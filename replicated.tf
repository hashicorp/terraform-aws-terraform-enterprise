locals {
  rptfeconf = {
    "demo"      = "${file("${path.module}/data/demo.json")}"
    "airgap"    = "${file("${path.module}/data/airgap.json")}"
    "es"        = "${file("${path.module}/data/es.json")}"
    "es_airgap" = "${file("${path.module}/data/es_airgap.json")}"
  }

  replconf = {
    "demo"      = "${file("${path.module}/data/demo_replicated.json")}"
    "airgap"    = "${file("${path.module}/data/airgap_replicated.json")}"
    "es"        = "${file("${path.module}/data/es_replicated.json")}"
    "es_airgap" = "${file("${path.module}/data/es_airgap_replicated.json")}"
  }
}
