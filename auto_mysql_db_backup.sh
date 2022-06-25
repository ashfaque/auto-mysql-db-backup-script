#!/bin/sh

# A small shell script to backup / dump MySQL database daily at 11 pm using linux `crontab -e`.

# ? https://fedingo.com/how-to-run-shell-script-as-cron-job/

# Todo:  1st time run, generate bkup .sql, compress it with gzip / bzip2. Delete the bkup .sql, if 2 days ago named backup(eg. db_bkup_26_04_2022.gz) exists then only delete it else do nothing [also] check the creation date and delete it. Or First perform the 2 days back delete operation then perform the dump will save a lot of disk space.
# ? Test with a small DB. Will be faster.

sudo mysql -uroot -ppassword_here db_name > /home/username/Documents/db_backup.sql

# df -h on live = 85GB FREE, live db is 9 GB, we need 18 GB.
# What to write inside `crontab -e`, eg.,
# 0 18 * * * /home/USERNAME/dir/dir2/env/bin/python /home/USERNAME/dir/dir2/dj_proj_name/manage.py crontab run 7de5ce167d012c645bed8a3a997c7a29 >> /home/USERNAME/dir/dir2/dj_proj_name/profile_job.log

# already weekly happening in live where? how?
# ! after completing this, extract the gz archive then test on a server with root access / as a root user