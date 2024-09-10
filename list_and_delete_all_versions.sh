#!/bin/bash

# Check if VAULT_ADDR is set
if [ -z "$VAULT_ADDR" ]; then
  echo "Error: VAULT_ADDR environment variable is not set."
  exit 1
fi

# Check if VAULT_ROOT_TOKEN is set
if [ -z "$VAULT_ROOT_TOKEN" ]; then
  echo "Error: VAULT_ROOT_TOKEN environment variable is not set."
  exit 1
fi

# Check if the correct number of arguments is provided
if [ $# -lt 2 ]; then
  echo "Error: Not enough arguments. Usage: ./list_and_delete_all_versions.sh <list|delete> <path>"
  exit 1
fi

# Log in to Vault using the root token
vault login $VAULT_ROOT_TOKEN &> /dev/null

if [ $? -ne 0 ]; then
  echo "Error: Failed to authenticate with Vault using VAULT_ROOT_TOKEN."
  exit 1
fi

# Variables
operation=$1
provided_path=$2
logfile="vault_operation.log"

# Function to recursively list and delete all versions of keys
list_and_delete_recursive() {
  local path=$1
  # List keys at the current path
  keys=$(vault kv list -format=json $path | jq -r '.[]')

  for key in $keys; do
    # If the key ends with a "/", it is a folder; recurse into it
    if [[ $key == */ ]]; then
      echo "Folder: $path$key" | tee -a $logfile
      # Recursive call
      list_and_delete_recursive "$path$key"
    else
      if [ "$operation" == "list" ]; then
        # Just print the key when listing
        echo "Key: $path$key" | tee -a $logfile
      elif [ "$operation" == "delete" ]; then
        # Print and delete all versions of the secret
        echo "Deleting all versions of secret: $path$key" | tee -a $logfile
        vault kv metadata delete "$path$key" >> $logfile 2>> $logfile
      fi
    fi
  done
}

# Start the recursive listing or deletion from the provided path
if [ "$operation" == "list" ] || [ "$operation" == "delete" ]; then
  echo "Starting operation '$operation' on path '$provided_path/'..." | tee -a $logfile
  list_and_delete_recursive "$provided_path/"
else
  echo "Error: Invalid operation. Use 'list' or 'delete'." | tee -a $logfile
  exit 1
fi

# Log operation completion
if [ "$operation" == "delete" ]; then
  echo "Attempting to delete metadata for the provided folder: $provided_path" | tee -a $logfile
  vault kv metadata delete "$provided_path" >> $logfile 2>> $logfile
fi

echo "Operation '$operation' completed for path '$provided_path/'." | tee -a $logfile
