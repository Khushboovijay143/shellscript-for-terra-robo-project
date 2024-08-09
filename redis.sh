#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$0-$DATE.log
USERID=$(id -u)
USERIDROBO=$(id -u roboshop)

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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE
VALIDATE $? "Installing Redis repo"

yum module enable redis:remi-6.2 -y &>>$LOGFILE
VALIDATE $? "Enabling redis-6.2"

yum install redis -y &>>$LOGFILE
VALIDATE $? "Install redis"

sed -i 's/127.0.0.0/0.0.0.0/g'  /etc/redis.conf /etc/redis/redis.conf &>>$LOGFILE
VALIDATE $? "replacing 127.0.0.0 to 0.0.0.0 in redis.conf"

systemctl enable redis &>>$LOGFILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOGFILE
VALIDATE $? "starting redis"