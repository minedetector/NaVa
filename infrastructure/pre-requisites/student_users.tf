# Students group
resource "aws_iam_group" "students" {
  name = "students"
}

# Custom policy for students
resource "aws_iam_policy" "students_custom" {
  name        = "StudentsCustomPolicy"
  description = "Custom policy for student access with resource restrictions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2FullAccess"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "logs:*",
          "cloudformation:*",
          "cloudformation:CreateStack"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyNonT3MicroEC2Launch"
        Effect = "Deny"
        Action = "ec2:RunInstances"
        Resource = "arn:aws:ec2:eu-north-1:*:instance/*"
        Condition = {
          StringNotEquals = {
            "ec2:InstanceType" = "t3.micro"
          }
        }
      },
      {
        Sid    = "RDSFullAccess"
        Effect = "Allow"
        Action = [
          "rds:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "KMS"
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyNonT3MicroRDSCreation"
        Effect = "Deny"
        Action = "rds:CreateDBInstance"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "rds:DatabaseClass" = "db.t3.micro"
          }
        }
      },
      {
        Sid    = "S3ReadAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetObjectVersion",
          "s3:ListBucketVersions",
          "s3:ListAllMyBuckets"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        Sid    = "S3WriteGroupPrefix"
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::team-*",
          "arn:aws:s3:::team-*/*"
        ]
      },
      {
        Sid    = "EC2InstanceConnect"
        Effect = "Allow"
        Action = [
          "ec2-instance-connect:SendSSHPublicKey"
        ]
        Resource = "arn:aws:ec2:eu-north-1:*:instance/*"
      },
      {
        Sid    = "SSMSessionManager"
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssm:GetConnectionStatus"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMDescribeInstances"
        Effect = "Allow"
        Action = [
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeDocument",
          "ssm:GetDocument",
          "ssm:ListDocuments"
        ]
        Resource = "*"
      },
      {
        Sid    = "FullECSAccess"
        Effect = "Allow"
        Action = [
          "ecs:*",
          "servicediscovery:ListNamespaces"
        ]
        Resource = "*"
      },
      {
        Sid    = "FullECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "NetworkingReadAccess"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "FullIAMAccess"
        Effect = "Allow"
        Action = [
          "iam:*",
          "iam:ListRoles"
        ]
        Resource = "*"
      },
      {
        Sid    = "RegionRestrictionDeny"
        Effect = "Deny"
        NotAction = [
          "iam:*",
          "cloudfront:*",
          "route53:*",
          "organizations:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = "eu-north-1"
          }
        }
      }
    ]
  })
}

# Attach custom policy to students group
resource "aws_iam_group_policy_attachment" "students_custom" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.students_custom.arn
}

# Attach AWS managed policy: ElasticLoadBalancingFullAccess
resource "aws_iam_group_policy_attachment" "students_elb" {
  group      = aws_iam_group.students.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

# Attach AWS managed policy: SecretsManagerReadWrite
resource "aws_iam_group_policy_attachment" "students_secrets" {
  group      = aws_iam_group.students.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Create 36 users
resource "aws_iam_user" "students" {
  count = 36
  name  = "tiim_${count.index + 1}"

  tags = {
    Group = "students"
    Type  = "student-account"
  }
}

# Add users to group
resource "aws_iam_user_group_membership" "students" {
  count = 36
  user  = aws_iam_user.students[count.index].name

  groups = [
    aws_iam_group.students.name
  ]
}

# Generate random passwords for each user
resource "random_password" "student_passwords" {
  count   = 36
  length  = 18
  special = true

  override_special = "!@%*()_+-=[]{}|:;<>,.?"

  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1

  keepers = {
    user = "tiim_${count.index + 1}"
  }
}

# Create login profiles using AWS CLI (workaround for provider limitation)
resource "null_resource" "create_login_profiles" {
  count = 36

  depends_on = [aws_iam_user.students]

  provisioner "local-exec" {
    command = <<-EOT
      aws iam create-login-profile \
        --user-name ${aws_iam_user.students[count.index].name} \
        --password '${random_password.student_passwords[count.index].result}' \
        --profile nava-admin \
        --region eu-north-1 2>/dev/null || \
      aws iam update-login-profile \
        --user-name ${aws_iam_user.students[count.index].name} \
        --password '${random_password.student_passwords[count.index].result}' \
        --profile nava-admin \
        --region eu-north-1
    EOT

    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws iam delete-login-profile --user-name ${self.triggers.username} --region eu-north-1 2>/dev/null || true"
  }

  triggers = {
    username = aws_iam_user.students[count.index].name
    password = random_password.student_passwords[count.index].result
  }
}

# Export credentials to CSV file
resource "local_file" "student_credentials" {
  filename = "${path.module}/student_credentials.csv"
  content = join("\n", concat(
    ["Username,Password,Console_URL"],
    [for i in range(36) :
      "${aws_iam_user.students[i].name},${random_password.student_passwords[i].result},https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
    ]
  ))

  file_permission = "0600"

  depends_on = [null_resource.create_login_profiles]
}

# Outputs
output "credentials_file" {
  value = "Credentials saved to: ${local_file.student_credentials.filename}"
}

output "students_group_name" {
  value = aws_iam_group.students.name
}

output "custom_policy_arn" {
  value = aws_iam_policy.students_custom.arn
}
