# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

locals {

  active_active = var.operational_mode == "active-active"
  disk          = var.operational_mode == "disk"
  env = merge(
    local.database_configuration,
    local.redis_configuration,
    local.storage_configuration,
    local.vault_configuration,
    local.explorer_database_configuration,
    {
      http_proxy                    = var.http_proxy != null ? "http://${var.http_proxy}" : null
      HTTP_PROXY                    = var.http_proxy != null ? "http://${var.http_proxy}" : null
      https_proxy                   = var.https_proxy != null ? "http://${var.https_proxy}" : null
      HTTPS_PROXY                   = var.https_proxy != null ? "http://${var.https_proxy}" : null
      no_proxy                      = var.no_proxy != null ? join(",", var.no_proxy) : null
      NO_PROXY                      = var.no_proxy != null ? join(",", var.no_proxy) : null
      TFE_HOSTNAME                  = var.hostname
      TFE_HTTP_PORT                 = var.http_port
      TFE_HTTPS_PORT                = var.https_port
      TFE_ADMIN_HTTPS_PORT          = var.admin_api_https_port
      TFE_OPERATIONAL_MODE          = var.operational_mode
      TFE_ENCRYPTION_PASSWORD       = random_password.enc_password.result
      TFE_DISK_CACHE_VOLUME_NAME    = "terraform-enterprise_terraform-enterprise-cache"
      TFE_LICENSE_REPORTING_OPT_OUT = var.license_reporting_opt_out
      TFE_USAGE_REPORTING_OPT_OUT   = var.usage_reporting_opt_out
      TFE_LICENSE                   = var.tfe_license
      TFE_TLS_CA_BUNDLE_FILE        = var.tls_ca_bundle_file != null ? var.tls_ca_bundle_file : null
      TFE_TLS_CERT_FILE             = var.cert_file
      TFE_TLS_CIPHERS               = var.tls_ciphers
      TFE_TLS_KEY_FILE              = var.key_file
      TFE_TLS_VERSION               = var.tls_version != null ? var.tls_version : ""
      TFE_RUN_PIPELINE_IMAGE        = var.run_pipeline_image
      TFE_CAPACITY_CONCURRENCY      = var.capacity_concurrency
      TFE_CAPACITY_CPU              = var.capacity_cpu
      TFE_CAPACITY_MEMORY           = var.capacity_memory
      TFE_IACT_SUBNETS              = var.iact_subnets
      TFE_IACT_TIME_LIMIT           = var.iact_time_limit
      TFE_IACT_TRUSTED_PROXIES      = join(",", var.trusted_proxies)
    }
  )
  # compose files allow for $ deliminated variable injection.  $$ is the appropriate escape.
  sensitive_fields = ["TFE_ENCRYPTION_PASSWORD", "TFE_DATABASE_PASSWORD", "TFE_REDIS_PASSWORD"]
  compose_escaped_env = {
    for k, v in local.env :
    k => (contains(local.sensitive_fields, k) ? replace((v == null ? "" : v), "$", "$$") : v)
  }
  compose = {
    version = "3.9"
    name    = "terraform-enterprise"
    services = {
      tfe = {
        image       = var.tfe_image
        environment = local.compose_escaped_env
        cap_add = [
          "IPC_LOCK"
        ]
        read_only = true
        tmpfs = [
          "/tmp:mode=01777",
          "/run:${var.enable_run_exec_tmpfs ? "exec" : "noexec"}",
          "/var/log/terraform-enterprise",
        ]
        ports = flatten([
          "80:${var.http_port}",
          "443:${var.https_port}",
          "${var.admin_api_https_port}:${var.admin_api_https_port}",
          local.active_active ? ["8201:8201"] : [],
          var.metrics_endpoint_enabled ? [
            "${var.metrics_endpoint_port_http}:9090",
            "${var.metrics_endpoint_port_https}:9091"
          ] : []
        ])

        volumes = flatten([
          {
            type   = "bind"
            source = "/var/run/docker.sock"
            target = "/run/docker.sock"
          },
          {
            type   = "bind"
            source = "/etc/tfe/ssl"
            target = "/etc/ssl/private/terraform-enterprise"
          },
          {
            type   = "bind"
            source = "/etc/tfe/ssl/postgres"
            target = "/etc/ssl/private/terraform-enterprise/postgres"
          },
          {
            type   = "bind"
            source = "/etc/tfe/ssl/redis"
            target = "/etc/ssl/private/terraform-enterprise/redis"
          },
          {
            type   = "volume"
            source = "terraform-enterprise-cache"
            target = "/var/cache/tfe-task-worker/terraform"
          },
          local.disk ? [{
            type   = "bind"
            source = var.disk_path
            target = "/var/lib/terraform-enterprise"
          }] : [],
        ])
      }
    }
    volumes = merge(
      { terraform-enterprise-cache = {} },
      local.disk ? { terraform-enterprise = {} } : {}
    )
  }
  kube = {
    apiVersion = "v1"
    kind       = "Pod"
    metadata = {
      labels = {
        app = "terraform-enterprise"
      }
      name = "terraform-enterprise"
    }
    spec = {
      restartPolicy = "Never"
      containers = [{
        env = [
          for k, v in local.env : {
            name  = k,
            value = v
          }
        ]
        image = var.tfe_image
        name  = "terraform-enterprise"
        ports = flatten([
          {
            containerPort = var.http_port
            hostPort      = 80
          },
          {
            containerPort = var.https_port
            hostPort      = 443
          },
          {
            containerPort = var.admin_api_https_port
            hostPort      = var.admin_api_https_port
          },
          local.active_active ? [{ containerPort = 8201, hostPort = 8201 }] : [],
          var.metrics_endpoint_enabled ? [
            { containerPort = 9090, hostPort = var.metrics_endpoint_port_http },
            { containerPort = 9091, hostPort = var.metrics_endpoint_port_https }
          ] : []
        ])
        securityContext = {
          capabilities = {
            add = [
              "CAP_IPC_LOCK"
            ]
          }
          readOnlyRootFilesystem = true
          seLinuxOptions = {
            type = "spc_t"
          }
        }
        volumeMounts = flatten([
          {
            mountPath = "/etc/ssl/private/terraform-enterprise"
            name      = "certs"
          },
          {
            mountPath = "/var/log/terraform-enterprise"
            name      = "log"
          },
          {
            mountPath = "/run"
            name      = "run"
          },
          {
            mountPath = "/tmp"
            name      = "tmp"
          },
          {
            mountPath = "/run/docker.sock"
            name      = "docker-sock"
          },
          {
            mountPath = "/var/cache/tfe-task-worker/terraform"
            name      = "terraform-enterprise_terraform-enterprise-cache-pvc"
          },
          local.disk ? [{
            mountPath = "/var/lib/terraform-enterprise"
            name      = "data"
          }] : []
        ])
        },
      ]
      volumes = flatten([
        {
          hostPath = {
            path = "/etc/tfe/ssl"
            type = "Directory"
          }
          name = "certs"
        },
        {
          emptyDir = {
            medium = "Memory"
          }
          name = "log"
        },
        {
          emptyDir = {
            medium = "Memory"
          }
          name = "run"
        },
        {
          emptyDir = {
            medium = "Memory"
          }
          name = "tmp"
        },
        {
          hostPath = {
            path = "/var/run/docker.sock"
            type = "File"
          }
          name = "docker-sock"
        },
        {
          name = "terraform-enterprise_terraform-enterprise-cache-pvc"
          persistentVolumeClaim = {
            claimName = "terraform-enterprise_terraform-enterprise-cache"
          }
        },
        local.disk ? [{
          hostPath = {
            path = var.disk_path
            type = "Directory"
          }
          name = "data"
        }] : [],
      ])
    }
  }
}

resource "random_password" "enc_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
