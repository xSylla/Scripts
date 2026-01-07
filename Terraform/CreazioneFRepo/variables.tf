# -----------------------------------------------------
# VARIABILI
# -----------------------------------------------------

variable "gitlab_token" {
  description = "Token di autenticazione per l'API di GitLab"
  type        = string
  sensitive   = true
}

variable "base_repo_name" {
  type        = string
  description = "Il nome base"
}

variable "visibility" {
  type        = string
  description = "Visibilità del progetto"
  default     = "private"
}

variable "group_path_applicationbusiness" {
  type        = string
  description = "Path del gruppo padre per ApplicationBusiness"
}

variable "group_path_projects" {
  type        = string
  description = "Path del gruppo padre per Projects"
}

variable "group_path_pipeline" {
  type        = string
  description = "Path del gruppo padre per Pipeline"
}