# -----------------------------------------------------
# PROVIDER E CONFIGURAZIONE
# -----------------------------------------------------
terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 18.5.0"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
  #base_url = "https://gitlab.com/api/v4/" #non serve se non custom
}

# -----------------------------------------------------
# DATA SOURCES (Per recuperare gli ID dei gruppi)
# -----------------------------------------------------

# Risolve l'ID del gruppo ApplicationBusiness
data "gitlab_group" "applicationbusiness_group" {
  full_path = var.group_path_applicationbusiness
}

# Risolve l'ID del gruppo Projects
data "gitlab_group" "projects_group" {
  full_path = var.group_path_projects
}

# Risolve l'ID del gruppo Pipeline
data "gitlab_group" "pipeline_group" {
  full_path = var.group_path_pipeline
}