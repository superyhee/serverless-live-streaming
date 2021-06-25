#!/bin/bash

#PROFILE="--profile bluefin"

case $1 in
    ecr)
        aws cloudformation deploy \
        --template-file ecr.stack.yml \
        --stack-name video-streaming-processor-ecr \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
        RepositoryName=video-streaming-processor \
        ${PROFILE}
        ;;
    service)
        aws cloudformation deploy \
        --template-file service.stack.yml \
        --stack-name video-streaming-processor \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
        Version=1.0.15 \
        DesiredCount=1 \
        RedisStack=video-streaming-redis \
        ${PROFILE}
        ;;

    service-cn)
        aws cloudformation deploy \
        --template-file service.stack-cn.yml \
        --stack-name video-streaming-processor \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
        Version=1.0.15 \
        DesiredCount=1 \
        RedisStack=video-streaming-redis \
        ${PROFILE}
        ;;
    *)
        echo $"Usage: $0 {ecr|service-}"
        exit 1
esac