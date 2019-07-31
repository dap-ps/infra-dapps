/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
 **/

//output "s3_access_key" {
//  value = "${aws_iam_access_key.mongodb_backup.id}"
//}
//output "s3_secret_key" {
//  value = "${aws_iam_access_key.mongodb_backup.encrypted_secret}"
//}

/**
 * This can be decrypted with:
 * echo $encrypted_secret | base64 --decode | keybase pgp 
 **/
