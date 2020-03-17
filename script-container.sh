#!/bin/bash

# Change directory to app-directory
cd $(dirname $0)

# Takes 3 arguments and returns the first one that is not null
function set_value (){
	[[ ! -z $1 ]] && echo $1 || ([[ ! -z $2 ]] && echo $2 || echo $3)
}

CONTAINER_NAME="flare-git-push"

GIT_REMOTE_USER_NAME_DEFAULT=""
GIT_REMOTE_USER_NAME_GENERAL=$(yq r cibr-config.yml git.remote.user.name)
GIT_REMOTE_USER_NAME_CONTAINER=$(yq r cibr-config.yml $CONTAINER_NAME.git.remote.user.name)
GIT_REMOTE_USER_NAME=$(set_value $GIT_REMOTE_USER_NAME_CONTAINER $GIT_REMOTE_USER_NAME_GENERAL $GIT_REMOTE_USER_NAME_DEFAULT)

GIT_REMOTE_USER_EMAIL_DEFAULT=""
GIT_REMOTE_USER_EMAIL_GENERAL=$(yq r cibr-config.yml git.remote.user.email)
GIT_REMOTE_USER_EMAIL_CONTAINER=$(yq r cibr-config.yml $CONTAINER_NAME.git.remote.user.email)
GIT_REMOTE_USER_EMAIL=$(set_value $GIT_REMOTE_USER_EMAIL_CONTAINER $GIT_REMOTE_USER_EMAIL_GENERAL $GIT_REMOTE_USER_EMAIL_DEFAULT)

GIT_REMOTE_BRANCH_DEFAULT="master"
GIT_REMOTE_BRANCH_GENERAL=$(yq r cibr-config.yml git.remote.branch)
GIT_REMOTE_BRANCH_CONTAINER=$(yq r cibr-config.yml $CONTAINER_NAME.git.remote.branch)
GIT_REMOTE_BRANCH=$(set_value $GIT_REMOTE_BRANCH_CONTAINER $GIT_REMOTE_BRANCH_GENERAL $GIT_REMOTE_BRANCH_DEFAULT)

GIT_REMOTE_SERVER_DEFAULT="github.com"
GIT_REMOTE_SERVER_GENERAL=$(yq r cibr-config.yml git.remote.server)
GIT_REMOTE_SERVER_CONTAINER=$(yq r cibr-config.yml $CONTAINER_NAME.git.remote.server)
GIT_REMOTE_SERVER=$(set_value $GIT_REMOTE_SERVER_CONTAINER $GIT_REMOTE_SERVER_GENERAL $GIT_REMOTE_SERVER_DEFAULT)

GIT_REMOTE_REPOSITORY_DEFAULT=""
GIT_REMOTE_REPOSITORY_GENERAL=$(yq r cibr-config.yml git.remote.repository)
GIT_REMOTE_REPOSITORY_CONTAINER=$(yq r cibr-config.yml $CONTAINER_NAME.git.remote.repository)
GIT_REMOTE_REPOSITORY=$(set_value $GIT_REMOTE_REPOSITORY_CONTAINER $GIT_REMOTE_REPOSITORY_GENERAL $GIT_REMOTE_REPOSITORY_DEFAULT)

# Set up SSH
mkdir -p /root/.ssh/
cp id_rsa* /root/.ssh/.
ssh-keyscan $GIT_REMOTE_SERVER > /root/.ssh/known_hosts

# Run container task
git config --global user.name $GIT_REMOTE_USER_NAME
git config --global user.email $GIT_REMOTE_USER_EMAIL
git clone git@$GIT_REMOTE_SERVER:$GIT_REMOTE_REPOSITORY
cd $(awk -F. '{print $1}' <<< $(awk -F/ '{print $NF}' <<< $GIT_REMOTE_REPOSITORY))
git checkout $GIT_REMOTE_BRANCH
git pull
echo $(date) >> date.log
git add .
git commit -m "Add"
git push

# Remove .ssh directory for security purposes
rm -rf /root/.ssh/