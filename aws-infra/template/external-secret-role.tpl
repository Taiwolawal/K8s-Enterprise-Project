{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRoleWithWebIdentity"],
      "Effect": "Allow",
      "Principal": {
          "Federated": "${eks_provider_arn}"
        }
    }
  ]
}