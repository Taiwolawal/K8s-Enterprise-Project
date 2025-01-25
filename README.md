# K8s-Enterprise-Project

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRoleWithWebIdentity"],
      "Effect": "Allow",
      "Principal": {
          "Federated": "${eks_oid_provider_arn}"
        }
    }
  ]
}