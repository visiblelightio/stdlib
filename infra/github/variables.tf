variable "woodpecker_pr_status_contexts" {
  description = "Observed Woodpecker PR status contexts required to merge into main."
  type        = set(string)
  default = [
    "Format (pr)",
    "Hooks (pr)",
    "Lint (pr)",
    "Tests (pr)",
    "Typecheck (pr)",
  ]
  nullable = false

  validation {
    condition = alltrue([
      for context in var.woodpecker_pr_status_contexts : context == null ? false : (
        length(trimspace(context)) > 0 && context == trimspace(context)
      )
    ])
    error_message = "Use observed status contexts without empty values or leading or trailing whitespace."
  }
}
