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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE
VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing NodeJS"
    
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


curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
VALIDATE $? "downloading cart artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving into app directory"

unzip /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "unzipping cart"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

# give full path of cart.service because we are inside /app
cp /home/centos/shellscript-for-terra-robo-project/cart.service /etc/systemd/system/cart.service &>>$LOGFILE
VALIDATE $? "copying cart.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl enable cart &>>$LOGFILE
VALIDATE $? "Enabling cart"

systemctl start cart &>>$LOGFILE
VALIDATE $? "Starting cart"