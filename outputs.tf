/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
 **/

output "smtp_access_key" {
  value = "${aws_iam_access_key.smtp.id}"
}
output "smtp_secret_key" {
  value = "${aws_iam_access_key.smtp.encrypted_secret}"
}

/**
 * This can be decrypted with:
 * echo $encrypted_secret | base64 --decode | keybase pgp 
 **/
