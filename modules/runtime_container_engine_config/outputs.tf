# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "docker_compose_yaml" {
  value       = base64encode(yamlencode(local.compose))
  description = "A base 64 encoded yaml object that will be used as the Docker Compose file for TFE deployment."
}

output "podman_kube_yaml" {
  value       = base64encode(yamlencode(local.kube))
  description = "A base 64 encoded yaml object that will be used as the Podman kube.yaml file for TFE deployment"
}
