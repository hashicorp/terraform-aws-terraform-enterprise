locals {
  rptfeconf = {
    "demo-online"              = file("${path.module}/data/demo.json")
    "demo-airgap"              = file("${path.module}/data/airgap.json")
    "external_services-online" = file("${path.module}/data/es.json")
    "external_services-airgap" = file("${path.module}/data/es_airgap.json")
  }

  replconf = {
    "demo-online"              = file("${path.module}/data/demo_replicated.json")
    "demo-airgap"              = file("${path.module}/data/airgap_replicated.json")
    "external_services-online" = file("${path.module}/data/es_replicated.json")
    "external_services-airgap" = file("${path.module}/data/es_airgap_replicated.json")
  }
}

