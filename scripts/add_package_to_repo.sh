#!/bin/bash
REPO_BASE=/var/www/repos/apt/ubuntu
USER=`whoami`
if ([ ! $1 ] || [ ! $2 ] || [ $3 ]); then
        echo "invalid arguments"
        exit 1
fi

FILE=$1
FILE_PATH=`dirname $FILE`
FILE=`basename $FILE`
if [ ! -f $FILE_PATH/$FILE ]; then
        echo "$FILE_PATH/$FILE file not found"
        exit 1
fi

HOST=$2
HOST_CMD="host $HOST"
echo "$HOST_CMD"
$HOST_CMD
if [ $? -ne  0 ]; then
    exit 1
fi

RSYNC_CMD="rsync -avP $FILE_PATH/$FILE $HOST:~/$FILE"
echo "$RSYNC_CMD"
$RSYNC_CMD
if [ $? -ne  0 ]; then
    echo "problem with the file transfer"
    exit 1
fi

ssh -t $HOST <<EOF

if [ -f $REPO_BASE/$FILE ]; then
        echo "$REPO_BASE/$FILE already exists"
        exit 1
else
    echo "copying $FILE to $REPO_BASE"
        sudo cp ~/$FILE $REPO_BASE/
fi

echo "adding file to repo..."
echo "sudo reprepro -Vb $REPO_BASE --gnupghome /etc/pki includedeb lucid $REPO_BASE/$FILE"
sudo reprepro -Vb $REPO_BASE --gnupghome /etc/pki includedeb lucid $REPO_BASE/$FILE
if [ $? -ne 0 ]; then
        echo "reprepro exited nonzero"
        exit 1
fi

exit
EOF

exit
