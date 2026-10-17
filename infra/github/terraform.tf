terraform {
  required_version = "= 1.16.6"

  cloud {
    organization = "visiblelight"

    workspaces {
      name = "stdlib-github"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "= 6.13.0"
    }
  }
}

# Configure stdlib-github for Local execution in HCP Terraform before init.
# Authentication comes from GITHUB_TOKEN in the root mise.local.toml.
provider "github" {
  owner = "visiblelightio"
}
