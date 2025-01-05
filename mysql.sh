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

dnf install mysql-server -y  &>>$LOG_FILE_NAME
VALIDATE $?  "Installing MySQL Server"

systemctl enable mysqld  &>>$LOG_FILE_NAME
VALIDATE $? "Enabling MySql Server"

systemctl start mysqld  &>>$LOG_FILE_NAME
VALIDATE $? "Strating MySQL Server"


mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up root password"

