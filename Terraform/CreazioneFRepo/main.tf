# -----------------------------------------------------
# VARIABILI LOCALI
# -----------------------------------------------------

locals {
  base_repo_name_min = lower(var.base_repo_name)
  empty_folders = [
    "Svil/", 
    "Svil/Deployment/",
    "Svil/Route/",
    "Svil/Secret/",
    "Svil/Service/",
    "Coll/", 
    "Coll/Deployment/",
    "Coll/Route/",
    "Coll/Secret/",
    "Coll/Service/",
    "Pre-Prod/", 
    "Pre-Prod/Deployment/",
    "Pre-Prod/Route/",
    "Pre-Prod/Secret/",
    "Pre-Prod/Service/",
    "Prod/", 
    "Prod/Deployment/",
    "Prod/Route/",
    "Prod/Secret/",
    "Prod/Service/",
  ]
}

# -----------------------------------------------------
# ApplicationBusiness
# -----------------------------------------------------

# A. Gruppo contenente lo stesso nome del progetto per ApplicationBusiness
resource "gitlab_group" "applicationbusiness_subgroup" {
  parent_id        = data.gitlab_group.applicationbusiness_group.group_id
  name             = var.base_repo_name
  path             = local.base_repo_name_min
  visibility_level = var.visibility
}

# B. Gruppo Frontend
resource "gitlab_group" "frontend_group" {
  parent_id        = gitlab_group.applicationbusiness_subgroup.id
  name             = "${var.base_repo_name}-FE" #nome gruppo indicato da input con -fe
  path             = "${local.base_repo_name_min}-fe" #path gruppo indicato da input con -fe
  visibility_level = var.visibility #impostazione di visibilità che scelgo durante la pipeline nwgli input
}

# C. Gruppo Backend
resource "gitlab_group" "backend_group" {
  parent_id        = gitlab_group.applicationbusiness_subgroup.id
  name             = "${var.base_repo_name}-BE"
  path             = "${local.base_repo_name_min}-be"
  visibility_level = var.visibility
}

# -----------------------------------------------------
# Projects
# -----------------------------------------------------

# A. Gruppo contenente lo stesso nome del progetto per Projects
resource "gitlab_group" "projects_subgroup" {
  parent_id        = data.gitlab_group.projects_group.group_id
  name             = var.base_repo_name
  path             = local.base_repo_name_min
  visibility_level = var.visibility
}

# B. Repo Frontend
resource "gitlab_project" "projects_frontend_repo" {
  name             = "${var.base_repo_name}-FE" 
  path             = "${local.base_repo_name_min}-fe"
  namespace_id     = gitlab_group.projects_subgroup.id
  visibility_level = var.visibility
}

# C. Repo Backend
resource "gitlab_project" "projects_backend_repo" {
  name             = "${var.base_repo_name}-BE"
  path             = "${local.base_repo_name_min}-be"
  namespace_id     = gitlab_group.projects_subgroup.id
  visibility_level = var.visibility
}

# -----------------------------------------------------
# CREAZIONE CARTELLE VUOTE SU PROJECTS
# ATTENZIONE, LO SCRIPT DI SOTTO ESEGUE COMMIT PER CARTELLA CREATA, QUINDI SE VENGONO CREATE 30 CARTELLE, CI SARANNO 30 COMMIT
# NEL CASO BISOGNA SPOSTARE LA LOGICA
# -----------------------------------------------------

# Frontend
resource "gitlab_repository_file" "projects_fe_empty_folders" {
  for_each = toset(local.empty_folders)
  project          = gitlab_project.projects_frontend_repo.id 
  file_path        = "${each.value}.gitkeep"
  content          = "Questo file forza Git a tracciare la cartella vuota."
  encoding         = "text"
  branch           = "main" 
  commit_message   = "Terraform script: Aggiunta cartella ${each.value}"
  depends_on = [gitlab_project.projects_frontend_repo]
}

# Backend
resource "gitlab_repository_file" "projects_be_empty_folders" {
  for_each = toset(local.empty_folders)
  project          = gitlab_project.projects_backend_repo.id 
  file_path        = "${each.value}.gitkeep"
  content          = "Questo file forza Git a tracciare la cartella vuota."
  encoding         = "text"
  branch           = "main"
  commit_message   = "Terraform script: Aggiunta cartella ${each.value}"
  depends_on = [gitlab_project.projects_backend_repo]
}

# ----------------------------------------------------------------------------
# Pipeline (Sviluppo, Release, API) Pipeline/Deploy (Collaudo, Pre-Prod, Prod)
# ----------------------------------------------------------------------------

# A. Gruppo contenente lo stesso nome del progetto per Pipelines
resource "gitlab_group" "pipeline_subgroup" {
  parent_id        = data.gitlab_group.pipeline_group.group_id
  name             = var.base_repo_name
  path             = local.base_repo_name_min
  visibility_level = var.visibility
}

# B. Gruppo Deploy che finirà sotto il gruppo Pipelines
resource "gitlab_group" "pipeline_deploy_group" {
  parent_id        = gitlab_group.pipeline_subgroup.id
  name             = "Deploy"
  path             = "deploy"
  visibility_level = var.visibility
}

# C. Repo Sviluppo
resource "gitlab_project" "pipeline_sviluppo_repo" {
  name             = "Sviluppo"
  path             = "sviluppo"
  namespace_id     = gitlab_group.pipeline_subgroup.id 
  visibility_level = var.visibility
}

# D. Repo Release
resource "gitlab_project" "pipeline_release_repo" {
  name             = "Release"
  path             = "release"
  namespace_id     = gitlab_group.pipeline_subgroup.id
  visibility_level = var.visibility
}

# E. Repo API
resource "gitlab_project" "pipeline_api_repo" {
  name             = "API"
  path             = "api"
  namespace_id     = gitlab_group.pipeline_subgroup.id
  visibility_level = var.visibility
}

# E. Repo Collaudo
resource "gitlab_project" "pipeline_coll_repo" {
  name             = "Collaudo"
  path             = "collaudo"
  namespace_id     = gitlab_group.pipeline_deploy_group.id 
  visibility_level = var.visibility
}

# F. Repo Pre-Prod
resource "gitlab_project" "pipeline_pre_repo" {
  name             = "Pre-Prod"
  path             = "pre-prod"
  namespace_id     = gitlab_group.pipeline_deploy_group.id
  visibility_level = var.visibility
}

# G. Repo Prod
resource "gitlab_project" "pipeline_prod_repo" {
  name             = "Prod"
  path             = "prod"
  namespace_id     = gitlab_group.pipeline_deploy_group.id
  visibility_level = var.visibility
}