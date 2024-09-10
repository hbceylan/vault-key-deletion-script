# Vault Key Deletion Script

This script is designed to recursively list or delete all keys and their versions from a Vault Key-Value (KV) v2 secrets engine path. It allows two operations:

1. **List**: Displays all keys and folders under the provided path.
2. **Delete**: Deletes all versions of keys and folders, including metadata.

All output (including errors) is saved to a log file (`vault_operation.log`).

## Prerequisites

Before using this script, ensure the following:

- **Vault CLI**: You must have the Vault CLI installed on your system.
- **Vault Server**: Ensure your Vault server is running and accessible.
- **Environment Variables**: The script depends on the following environment variables:
  - `VAULT_ADDR`: The address of your Vault server (e.g., `https://vault.example.com:8200`).
  - `VAULT_ROOT_TOKEN`: The root token for authenticating with Vault.

## Usage

### 1. Set Environment Variables

Ensure that both `VAULT_ADDR` and `VAULT_ROOT_TOKEN` environment variables are set:

```bash
export VAULT_ADDR='https://vault.example.com:8200'
export VAULT_ROOT_TOKEN='s.YOUR_ROOT_TOKEN_HERE'
```

### 2. Run the Script
You can run the script by providing two arguments:

  1. **Operation:** list or delete (to list or delete keys).
  2. **Path:** The Vault KV v2 path where the secrets are located.

```bash
./list_and_delete_all_versions.sh <list|delete> <path>
```

**Example:**
To **list** all folders and keys under the `path/` path:

```bash
./list_and_delete_all_versions.sh list path
```

To **delete** all versions of keys and folders under the `path/` path:
```bash
./list_and_delete_all_versions.sh delete path
```

### 3. Log File

All output (including any errors) is saved to a log file named `vault_operation.log`. This includes both the standard output and error messages from the script.

### Script Behavior

- **List Operation**: Recursively lists all keys and folders under the specified path and outputs them to both the terminal and the log file.
- **Delete Operation**: Recursively deletes all keys and their versions under the specified path, including their metadata. The folder itself is also deleted.
  
The log file (`vault_operation.log`) records both successful operations and any errors that occur during the process.

### Example Log Output:

#### For a `list` operation:

```bash
Starting operation 'list' on path 'path/'...
Folder: path/subfolder1/
Key: path/subfolder1/key1
Key: path/subfolder1/key2
Folder: path/subfolder2/
Key: path/subfolder2/key3
Operation 'list' completed for path 'path/'.
```
#### For a `delete` operation:

```bash
Starting operation 'delete' on path 'path/'...
Folder: path/subfolder1/
Deleting all versions of secret: path/subfolder1/key1
Deleting all versions of secret: path/subfolder1/key2
Folder: path/subfolder2/
Deleting all versions of secret: path/subfolder2/key3
Attempting to delete metadata for the provided folder: path
Operation 'delete' completed for path 'path/'.
```

## Error Handling

- **Environment Variables**: The script will exit with an error if `VAULT_ADDR` or `VAULT_ROOT_TOKEN` are not set.
- **Vault Login**: If the Vault login using `VAULT_ROOT_TOKEN` fails, the script will exit.
- **Invalid Path**: If the provided path does not exist in Vault, the script will log an error.
- **Log File**: Any errors encountered during the `list` or `delete` operations will be logged to `vault_operation.log`.

### Common Issues:

- If Vault reports that the path doesn't exist, ensure that the provided path is correct and corresponds to a KV v2 mount.
- If some keys or folders are not being deleted, ensure that you have the necessary permissions to perform deletion on all subpaths.

## License

This script is provided as-is and is intended for use with HashiCorp Vault.
