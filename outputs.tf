output "tfstate-bucket-id" {
    value       = aws_s3_bucket.tfstate-s3-bucket.id
    description = "The ID of the tfstate bucket"
}

output "tfstate-bucket-arn" {
    value       = aws_s3_bucket.tfstate-s3-bucket.arn
    description = "The ARN of the tfstate bucket"
}

output "tfstate-bucket-kms-key-id" {
    value       = aws_kms_alias.tfstate-kms-key-alias.id
    description = "The ID of the KMS key that is used to encrypt the tfstate bucket"
}

output "tfstate-bucket-kms-key-arn" {
    value       = aws_kms_alias.tfstate-kms-key-alias.arn
    description = "The ARN of the KMS key that is used to encrypt the tfstate bucket"
}

output "tfstate-dynamodb-table-id"{
    value       = aws_dynamodb_table.tfstate-lock-dynamodb.id
    description = "The ID of the dynamodb table that locks terraform operations"
}

output "tfstate-dynamodb-table-arn"{
    value       = aws_dynamodb_table.tfstate-lock-dynamodb.arn
    description = "The ARN of the dynamodb table that locks terraform operations"
}

