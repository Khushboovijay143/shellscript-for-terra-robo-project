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

# cd /etc/yum.repos.d/ &>>$LOGFILE
# VALIDATE $? "Moving into app directory"

# sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* &>>$LOGFILE
# VALIDATE $? "Adding mirrorlist"

# sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* &>>$LOGFILE
# VALIDATE $? "Adding baseurl and mirrorlist"

yum install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Installing python gcc and devel"
    
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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downloading payment artifact "

cd /app &>>$LOGFILE
VALIDATE $? "moving to app dir"

unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "unzipping payment artifact"

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Installing pip.6"

cp /home/centos/roboshop-shellscript/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "copying payment.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading payment service"

systemctl enable payment &>>$LOGFILE
VALIDATE $? "Enabling payment service"

systemctl start payment &>>$LOGFILE
VALIDATE $? "Starting payment service"