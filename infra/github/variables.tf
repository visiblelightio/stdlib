variable "woodpecker_pr_status_contexts" {
  description = "Observed Woodpecker PR status contexts for every workflow. Leave empty until the CI rollout has been verified."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for context in var.woodpecker_pr_status_contexts : context == null ? false : (
        length(trimspace(context)) > 0 && context == trimspace(context)
      )
    ])
    error_message = "Use observed status contexts without empty values or leading or trailing whitespace."
  }
}
