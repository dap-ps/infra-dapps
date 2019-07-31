# Description

This role configures a [MongoDB](https://www.mongodb.com/) container using the [`mongo`](ttps://hub.docker.com/_/mongo) Docker image.

# Configuration

```yaml
mongo_db_name: mydb
mongo_db_user: test
mongo_db_pass: test-user-password
```

# Backups

Setup of backups created via the [`mongodump`](https://docs.mongodb.com/manual/reference/program/mongodump/#bin.mongodump) utility.

The backups end up in:
```yaml
mongo_backup_path: '/var/tmp/backups'
```

# Known Issues

__TODO__
