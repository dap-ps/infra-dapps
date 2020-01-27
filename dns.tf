/* DNS ------------------------------------*/

/** WARNING: The .ps TLD has special status.
 * Its registration took extra long time when it was purchased.
 * It required help from Gandi support to change the nameservers to AWS ones.
 * Make changes to it on Gandi side with that in mind.
 **/

/* Configure managing domain with Route53 Hosted Zone */
resource "aws_route53_zone" "dap_ps" {
  name    = "dap.ps"
  comment = "Domain for Dapp Discovery website."
}
