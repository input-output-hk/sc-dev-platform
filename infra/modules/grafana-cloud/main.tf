provider "sops" {}

data "sops_file" "this" {
  source_file = var.path_to_sops
}

# Declaring the first provider to be only used for creating the cloud-stack
provider "grafana" {
  alias         = "first"

  cloud_api_key = data.sops_file.this.data["grafana_cloud_api_key"]
}

resource "grafana_cloud_stack" "this" {
  provider    = grafana.first

  name        = var.stack_name
  slug        = var.stack_name
  region_slug = var.region
}

# Creating an API key in Grafana instance to be used for creating resources in Grafana instance
resource "grafana_api_key" "this" {
  provider = grafana.first

  cloud_stack_slug = grafana_cloud_stack.this.slug
  name             = "${var.stack_name}_key"
  role             = "Admin" 
}

# Declaring the second provider to be used for creating resources in Grafana        
provider "grafana" {
  alias         = "second"

  url  = grafana_cloud_stack.this.url
  auth = grafana_api_key.this.key
}