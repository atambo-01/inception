#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
    
    while true; do
        # Use printf for reliable color output
        printf "Enter password for ${YELLOW}%s${NC}: " "$secret"
        stty -echo
        read pass
        stty echo
        printf "\n"  # Add newline after input
        if [ -n "$pass" ]; then
            break
        else
            printf "${RED}Error: password cannot be empty. Please try again.${NC}\n"
        fi
    done
    
    echo "$pass" > "$file"
    chmod 600 "$file"
    printf "${GREEN}✓ Saved to $file${NC}\n"
done