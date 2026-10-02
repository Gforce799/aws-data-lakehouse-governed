# AWS Governed Data Lakehouse

    A governed data lakehouse baseline with encrypted S3 zones, Glue catalog, Lake Formation registration, Athena workgroup controls, and analytics access boundaries.

    **Portfolio size:** Large

    ## AWS services covered

    - Amazon S3
- AWS Glue Data Catalog
- AWS Lake Formation
- Amazon Athena
- AWS KMS
- IAM

    ## Enterprise controls demonstrated

    - Provider pinning and repeatable Terraform workflows.
    - Encryption at rest with KMS where the service supports customer managed keys.
    - Least-privilege IAM roles and narrowly scoped service policies.
    - Consistent tagging, naming, retention, and environment separation.
    - CI checks for formatting, validation, linting, and IaC security scanning.
    - Security documentation, architecture notes, and reusable module structure.

    ## Quick start

    ```bash
    terraform init
    terraform fmt -recursive
    terraform validate
    terraform plan -out=tfplan
    ```

    ## Production hardening checklist

    - Replace placeholder CIDR ranges, ARNs, domain names, and retention windows.
    - Connect remote state with state locking before team usage.
    - Review every IAM trust relationship against your account structure.
    - Enable branch protection and required CI checks in GitHub.
    - Run a cost estimate before deployment to a live AWS account.

    ## Repository intent

    This repository is designed as a professional AWS infrastructure template.
    It favors clear architecture, security defaults, and reviewable Terraform
    over one-click deployment magic.
