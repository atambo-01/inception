#!/bin/bash
SECRETS_DIR="$HOME/.inception_secrets"
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

for secret in \
    db_root_password \
    db_password \
    wp_admin_password \
    wp_user_password ; 
do
    file="$SECRETS_DIR/$secret.txt"
    if [ ! -f "$file" ]; then
        echo -n "Enter password for $secret: "
        stty -echo; read pass; stty echo; echo
        echo "$pass" > "$file"
        chmod 600 "$file"
        echo "Saved to $file"
    else
        echo "$file already exists"
    fi
done