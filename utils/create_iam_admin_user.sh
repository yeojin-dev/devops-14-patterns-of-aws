#!/usr/bin/env bash

USER_NAME=${1}
if [ "${USER_NAME}" == "" ]; then
    echo "USER_NAME is not set."
    exit 1
fi

echo "create a administrator user - ${USER_NAME}"
aws iam create-user --user-name ${USER_NAME} --output text > /dev/null

ADMIN_POLICY_NAME="arn:aws:iam::aws:policy/AdministratorAccess"
echo "attach ${ADMIN_POLICY_NAME} to ${USER_NAME}"
aws iam attach-user-policy --user-name ${USER_NAME} --policy-arn ${ADMIN_POLICY_NAME} --output text > /dev/null

aws iam list-attached-user-policies --user-name ${USER_NAME} --output text > /dev/null
aws iam create-access-key --user-name ${USER_NAME} | jq .
