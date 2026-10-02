module "this" {
    source = "../.."

    name        = "data-lakehouse-governed"
    environment = "dev"

retention_days = 730

    tags = {
      Owner      = "platform-team"
      CostCenter = "portfolio"
    }
  }
