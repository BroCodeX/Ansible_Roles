# {{ ansible_managed }}

ui = true
disable_mlock = {{ vault_disable_mlock | lower }}

api_addr     = "http://vault1:8200"
cluster_addr = "http://vault1:8201"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = {{ vault_tls_disable | lower }}
}

storage "raft" {
  path    = "/vault/data"
  node_id = "vault1"
  retry_join {
    leader_api_addr = "http://vault1:8200"
  }
  retry_join {
    leader_api_addr = "http://vault2:8200"
  }
}
