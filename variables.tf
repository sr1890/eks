variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [{
    userarn = "arn:aws:iam::219077731788:user/auditor1",
    username = "auditor1",
    groups = ["audit-team"]
  }]
}
