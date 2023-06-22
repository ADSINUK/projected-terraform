# MODULE: Access-analyzer

## General

This module creates following resources. `aws_accessanalyzer_analyzer`


## `iam-access-analyzer` module

This creates a simple access-analyzer, tagging it appropriately.

### Parameters

* `tags`
Base tags to assign to the resources

* `name` The name of the aws access-analyzer

### Example

```
### AIM Access Analyzer
module "iam-access-analyzer" {
  source = "../../modules/iam-access-analyzer"
  tags   = local.base_tags

  analyzer_name = "${local.basename}-Access-Analyzer"
}
```

--
Copyright (c) 2023 Automat-IT
