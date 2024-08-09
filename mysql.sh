#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$0-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum module disable mysql -y &>>$LOGFILE
VALIDATE $? "Disabling mysql"

cp /home/centos/shellscript-for-terra-robo-project/mysql.repo /etc/yum.repos.d/mysql.repo
VALIDATE $? "Copying mysql.repo in to etc"

yum install mysql-community-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE
VALIDATE $? "Setting up root password"