#!/bin/bash

USERID=$(id -u) # checking is it root user or not

#colors added to the script
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


VALIDATE(){

 if [ $1 -ne 0 ] # again checking installation is success or not
    then 
        echo -e " $2 .... $R Failure $N "
        exit 1
    else
        echo -e " $2 .... $G Success $N "
    fi

}


CHECK_ROOT(){
if [ $USERID -ne 0 ] 
then 
    echo "ERROR:: you must have sudo access to execute script"
    exit 1 # other than exit 0 you can give any number "exit 0 means success"
fi
}

echo "script started executing at :: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling Existing NODEJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling NODEJS 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing NODEJS"

useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "ADDING EXPENSE user "

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? " CREATING APP Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? " Downloading Backend"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? " Unzip the Downloaded Backend code"


npm install &>>$LOG_FILE_NAME
VALIDATE $? " Installing Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#prepare mysql schema

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? " Installing MYSQL Client"

mysql -h mysql.telugustreetbyte.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? " Settingup the transactions schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon-Reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? " Enabling backend service"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? " Restarting Backend"
