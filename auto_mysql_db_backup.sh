#!/bin/sh


# * ####################### * #
# * Author : Ashfaque Alam  * #
# * Date : June 25, 2022    * #
# * ####################### * #

# ! Give executable permission : sudo chmod +x auto_mysql_db_backup.sh

# ? A shell script to which can be run with a crontab. Can take a dump of the entire MySQL database.

# * If ran will 1st delete 2 days older dump archive. Then it will generate a dump in .sql format. Then will compress with the 
# * compression method(bzip2 / gzip) declared in the variable and delete the .sql file. 

# ! Free disk space of twice the size of the database will be needed for this script to work properly. Check it with `df -h`

# ? Check the size of DB with this RDBMS SQL query :-
# SELECT table_schema AS "Database", 
# ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" 
# FROM information_schema.TABLES 
# GROUP BY table_schema;


# ? VARIABLES DECLARATION :-
file_name="db_backup"
archive_type="bzip2"    # ! Options:- bzip2 / gzip / sql
working_dir="/home/$USER/Documents/test"
msql_username="root"
mysql_password="password_here"
mysql_db_name="db_name"

# mkdir -p "$working_dir"    # This will create the dir, if it doesn't exists. But if `$working_dir` is not a dir but a file and it exists. Then we will have a problem. So to solve this, I wrote this code below.
# ? If the working directory doesn't exists it will create one. If another file exists with the same name then it will create the dir with `_DB_BKUP` as a suffix.
if [[ ! -e "$working_dir" ]]; then
    mkdir -p "$working_dir"
elif [[ ! -d "$working_dir" ]]; then
    working_dir+="_DB_BKUP"
    mkdir -p "$working_dir"
fi


# ? https://unix.stackexchange.com/a/155185#
# The code below finds file modified 2 days ago and deletes all of them at once. But we want to just delete the dumps archive.
#  /usr/bin/find /home/username/Documents -type f -mtime +2 -exec rm -f {} +

# ? Settings file extension, which willbe deleted.
case "$archive_type" in
*"bzip2"*)
    extension_to_check=".bz2"
    ;;
*"gzip"*)
    extension_to_check=".gz"
    ;;
*"sql"*)
    extension_to_check=".sql"
    ;;
*)
    ;;
esac

# ? Settings file name pattern, which will be deleted.
file_name_pattern="$file_name"+"_"

# ? Deleting those files which are older than 2 days from current date, whose file name contains `$file_name_pattern` and whose extension is `$extension_to_check`.
for file in $(/usr/bin/find "$working_dir" -type f -mtime +2)    # Fetches those files which are modified 2 or more days ago.
do
    case "$file" in
    *"$file_name_pattern"*)
        filename=${file##*/}
        # echo "$filename"
        case "$filename" in
        *"$extension_to_check"*)
            rm -f "$file"
            ;;
        *)          # Default case
            ;;
        esac
        ;;
    *)          # Default case
        ;;
    esac
done


# This code below finds files modified 2 or more days ago.
# /usr/bin/find /home/username/Documents -type f -mtime +2


# Create file with custom last modification date, for testing purpose with:-
# touch -d '15 Feb 2020' db_backup_15_02_2020.sql.bz2 db_backup_15_02_2020.sql.gz db_backup_15_02_2020.sql

# ? https://www.cyberciti.biz/faq/unix-linux-getting-current-date-in-bash-ksh-shell-script/
today_date=$(date +'%d_%m_%Y_%H_%M_%S')    # eg., O/P:- 25_06_2022_23_32_55


# ? Creating a MySQL dump.
# mysql -u"$msql_username" -p"$mysql_password" "$mysql_db_name" > "$working_dir"+"/"+"$file_name"+"_"+"$today_date".sql
mysqldump -u"$msql_username" -p"$mysql_password" "$mysql_db_name" > "$working_dir"+"/"+"$file_name"+"_"+"$today_date".sql


# ? Performing compression on the dump created above to save disk space.
case "$archive_type" in
*"bzip2"*)
    bzip2 -fqz "$working_dir"+"/"+"$file_name"+"_"+"$today_date".sql    # Also deletes the original file. To keep the original file use the `-k` option. -q –> quiet , -f ->force, -v -> verbose.
    ;;
*"gzip"*)
    gzip -fq "$working_dir"+"/"+"$file_name"+"_"+"$today_date".sql
    ;;
*"sql"*)
    ;;
*)
    ;;
esac

# * From my personal experience I concluded that, bzip2 is slower but provides better compression i.e., smaller file size. 
# * gzip is faster but provides mediocre compression i.e., slightly larger file size compared to bzip2.
# * Even though the decompression speed and output file quality (which is exactly same as original file) is same for both compression methods.
# * Tested on a .sql dump file of size, 517 MB. bzip2 was able to produce an archive of 44 MB and gzip produced archive of 66 MB.

# ? To decompress use this command:-
# bzip2/gzip -dv /full_path_here/db_backup_25_06_2022.sql.bz2/gz

# ? To import the .sql file use this command:-
# mysql -uroot -ppassword_here new_db < /home/$USER/Documents/test/db_backup_25_06_2022.sql


# ? Steps to run this script with `crontab -e` in GNU/LINUX.
# https://fedingo.com/how-to-run-shell-script-as-cron-job/
# crontab -e
# ? add this line below in it:-
# 0 1 * * * sudo /full_path_here/auto_mysql_db_backup.sh >> /home/$USER/log/auto_mysql_db_backup.log 2>&1    # If you want to save a log.
# 0 1 * * * sudo /full_path_here/auto_mysql_db_backup.sh >/dev/null 2>&1    # If you don't want to log

#? Crontab commands:-
# crontab -l = List cron tables
# crontab -e = create a new cron table.
# crontab -r = removes a cron table and all cron scheduled jobs.




# ----------
# ARCHIVES:-
# ----------
# Limitation of this code is it will only delete the file whose `file name == 2 days back date`.
# two_days_back_date=$(date -d '-2 day' '+%d_%m_%Y')
# echo "$two_days_back_date"
# if [ -e /home/$USER/Documents/test/db_backup_"$two_days_back_date".sql ]
# then
    # rm -f /home/$USER/Documents/test/db_backup_"$two_days_back_date".sql
# fi
