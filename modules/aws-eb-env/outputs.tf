/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
output "deploy_access_key" {
  value = "${aws_iam_access_key.deploy.id}"
}
output "deploy_secret_key" {
  value = "${aws_iam_access_key.deploy.encrypted_secret}"
}
*/
