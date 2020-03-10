variable "s3_bucket_name" {
    type        = string
    description = "The name of the s3 bucket that will hold the remote state"
}

variable "iam_group_name" {
    type        = string
    description = "The name of the IAM group to which users that are allowed to manage terraform state will belong"
    default     = "TerrafromStateManagers"
}

variable "iam_policy_name" {
    type        = string
    description = "The name of the IAM policy that confers access to the AWS entities that are needed to manage remote state (S3 bucket, dynamoDB table, etc.)"
    default     = "TerrafromStateManagementPolicy"
}

variable "kms_grant_name" {
    type        = string
    description = "The name of the KMS grant that confers access to the KMS key used to encrypt and decrypt remote state"
    default     = "TerraformStateManagersKMSGrant"
}

variable "kms_key_alias_name" {
    type        = string
    description = "The name of the KMS key alias (human-readable name) for the remote state encryption key"
    default     = "tfstate-key-alias"
}

variable "iam_usernames" {
    type        = list(string)
    description = "list of IAM usernames that have access to manage remote state"
    default     = []
}

variable "tags" {
    type        = map
    description = "Tags to associate with resources created by this module"
    default     = {}
}
