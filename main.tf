# Create KMS key to encrypt contents of tfstate bucket
resource "aws_kms_key" "tfstate-kms-key" {
    description             = "Used to encrypt the s3 bucket ${var.s3_bucket_name}"
    deletion_window_in_days = 10
    tags                    = var.tags
}

# Create an alias for the tfstate bucket encryption key
resource "aws_kms_alias" "tfstate-kms-key-alias" {
    name          = "alias/${var.kms_key_alias_name}"
    target_key_id = aws_kms_key.tfstate-kms-key.key_id
}

# Create encrypted s3 bucket to hold terraform remote state
resource "aws_s3_bucket" "tfstate-s3-bucket" {
    bucket        = var.s3_bucket_name
    acl           = "private"
    tags          = var.tags
    force_destroy = true

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                kms_master_key_id = aws_kms_key.tfstate-kms-key.arn
                sse_algorithm     = "aws:kms"
            }
        }
    }

#    lifecycle {
#        prevent_destroy = true
#    }
}

# Block creation of objects in this bucket with public access
resource "aws_s3_bucket_public_access_block" "tfstate-s3-public-block" {
  bucket = aws_s3_bucket.tfstate-s3-bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# Create a dynamodb table to enable terraform state locking
resource "aws_dynamodb_table" "tfstate-lock-dynamodb" {
    name         = "${var.s3_bucket_name}-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    tags         = var.tags

    attribute {
        name = "LockID"
        type = "S"
    }
}

# Define an IAM policy that allows users in the above group
# to do the necessary operations on state management entities
data "aws_iam_policy_document" "tfstate-policy-management-document" {
    # View the bucket that holds the state
    statement {
        actions = [
            "s3:ListBucket",
        ]

        resources = [
            aws_s3_bucket.tfstate-s3-bucket.arn
        ]
    }

    # Read from and write to the key that holds the state
    statement {
        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]

        resources = [
            "${aws_s3_bucket.tfstate-s3-bucket.arn}/*"
        ]
    }

    # Read from and write to the dynamodb instance that locks state
    statement {
        actions = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem"
        ]

        resources = [
            aws_dynamodb_table.tfstate-lock-dynamodb.arn
        ]
    }
}

resource "aws_iam_policy" "tfstate-management-policy" {
    name   = var.iam_policy_name
    path   = "/"
    policy = data.aws_iam_policy_document.tfstate-policy-management-document.json
}

# Create an IAM group to hold IAM users that need access to the
# s3 bucket and dynamodb table to manage state
resource "aws_iam_group" "tfstate-managers-group" {
    name = var.iam_group_name
}

# Attach the TerraformStateManagementPolicy policy to
# the TerraformStateManagers group
resource "aws_iam_group_policy_attachment" "tfstate-policy-attach" {
  group      = aws_iam_group.tfstate-managers-group.name
  policy_arn = aws_iam_policy.tfstate-management-policy.arn
}

# Determine the current AWS account ID
data "aws_caller_identity" "current" {}

locals {
    account_id = "${data.aws_caller_identity.current.account_id}"
}

# Create a KMS grant to allow the specified users
# to use the tfstate KMS key to encrypt and decrypt state in the s3 bucket
resource "aws_kms_grant" "tfstate-kms-grant" {
    for_each          = toset(var.iam_usernames)

    name              = var.kms_grant_name
    key_id            = aws_kms_key.tfstate-kms-key.key_id
    grantee_principal = "arn:aws:iam::${local.account_id}:user/${each.value}"
    operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}

# Add the specified users to the TerraformStateManagers group
resource "aws_iam_user_group_membership" "tfstate-managers-group-users" {
    for_each = toset(var.iam_usernames)

    user     = each.value

    groups = [
      aws_iam_group.tfstate-managers-group.name
    ]
}
