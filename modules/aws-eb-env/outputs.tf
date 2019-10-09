/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
 **/

output "deploy_access_key" {
  value = "${aws_iam_access_key.deploy.id}"
}

output "deploy_secret_key" {
  value = "${aws_iam_access_key.deploy.encrypted_secret}"
}

/**
 * This can be decrypted with:
 * echo $encrypted_secret | base64 --decode | keybase pgp 
 **/

output "elb_names" {
  value = module.eb_environment.load_balancers
}

output "elb_fqdns" {
  value = [for elb in data.aws_elb.main: elb.dns_name]
}
