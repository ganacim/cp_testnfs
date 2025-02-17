#!/bin/bash

# Default values
SERVER_PORT=50001
USE_UDP=false

# Help function
usage() {
    echo "Usage: $0 -s <server_ip> -p <port> -u -f <file_to_send>"
    echo "  -s   Server IP address (required)"
    echo "  -p   Port number (default: 50000)"
    echo "  -u   Use UDP instead of TCP (default: TCP)"
    echo "  -f   File to send (required)"
    exit 1
}

# Parse command-line arguments
while getopts ":s:p:uf:" opt; do
    case "${opt}" in
        s) SERVER_IP=${OPTARG} ;;
        p) SERVER_PORT=${OPTARG} ;;
        u) USE_UDP=true ;;
        f) FILE_TO_SEND=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check for required arguments
if [[ -z "$SERVER_IP" || -z "$FILE_TO_SEND" ]]; then
    usage
fi

# Start the server listener via SSH
echo "Starting listener on remote server ($SERVER_IP:$SERVER_PORT)..."
ssh -T "$SERVER_IP" <<EOF &
if $USE_UDP; then
    nc -u -l -p $SERVER_PORT > /dev/null
else
    nc -l -p $SERVER_PORT > /dev/null
fi
EOF

sleep 2  # Give the server time to start

# Start the client transfer
echo "Sending file '$FILE_TO_SEND' to $SERVER_IP:$SERVER_PORT..."
if $USE_UDP; then
    pv "$FILE_TO_SEND" | nc -q 0 -u "$SERVER_IP" "$SERVER_PORT"
else
    pv "$FILE_TO_SEND" | nc -q 0 "$SERVER_IP" "$SERVER_PORT"
fi

echo "File transfer completed!"
