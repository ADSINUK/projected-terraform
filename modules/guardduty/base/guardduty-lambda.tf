### IAM Role for GuardDuty SQS processing Lambda
resource "aws_iam_role" "gd-lambda" {
  name = "${var.name}-GuardDuty-Lambda-${var.aws_region}"

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": {"Service": "lambda.amazonaws.com"}
        }
      ]
    }
    POLICY

  tags = merge(var.tags, {
    Name = "${var.name}-GuardDuty-Lambda-${var.aws_region}"
  })
}

# Inline Policy: Allow Lambda to read messages from SQS
resource "aws_iam_role_policy" "gd-lambda-receive" {
  role = aws_iam_role.gd-lambda.id

  name   = "get-findings"
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:DeleteMessageBatch",
            "sqs:SendMessage",
            "sqs:ChangeMessageVisibility",
            "sqs:TagQueue",
            "sqs:UntagQueue",
            "sqs:PurgeQueue"
          ],
          "Resource": [
            "${aws_sqs_queue.guardduty.arn}",
            "${aws_sqs_queue.guardduty-dlq.arn}"
          ]
        }
      ]
    }
    POLICY
}

# Inline Policy: Allow Lambda to publish messages to SNS
resource "aws_iam_role_policy" "gd-lambda-notify" {
  role = aws_iam_role.gd-lambda.id

  name   = "send-notifies"
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "sns:Publish",
          "Resource": "${aws_sns_topic.guardduty.arn}"
        }
      ]
    }
    POLICY
}

# Inline Policy: Allow Lambda to write logs to CloudWatch Logs
resource "aws_iam_role_policy" "gd-lambda-logs" {
  role = aws_iam_role.gd-lambda.id

  name   = "publish-logs"
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
          "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:*"
        }
      ]
    }
    POLICY
}

resource "aws_iam_role_policy" "gd-lambda-kms" {
  role   = aws_iam_role.gd-lambda.id
  name   = "kms-gd-keys"
  policy = <<-POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RequiredKmsKeys",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:GenerateDataKey*",
                "kms:CreateGrant"
            ],
            "Resource": [
                "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${aws_kms_key.guard-cloudwatch.id}",
                "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${aws_kms_key.kms-lambda.key_id}",
                "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${aws_kms_key.guardduty.key_id}"
            ]
        },
        {
            "Sid": "AccessKmsList",
            "Effect": "Allow",
            "Action": "kms:ListAliases",
            "Resource": "*"
        }
    ]
}
    POLICY
}


resource "aws_iam_role_policy_attachment" "aws-lambda-vpc-access-execution-role" {
  role       = aws_iam_role.gd-lambda.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

### CloudWatch Log Group: Ensure retention
resource "aws_cloudwatch_log_group" "guardduty-relay" {
  name              = "/aws/lambda/${var.name}-guardduty-findings-relay"
  kms_key_id        = aws_kms_key.guard-cloudwatch.arn
  retention_in_days = 7
}


### Lambda Function: Relay GuardDuty Findings
# Compress source code
data "archive_file" "guardduty-relay-src" {
  type = "zip"

  source_file = "${path.module}/src/guardduty_findings_relay.py"
  output_path = "${path.module}/src/guardduty_findings_relay.zip"
}

resource "aws_ssm_parameter" "project" {
  name  = "/Lambda/EnvironmentVariable/PROJECT"
  type  = "SecureString"
  value = var.project_name

  tags = merge(var.tags, {
    Name = "/Lambda/EnvironmentVariable/PROJECT"
  })
}

resource "aws_ssm_parameter" "aws-sns-topic" {
  name  = "/Lambda/EnvironmentVariable/SNS_TOPIC"
  type  = "SecureString"
  value = aws_sns_topic.guardduty.arn

  tags = merge(var.tags, {
    Name = "/Lambda/EnvironmentVariable/SNS_TOPIC"
  })
}

### Security Group For Lambda
resource "aws_security_group" "lambda" {
  name   = "${var.name}-guardduty-findings-relay"
  vpc_id = var.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-guardduty-findings-relay"
  })
}

# The function itself
resource "aws_lambda_function" "guardduty-relay" {
  function_name = "${var.name}-guardduty-findings-relay"

  runtime     = "python3.8"
  handler     = "guardduty_findings_relay.handle"
  timeout     = 30
  kms_key_arn = aws_kms_key.kms-lambda.arn
  filename    = "${path.module}/src/guardduty_findings_relay.zip"

  source_code_hash = data.archive_file.guardduty-relay-src.output_base64sha256

  dead_letter_config {
    target_arn = aws_sqs_queue.guardduty-dlq.arn
  }

  environment {
    variables = {
      PROJECT   = aws_ssm_parameter.project.value
      SNS_TOPIC = aws_ssm_parameter.aws-sns-topic.value
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tracing_config {
    mode = "Active"
  }

  role = aws_iam_role.gd-lambda.arn

  tags = merge(var.tags, {
    Name = "${var.name}-guardduty-findings-relay"
  })

  # Ensure the log group is not created by a function run
  depends_on = [aws_cloudwatch_log_group.guardduty-relay]
}

# Trigger function by SQS
resource "aws_lambda_event_source_mapping" "gd-lambda-sqs" {
  enabled = true

  function_name = aws_lambda_function.guardduty-relay.arn

  event_source_arn = aws_sqs_queue.guardduty.arn
  batch_size       = 10
}
