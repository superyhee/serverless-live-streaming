#!/bin/bash
: ${REGION:=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')}
: ${ACCOUNT_ID:=$(aws sts get-caller-identity|jq -r ".Account")}
###########################################################
###########                                     ###########
###########################################################


logger() {
  LOG_TYPE=$1
  MSG=$2

  COLOR_OFF="\x1b[39;49;00m"
  case "${LOG_TYPE}" in
      green)
          # Green
          COLOR_ON="\x1b[32;01m";;
      blue)
          # Blue
          COLOR_ON="\x1b[36;01m";;
      yellow)
          # Yellow
          COLOR_ON="\x1b[33;01m";;
      red)
          # Red
          COLOR_ON="\x1b[31;01m";;
      default)
          # Default
          COLOR_ON="${COLOR_OFF}";;
      *)
          # Default
          COLOR_ON="${COLOR_OFF}";;
  esac

  TIME=$(date +%F" "%H:%M:%S)
  echo -e "${COLOR_ON} ${TIME} -- ${MSG} ${COLOR_OFF}"
#  echo -e "${TIME} -- ${MSG}" >> "${LOG_OUTPUT}"
}

errorcheck() {
   if [ $? != 0 ]; then
          logger "red" "Unrecoverable generic error found in function: [$1]. Check the log. Exiting."
      exit 1
   fi
}

welcome() {
  logger "red" "*****************intall proxy server********************************"
  logger "green" "These are the environment settings that are going to be used:"
  logger "yellow" "AWS Region   : $REGION"
  logger "yellow" "Account ID   : $ACCOUNT_ID"
}

get-login()
{
if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]]; 
      then 
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com.cn  

      else
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
fi
 
}

build()
{
  docker build -t video-streaming-proxy ../  
}

tag()
{
      logger "red" "*****************tag********************************"
    if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]]; 
      then 
 docker tag video-streaming-proxy $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com.cn/video-streaming-proxy:latest   

      else
 docker tag video-streaming-proxy $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/video-streaming-proxy:latest   
fi
}

push()
{
          logger "red" "*****************push********************************"

if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]]; 
      then 
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com.cn/video-streaming-proxy:latest  

      else
  docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/video-streaming-proxy:latest  

fi
}

ecr()
{
logger "red" "*****************create ecr********************************"

 ./stack-up.sh ecr   
}

service()
{

 logger "red" "*****************create service********************************"

if [[ $REGION = "cn-northwest-1" ]] || [[ $REGION = "cn-north-1" ]];
      then
 ./stack-up.sh service-cn
      else
 ./stack-up.sh service
fi

}

all() { 
welcome
get-login
# build
tag
push
service
}

case $1 in
    welcome)
    welcome
    ;;
    get-login)
    get-login
    ;;
    build)
    build
     ;;
    tag)
    tag
    ;;
    push)
    push
     ;;
    service)
    service
        ;;
    all)
    all
        ;;
    *)
        echo $"Usage: $0 {get-login|build|tag|push|service|}"
        exit 1
esac