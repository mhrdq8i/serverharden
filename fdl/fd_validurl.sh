#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to start download with valid link
curl_req() {
    local vurl="$1"
    local req=$(curl -scL "$vurl" -o /tmp/`date +%A%d%b%y-%H%M%S`)
}

# Function to check if a URL is valid
is_valid_url() {
    local url="$1"
    local http_code=`curl -Is "$url" -o /dev/null -w '%{http_code}'`
    [[ "$http_code" -eq 200 || "$http_code" -eq 302 ]]
}

# Read the file line by line and search for a valid URL
while IFS= read -r url; do
    if is_valid_url "$url"; then
	valid_url="$url"
	echo "valid URL is: $valid_url"
	curl_req "$valid_url"
        exit 0
    elif ! is_valid_url "$url"; then
	continue	
    fi
done < "$script_dir/urls.txt"

echo "No valid URL found"

