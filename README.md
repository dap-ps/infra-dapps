# Description

This repo configures infrastructure for the https://dap.ps/ service.

The service is split into two stages:

| Stage | With CDN | Without CDN |
|-|-|-|
| __`prod`__ | https://prod.dap.sp/ | https://raw.prod.dap.sp/ |
| __`dev`__  | https://dev.dap.ps/  | https://raw.dev.dap.sp/ |

The `prod` environment is `CNAME`ed to `dap.ps` domain.

# Technical Details

## Site

The infrastructure is hosted on AWS and consists of 5 main elements:

* [__ELB__](https://aws.amazon.com/elasticloadbalancing/) - Load balancers
* [__EB__](https://aws.amazon.com/elasticbeanstalk/) - Node.js App hosting
* [__EC2__](https://aws.amazon.com/ec2/) - [MongoDB](https://www.mongodb.com/) cluster
* [__S3__](https://aws.amazon.com/s3/) - [MongoDB](https://www.mongodb.com/) backups & [Terraform](https://www.terraform.io/) state
* [__SES__](https://aws.amazon.com/ses/) - Mail forwarding
* [__CF__](https://aws.amazon.com/cloudfront/) - [CDN](https://en.wikipedia.org/wiki/Content_delivery_network)
* [__R53__](https://aws.amazon.com/route53/) - Route53 DNS

All the AWS parts are provisioned and managed with [Terraform](https://www.terraform.io/) and the MongoDB cluster configured with [Ansible](https://www.ansible.com/).

The `dap.ps` domain is registered via [Gandi](https://www.gandi.net/) DNS provider and is managed with AWS [Route53](https://aws.amazon.com/route53/) [Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) by changing the Name Servers with help from Gandi support. See `dns.tf` for more details.

## EMail

There are no mailboxes for `dap.ps` domain. We forward emails using AWS Lambda and AWS SES. You can change the forwarding rules by editing the `defaultConfig` object in [`files/sesforwarder.js`](files/sesforwarder.js).

# Usage

Creation of both `dev` and `prod` stages is as simple as:
```
terraform init
terraform apply
```
And then configure the MongoDB hosts using ansible:
```
ansible-playbook ansible/dev.yml
ansible-playbook ansible/prod.yml
```

# Known Issues

* The ElasticBeanstalk environments can fail when being recreated
  - This is mostly due to AWS being slow at destorying resources and their race conditions
* There is no easy way of making ElasticBeanstalk spread geographically
  - The only way seems to have multiple EB environments linked via ELB

# TODO

* [#4](https://github.com/dap-ps/infra-dapps/issues/4) - [prod] Geographically spread hosts
* [#11](https://github.com/dap-ps/infra-dapps/issues/11) - [prod] MongoDB Web UI
* [#13](https://github.com/dap-ps/infra-dapps/issues/13) - [prod] Stress test infrastructure

# Links

These helped me during work on this setup:

* https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html
* https://aws.amazon.com/getting-started/tutorials/deploy-app-command-line-elastic-beanstalk/
* https://medium.com/@vygandas/how-to-deploy-your-nodejs-app-on-amazon-elastic-beanstalk-aws-eb-with-circleci-short-tutorial-d8210d2a7f0c
* https://realpython.com/deploying-a-django-app-to-aws-elastic-beanstalk/
