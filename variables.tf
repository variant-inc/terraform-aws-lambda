variable "name" {
  description = "Lambda Function name."
  type        = string
}

variable "description" {
  description = "Description of Lambda Function"
  type        = string
  default     = ""
}

variable "create_role" {
  description = "Specifies should role be created with module or will there be external one provided."
  type        = bool
  default     = true
}

variable "policy" {
  description = "List of additional policies for Lambda access."
  type = list(any)
  default = []
}

variable "role" {
  description = "Custom role ARN used for SFN state machine."
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Number of MB of assigned RAM to Lambda Function."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for Lambda Function in seconds."
  type        = number
  default     = 3
}

variable "package_type" {
  description = "Type of package. For now this module supports only Image, not Zip."
  type        = string
  default     = "Image"
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version."
  type        = bool
  default     = true
}

variable "image_uri" {
  description = "URI of ECR image used for this Lambda Function."
  type        = string
}

variable "image_config" {
  description = "Additional image config for overriding thing in the image."
  type        = any
  default     = {}
}

variable "dead_letter_target" {
  description = "Target for deadletter invocations SQS queue or SNS topic."
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "KMS key used for environment variable encryption. Uses default if not set"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Map of environment variables that need to be set in the container."
  type        = any
  default     = {}
}

variable "tracing_mode" {
  description = "Mode for x-ray tracing."
  type        = string
  default     = ""
}

variable "vpc_config" {
  description = "Map containing VPC configuration."
  type        = map(list(string))
  default     = {}
}

variable "aliases" {
  description = "Map of aliases and their config."
  type        = any
  default     = {
    prod = {
      description = "Default alias"
      version     = "$LATEST"
    }
  }
}

variable "lambda_permissions" {
  description = "Map of resource based permissions for lambda."
  type        = any
  default     = {}
}

variable "event_invoke" {
  description = "Configuration for async execution."
  type        = any
  default     = {}
}

variable "enable_retry_logic" {
  description = "Should this function have retry logic with SREve bot."
  type        = bool
  default     = false
}

variable "reciever_lambda" {
  description = "Name of Lambda that will act as reciever of Error events."
  type        = string
  default     = "receive-alert"
}

variable "filter_pattern" {
  description = "Filter pattern for CW log subscription filter."
  type        = string
  default     = "?ERROR ?event_log"
}