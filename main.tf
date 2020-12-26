terraform {
  required_version = ">=0.12"
}

variable "input" {
  description = "A list containing exactly two YAML strings to be merged."
  type        = list(string)
}

variable "dedupe" {
  description = "Deduplicate values in resulting merged lists."
  type        = bool
  default     = false
}

locals {
  alpha      = yamldecode(var.input[0])
  beta       = yamldecode(var.input[1])
  alphakeys  = [for key, val in local.alpha : key]
  betakeys   = [for key, val in local.beta : key]
  commonkeys = setintersection(local.alphakeys, local.betakeys)
  merged = merge(local.alpha, local.beta,
    {
      for key in local.commonkeys :
      key => var.dedupe ?
      distinct(
        compact(concat(
          # If not a list, convert to list with single element
          split(
            ":::::::", [flatten([for x in [local.alpha[key]] : x])[0]] ==
            [[for x in [local.alpha[key]] : x][0]] ?
            tostring(local.alpha[key]) : join(":::::::", local.alpha[key])
          ),
          split(
            ":::::::", [flatten([for x in [local.beta[key]] : x])[0]] ==
            [[for x in [local.beta[key]] : x][0]] ?
            tostring(local.beta[key]) : join(":::::::", local.beta[key])
          )
        ))
      ) :
      compact(concat(
        # If not a list, convert to list with single element
        split(
          ":::::::", [flatten([for x in [local.alpha[key]] : x])[0]] ==
          [[for x in [local.alpha[key]] : x][0]] ?
          tostring(local.alpha[key]) : join(":::::::", local.alpha[key])
        ),
        split(
          ":::::::", [flatten([for x in [local.beta[key]] : x])[0]] ==
          [[for x in [local.beta[key]] : x][0]] ?
          tostring(local.beta[key]) : join(":::::::", local.beta[key])
        )
      ))
    }
  )
}

output "result" {
  value = yamlencode(local.merged)
}
