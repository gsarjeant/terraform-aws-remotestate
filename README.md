# terraform-aws-remotestate

An opinionated module for managing entities needed to support terraform remote state on AWS.

### Description

Terraform is able to store state remotely in an S3 bucket, and this is Hashicorp's recommended aproach when multiple people or service accounts are responsible for managing the state of AWS resources. For a detailed explanation of Terraform Remote State, including benefits and recommended configuration, please see the [Remote State page](https://www.terraform.io/docs/state/remote.html) in the Terraform docs.

This module manages the entities that are needed to support remote state on AWS as recommended by Hashicorp for secure storage in team environments. My goal is to make this a least-privilege implementation of remote state managmenet. Briefly, that includes:

* An S3 bucket to store terraform state
* A DynamoDB table to lock state and prevent concurrent runs
* A KMS key to encrypt and decrypt terraform state in the S3 bucket
* An IAM Policy to confer access to required AWS entities
* An IAM group to hold users that are granted access to manage remote state

### Input Variables

* `s3_bucket_name` (Required)
   * The name of the s3 bucket that will hold the remote state. *NOTE:* this must be **globally unique** in AWS.
* `iam_group_name` (Optional)
    *  The name of the group that will be created to hold IAM users who have access to remote state
    *  Default: *TerrafromStateManagers*
* `iam_policy_name` (Optional)
    * The name of the IAM policy that confers access to entities required to manage remote state
    * This policy is attached to the *TerraformStateManagers* group
    * Default: *TerrafromStateManagementPolicy*
* `kms_grant_name` (Optional)
    * The name of the KMS grant that allows designated users to use the `tfstate-kms-key` key to encrypt and decrypt remote state
    * This grant is assigned to each username specified in `iam_usernames`
    * Default: *TerraformStateManagersKMSGrant*
* `kms_key_alias_name` (Optional)
    * The name of the key alias that is assigned to the `tfstate-kms-key` key.
    * This is a human-readable label for the KMS key so that it can be more easily identified in the AWS management console
    * Default: *kms_key_alias_name*
* `iam_usernames` (Optional)
    * A list of IAM usernames that will be granted access to manage terraform remote state
    * These should generally correspond to your terraform service accounts
    * Username in this list will be added to the following entities
        * tfstate-managers-group
        * tfstate-kms-grant
* `tags` (Optional)
    * A list of tags that will be applied to all entities that support tags.
