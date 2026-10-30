# =============================================================================
# Bedrock instance: point ~/.ssh/config at the new public IP after a Start
# =============================================================================

# Steps A6 and A7 of BEDROCK_INSTANCE_DAILY.md in one command.
#   bedrock-ip 3.25.10.42   use the address given
#   bedrock-ip              use the address on the clipboard (copied with the console's ⧉ icon)
bedrock-ip() {
    local ip="${1:-$(pbpaste)}"
    ip="${ip//[[:space:]]/}"

    if [[ ! "$ip" =~ '^([0-9]{1,3}\.){3}[0-9]{1,3}$' ]]; then
        print -u2 "bedrock-ip: '$ip' is not an IPv4 address."
        print -u2 "Copy the Public IPv4 address from the EC2 console, then run: bedrock-ip <address>"
        return 1
    fi
    local octet
    for octet in ${(s:.:)ip}; do
        if (( octet > 255 )); then
            print -u2 "bedrock-ip: '$ip' has an octet above 255."
            return 1
        fi
    done

    sed -i.bak "/^Host bedrock-dev$/,/^Host /s/^  HostName .*/  HostName $ip/" ~/.ssh/config || return 1
    command grep -A2 '^Host bedrock-dev' ~/.ssh/config

    if ! command grep -qE "^  HostName $ip\$" ~/.ssh/config; then
        print -u2 "bedrock-ip: the HostName line was not updated; ~/.ssh/config.bak holds the previous version."
        return 1
    fi

    print "Testing SSH..."
    ssh -o ConnectTimeout=10 bedrock-dev 'echo connected; hostname'
}
