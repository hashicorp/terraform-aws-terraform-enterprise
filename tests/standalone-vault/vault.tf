# Vault AppRole
# -------------
resource "hcp_vault_cluster" "test" {
  cluster_id      = local.test_name
  hvn_id          = "team-tfe-dev-hvn"
  public_endpoint = true
  tier            = "standard_medium"
}

resource "hcp_vault_cluster_admin_token" "test" {
  cluster_id = hcp_vault_cluster.test.cluster_id
}


# Vault Policy
# -------------
resource "vault_policy" "ptfe" {
  name = "dev-team"

  policy = <<EOT
    path "auth/approle/login" {
      capabilities = ["create", "read"]
    }
    path "sys/renew/*" {
      policy = "write"
    }
    path "auth/token/renew/*" {
      policy = "write"
    }
    path "transit/encrypt/atlas_*" {
      capabilities = ["create", "update"]
    }
    path "transit/decrypt/atlas_*" {
      capabilities = ["update"]
    }
    path "transit/encrypt/archivist_*" {
      capabilities = ["create", "update"]
    }
    # For decrypting datakey ciphertexts.
    path "transit/decrypt/archivist_*" {
      capabilities = ["update"]
    }
    # To upsert the transit key used for datakey generation.
    path "transit/keys/archivist_*" {
      capabilities = ["create", "update"]
    }
    # For performing key derivation.
    path "transit/datakey/plaintext/archivist_*" {
      capabilities = ["update"]
    }
    # For health checks to read the mount table.
    path "sys/mounts" {
      capabilities = ["read"]
    }
EOT
}

# Vault AppRole
# -------------
resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "approle" {
  backend        = vault_auth_backend.approle.path
  role_name      = "${local.test_name}-role"
  token_policies = [vault_policy.ptfe.name]
}

resource "vault_approle_auth_backend_role_secret_id" "approle" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.approle.role_name
}

resource "vault_mount" "transit" {
  path = "transit"
  type = "transit"
}
