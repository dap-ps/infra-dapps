# Description

This repo configures infrastructure for the https://dap.ps/ service.

The service is split into two stages:

* __`prod`__ - https://prod.dap.sp/
* __`dev`__ - https://dev.dap.ps/

The `prod` environment is `CNAME`ed to `dap.ps` domain.

# Technical Details

The infrastructure is hosted on AWS and consists of 5 main elements:

* [__ELB__](https://aws.amazon.com/elasticloadbalancing/) - Load balancers
* [__EB__](https://aws.amazon.com/elasticbeanstalk/) - Node.js App hosting
* [__EC2__](https://aws.amazon.com/ec2/) - [MongoDB](https://www.mongodb.com/) cluster
* [__S3__](https://aws.amazon.com/s3/) - [MongoDB](https://www.mongodb.com/) backups & [Terraform](https://www.terraform.io/) state
* [__SES__](https://aws.amazon.com/ses/) - Mail forwarding

All the AWS parts are provisioned and managed with [Terraform](https://www.terraform.io/) and the MongoDB cluster configured with [Ansible](https://www.ansible.com/).

The only part that is not AWS is [Gandi](https://www.gandi.net/) DNS provider due to AWS [Route53](https://aws.amazon.com/route53/) not supporting the `.ps` [TLD](https://en.wikipedia.org/wiki/Top-level_domain).

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
* [#10](https://github.com/dap-ps/infra-dapps/issues/10)  - [prod] Periodic EC2 Snapshots
* [#11](https://github.com/dap-ps/infra-dapps/issues/11)  - [prod] MongoDB Web UI
* [#13](https://github.com/dap-ps/infra-dapps/issues/13)  - [prod] Stress test infrastructure
