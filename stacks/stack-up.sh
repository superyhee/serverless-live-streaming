#!/bin/bash

#PROFILE="--profile bluefin"

case $1 in
    vpc)
        aws cloudformation deploy \
        --template-file vpc.stack.yml \
        --stack-name video-streaming-vpc \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
        KeyPairName=video-streaming \
        ${PROFILE}
        ;;
    assets)
        aws cloudformation deploy \
        --template-file assets.stack.yml \
        --stack-name video-streaming-assets \
        --capabilities CAPABILITY_IAM \
        ${PROFILE}
        ;;
    proxy-dns)
        aws cloudformation deploy \
        --template-file proxy-dns.stack.yml \
        --stack-name video-streaming-proxy-dns \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
        Proxy1=$(aws ec2 describe-network-interfaces --network-interface-ids $(aws ecs describe-tasks --cluster video-streaming --tasks $(aws ecs list-tasks --cluster video-streaming --service-name video-streaming-proxy --query "taskArns" --output text ${PROFILE}) --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text ${PROFILE}) --query "NetworkInterfaces[0].Association.PublicIp" --output text ${PROFILE}) \
        ${PROFILE}
        ;;
    ecs)
        aws cloudformation deploy \
        --template-file ecs.stack.yml \
        --stack-name video-streaming-ecs \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
        Name=video-streaming \
        ${PROFILE}
        ;;
    ecs-ec2)
        aws cloudformation deploy \
        --template-file ecs-ec2.stack.yml \
        --stack-name video-streaming-ecs \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
        Name=video-streaming \
        ${PROFILE}
        ;;
    redis)
        aws cloudformation deploy \
        --template-file redis.stack.yml \
        --stack-name video-streaming-redis \
        --capabilities CAPABILITY_IAM \
        ${PROFILE}
        ;;
    security)
        aws cloudformation deploy \
        --template-file security.stack.yml \
        --stack-name video-streaming-security \
        --capabilities CAPABILITY_IAM \
        ${PROFILE}
        ;;
    dynamodb)
        aws cloudformation deploy \
        --template-file dynamodb.stack.yml \
        --stack-name video-streaming-dynamodb \
        --capabilities CAPABILITY_IAM \
        ${PROFILE}
        ;;
    efs)
        aws cloudformation deploy \
        --template-file efs.stack.yml \
        --stack-name video-streaming-efs \
        --capabilities CAPABILITY_IAM \
        ${PROFILE}
        ;;
    *)
        echo $"Usage: $0 {vpc|assets|proxy-dns|ecs|redis|security|dynamodb}"
        exit 1
esac