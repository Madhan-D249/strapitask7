variable "region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "container_image" {
  description = "The full image URI for the container"
  type        = string
}

variable "app_keys" {
  description = "Strapi app keys"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret used by Strapi"
  type        = string
  sensitive   = true
}

variable "admin_jwt_secret" {
  description = "Admin JWT secret used by Strapi"
  type        = string
  sensitive   = true
}

variable "api_token_salt" {
  description = "API token salt used by Strapi"
  type        = string
  sensitive   = true
}