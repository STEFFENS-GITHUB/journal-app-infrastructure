#!/bin/bash

# $2 may be used to pass in a different tfvars file, else it will use dev.tfvars
if [ -z "$2" ]; then
    VARS_FILE="dev.tfvars"
else
    VARS_FILE=$2
fi

# Verify either "apply" or "destroy" was passed in
if [ -z "$1" ]; then
    echo "Usage: $0 {apply|destroy}"
    exit 1
elif [ "$1" != "apply" ] && [ "$1" != "destroy" ]; then
    echo "Invalid action: $1"
    echo "Usage: $0 {apply|destroy}"
    exit 1
fi

# Run the apply or destroy
if [ "$1" == "apply" ]; then
    terraform apply -var-file=$VARS_FILE
elif [ "$1" == "destroy" ]; then
    terraform destroy -var-file=$VARS_FILE -refresh=false
fi