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

yum install golang -y &>>$LOGFILE
VALIDATE $? "Installing golang"
    
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

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
VALIDATE $? "Downloading the dispatch artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving to app dir"

unzip /tmp/dispatch.zip &>>$LOGFILE
VALIDATE $? "Unziping the dispatch artifact"

go mod init dispatch &>>$LOGFILE && go get &>>$LOGFILE && go build &>>$LOGFILE
VALIDATE $? "Building the dispatch artifact using go command"

cp /home/centos/shellscript-for-terra-robo-project/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE
VALIDATE $? "copying dispatch.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloadding dispatch.service"

systemctl enable dispatch &>>$LOGFILE
VALIDATE $? "Enabling dispatch.service"

systemctl start dispatch &>>$LOGFILE
VALIDATE $? "Starting dispatch.service"