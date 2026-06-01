#!/usr/bin/env bash
for stack in cdn compute storage security network; do
  terraform -chdir=stacks/$stack destroy -var-file=dev.tfvars -auto-approve || break
done