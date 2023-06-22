# -*- coding: UTF-8 -*-

from datetime import datetime
import json
import os
import boto3
import botocore.session
from base64 import b64decode

# Probably will be needed for another encryption option
# To be able decrypt data
# ENCRYPTED = os.environ['PROJECT']
# # Decrypt code should run once and variables stored outside of the function
# # handler so that these are decrypted once per container
# DECRYPTED = boto3.client('kms').decrypt(
#     CiphertextBlob=b64decode(ENCRYPTED),
#     EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
# )['Plaintext'].decode('utf-8')

def lambda_handler(event, context):
    # TODO handle the event here
    pass

# Load configuration data
SNS_TOPIC = os.environ["SNS_TOPIC"]
SNS_REGION = SNS_TOPIC.split(":")[3]
PROJECT = os.getenv("PROJECT", None)

# Minimum finding severity to send a notify
SNS_SEVERITY = int(os.getenv("SNS_SEVERITY", "0"))



def format_instance(details):
    """Format EC2 instance details"""
    # Check if there is a Name tag
    for tag in details["tags"]:
        if tag["key"] == "Name":
            details["name_tag"] = " (" + tag["value"] + ")"
            break
    else:
        details["name_tag"] = ""

    return "{instanceId}{name_tag} running in {availabilityZone}".format(**details)


def format_accesskey(details):
    """Format AccessKey details"""
    if "userType" in details:
        return "{userType}/{userName}".format(**details)

    if "principalId" in details:
        return "Principal: {principalId}".format(**details)

    if "accessKeyId" in details:
        return "AccessKey: {accessKeyId}".format(**details)

    return "(unspecified/unrecognized AccessKey)"


def format_datetime(timestamp):
    """Parses and re-formats timestamps"""
    try:
        return datetime.fromisoformat(timestamp[:-1]).ctime()
    except ValueError:
        return timestamp


def format_localport(details):
    """Format local port details"""
    return "Local port: {port}/{name}\n".format(
        port=details.get("port", "(unknown)"),
        name=details.get("portName", "(unknown)"),
        )


def format_remoteip(details):
    """Format remote IP details"""
    if "organization" in details and "asn" in details["organization"]:
        asn = "AS" + details["organization"]["asn"]
    else:
        asn = "unknown AS"

    return "Remote IP: {ipv4} ({asn})\n".format(
        ipv4=details.get("ipAddressV4", "(unknown)"),
        asn=asn,
        )


def format_portprobe(action):
    """Format PortProbe type finding"""
    result = ""

    # Check if the probe was blocked
    if "blocked" in action:
        result += "Blocked: " + ("yes" if action["blocked"] else "NO") + "\n"
    else:
        result += "Blocked: (unknown)\n"

    # List port probe details (if any)
    for probe in action.get("portProbeDetails", []):
        result += format_localport(probe["localPortDetails"])
        result += format_remoteip(probe["remoteIpDetails"])

    return result


def format_connection(action):
    """Format Connection type finding"""
    result = ""

    # Check if the probe was blocked
    if "blocked" in action:
        result += "Blocked: " + ("yes" if action["blocked"] else "NO") + "\n"
    else:
        result += "Blocked: (unknown)\n"

    result += "Direction: {}\n".format(action["connectionDirection"])
    result += "Protocol: {}\n".format(action["protocol"])

    result += ("Local port: "
               + str(action["localPortDetails"]["port"])
               + "/"
               + action["localPortDetails"]["portName"]
               + "\n")

    result += ("Remote IP: "
               + action["remoteIpDetails"]["ipAddressV4"]
               + " (AS" + action["remoteIpDetails"]["organization"]["asn"] + ")"
               + "\n")

    return result


REPORT_TPL = """\
ID: {id}
Full info: https://console.aws.amazon.com/guardduty/home?region={region}#/findings?search=id%3D{id}

Severity: {severity}
Type: {type}
Region: {region}
Resource: {resource_info}

Description: {description}
{event_details}

First seen: {event_seen_first} (UTC)
Last seen: {event_seen_last} (UTC)
Total count: {event_total_count}
"""
def format_finding(msg):
    """Format GuardDuty Finding as a message"""
    # Set defaults
    report = dict.fromkeys(("resource_info", "event_seen_first",
                            "event_seen_last", "event_total_count"),
                           "(unknown)")
    report["event_details"] = ""

    # Copy known finding keys
    for k in ("id", "region", "severity", "type", "description"):
        report[k] = msg.get(k, "(unknown)")

    # Find out more about the resource
    if "resource" in msg and "resourceType" in msg["resource"]:
        if msg["resource"]["resourceType"] == "Instance":
            report["resource_info"] = format_instance(msg["resource"].get("instanceDetails", {}))
        elif msg["resource"]["resourceType"] == "AccessKey":
            report["resource_info"] = format_accesskey(msg["resource"].get("accessKeyDetails", {}))


    if "service" in msg:
        # Re-format timestamps
        if "eventFirstSeen" in msg["service"]:
            report["event_seen_first"] = format_datetime(msg["service"]["eventFirstSeen"])
        if "eventLastSeen" in msg["service"]:
            report["event_seen_last"] = format_datetime(msg["service"]["eventLastSeen"])
        if "count" in msg["service"]:
            report["event_total_count"] = msg["service"]["count"]

        if "action" in msg["service"]:
            action = msg["service"]["action"]

            if "portProbeAction" in action:
                report["event_details"] += format_portprobe(action["portProbeAction"])

            if "networkConnectionAction" in action:
                report["event_details"] += format_connection(action["networkConnectionAction"])

    if not "description" in msg:
        msg["description"] = msg["title"] if "title" in msg else "(no description)"

    result = ""

    # Add internal project ID if available
    if PROJECT is not None:
        result += "Project: " + PROJECT + "\n"

    # Add AWS Account ID if available
    if "accountId" in msg:
        result += "AWS Account #" + msg["accountId"] + "\n"

    # Add an extra empty line if any info was added to the report
    if result:
        result += "\n"

    # Get the rest of the report
    result += REPORT_TPL.format(**report)

    return result


def handle(event, context):
    """Relay GuardDuty Findings events from SQS to SNS"""
    sns = botocore.session.get_session().create_client("sns", region_name=SNS_REGION)

    print(f"""Processing {len(event["Records"])} records""")
    for record in event["Records"]:
        # Get message body
        try:
            msg = json.loads(record["body"])
        except ValueError:
            print(f"""Cannot parse message body as JSON:\n{record["body"]}""")
            continue

        # Parse message body as JSON
        try:
            msg = json.loads(msg["Message"])
        except ValueError:
            print(f"""Cannot parse message as JSON:\n{msg["Message"]}""")
            continue

        # Sample findings have a different message format somehow?..
        if "detail" in msg:
            msg = msg["detail"]

        # Process the finding
        try:
            print("Finding {id} of severity {severity}".format(**msg))

            if int(msg["severity"]) < SNS_SEVERITY:
                print("Skipping because severity is below configured threshold".format(**msg))
                continue

            message = format_finding(msg)
        except Exception as e:
            print(f"Error processing event: {e}")
            continue

        print("Sending notify")
        # Some sample events don't have this
        try:
            sns.publish(
                TopicArn=SNS_TOPIC,
                Subject="GuardDuty Finding",
                Message=message,
                )
        except Exception as e:
            print(f"ERROR: {e}")

