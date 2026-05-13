#!/bin/bash

# Verify stack directory is valid
if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Invalid or missing stack directory: $1"
    exit 1
fi

# Verify either "apply" or "destroy" was passed in
if [ -z "$2" ]; then
    echo "Usage: $0 {apply|destroy}"
    exit 1
elif [ "$2" != "apply" ] && [ "$2" != "destroy" ]; then
    echo "Invalid action: $2"
    echo "Usage: $0 {apply|destroy}"
    exit 1
fi


# $3 may be used to pass in a different tfvars file, else it will use dev.tfvars
if [ -z "$3" ]; then
    VARS_FILE="dev.tfvars"
else
    VARS_FILE=$3
fi

cd "$1" || exit 1

# Run the apply or destroy
if [ "$2" == "apply" ]; then
    terraform apply -var-file=$VARS_FILE
elif [ "$2" == "destroy" ]; then
    terraform destroy -var-file=$VARS_FILE -refresh=false
fi