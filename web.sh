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

yum install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing default html content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE
VALIDATE $? "Downloading roboshop-web artifact"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "moving in to default html"

unzip /tmp/web.zip &>>$LOGFILE
VALIDATE $? "Unziping the web artifacts"

cp /home/centos/roboshop-shellscript/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOGFILE
VALIDATE $? "copying roboshop.config file"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"