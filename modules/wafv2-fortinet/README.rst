=============================================
MODULE: Fortinet Web Application firewall v.2
=============================================

General
=======

This module requires aws provider version >=2.70 

Copyright (c) 2020 Automat-IT


Module details
==============

Module creates WAF with Fortinet OWASP top 10 rules. Before using this module, you should `subscribe`_ to the module. 

Also module includes submodule that populate given WAF/WAFv2 regional ipset with IPs of the repo providers(github, bitbucket, gitlab). 

Module parameters are:

``name```
  Name and metric's name to assign to the resources.

``blacklisted_ips``
  IPs blacklist.

``tags``
  Tags to assign to the resources.


Example

``module "wafv2" {
  source = "../../modules/waf/"

  name = local.basename
  tags = local.base_tags

  blacklisted_ips = []

}``

### Outputs
output "web_acl_id" { value = module.wafv2.web_acl_id }

.. Links

.. _subscribe:  https://aws.amazon.com/marketplace/pp/B081SK32C7
.. _Fortinet WAF: https://kb.fortinet.com/kb/microsites/search.do?cmd=displayKC&docType=kc&externalId=FD41114
.. _cron: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
.. vim: set ts=2 sw=2 et tw=98 spell:
