# Description

This role configures a cron job for making MongoDB dumps and uploading them to S3.

# Management

You can see existing dump/backup jobs using `systemctl`
```
admin@node-01.us-east-1a.db.prod:~ % sudo systemctl list-timers '*-mongod.timer'
NEXT                         LEFT     LAST PASSED UNIT                ACTIVATES
Wed 2020-04-01 00:00:00 UTC  15h left n/a  n/a    backup-mongod.timer backup-mongod.service
Wed 2020-04-01 00:00:00 UTC  15h left n/a  n/a    dump-mongod.timer   dump-mongod.service

2 timers listed.
```
And run one by hand:
```
admin@node-01.us-east-1a.db.prod:~ % sudo systemctl start dump-mongod.service
admin@node-01.us-east-1a.db.prod:~ % sudo journalctl -fu dump-mongod.service
-- Logs begin at Sun 2019-11-03 12:25:35 UTC. --
systemd[1]: Starting MongoDB dump job...
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.923+0000        dumping up to 3 collections in parallel
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.926+0000        writing prod-dap-ps.dappsmetadatas to
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.927+0000        writing prod-dap-ps.dappsimages to
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.927+0000        writing prod-dap-ps.media to
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.992+0000        done dumping prod-dap-ps.media (78 documents)
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.993+0000        done dumping prod-dap-ps.dappsimages (119 documents)
prod_dap_ps_dump.sh[17215]: 2020-03-31T08:55:55.994+0000        done dumping prod-dap-ps.dappsmetadatas (149 documents)
prod_dap_ps_dump.sh[17215]: tar: Removing leading `/' from member names
systemd[1]: Started MongoDB dump job.
```
