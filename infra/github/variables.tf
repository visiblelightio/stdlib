variable "woodpecker_pr_status_context" {
  description = "Observed Woodpecker PR status context. Leave null until the CI rollout has been verified."
  type        = string
  default     = null

  validation {
    condition = var.woodpecker_pr_status_context == null ? true : (
      length(trimspace(var.woodpecker_pr_status_context)) > 0 &&
      var.woodpecker_pr_status_context == trimspace(var.woodpecker_pr_status_context)
    )
    error_message = "Use null or an observed status context without leading or trailing whitespace."
  }
}
