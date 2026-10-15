variable "project_name" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "primary_region" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group for Data Factory"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = ""
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for Data Factory"
  type        = bool
  default     = true
}

variable "git_repo_type" {
  description = "Git repo type (AzureDevOpsGit or GitHub)"
  type        = string
  default     = "GitHub"
}

variable "git_repo_url" {
  description = "Git repository URL"
  type        = string
  default     = ""
}

variable "git_branch" {
  description = "Git branch"
  type        = string
  default     = "main"
}

variable "git_root_folder" {
  description = "Root folder in repo"
  type        = string
  default     = "/"
}

variable "managed_private_endpoint_targets" {
  description = "ADF managed private endpoints: name (static key), target_resource_id, subresource_name"
  type = list(object({
    name               = string
    target_resource_id = string
    subresource_name   = string
  }))
  default = []
}
