#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
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

yum install maven -y &>>$LOGFILE
VALIDATE $? "Installing Maven"

if [[ $USERIDROBO -ne 0 ]];
then
    echo -e "$R Roboshop already exist $N"
else
    useradd roboshop &>>$LOGFILE
    echo -e "$G Creating user Roboshop $N"
fi


if [ -d /app ];
then 
    echo -e "$R app already exist $N"
else
    mkdir /app &>>$LOGFILE
    echo -e "$G Creating app Directory $N"
fi

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
VALIDATE $? "Downloading shipping artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving to app directory"
 
unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "Unzipping shipping"

mvn clean package &>>$LOGFILE
VALIDATE $? "packaging shipping app"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "renaming shipping jar"

cp /home/centos/shellscript-for-terra-robo-project/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "copying shipping service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable shipping  &>>$LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Starting shipping"


yum install mysql -y  &>>$LOGFILE
VALIDATE $? "Installing MySQL client"

mysql -h mysql.vijaydeepak0812.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$LOGFILE
VALIDATE $? "Loaded countries and cities info"

systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Restarting shipping"