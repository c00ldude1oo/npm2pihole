#!/usr/bin/env bash
sleep 1
n=0
ip=$NPM_IP
usftp=$USE_SFTP
sip=$SFTP_IP
declare -a domains1
declare -a domains2
echo $(date) - Starting
#checks if using sftp
if "$usftp"; then
    echo $(date) - Using sftp to get dns list
    # checks if ssh key has been made
    if [ ! -f /root/.ssh/id_rsa ]; then
        # generate ssh key
        ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa
        touch INSTALL_SSH_KEY
        echo $(date) - install ssh key and restart container. run ssh-copy-id -i ssh/id_rsa "$sip"
        exit 1
    fi
    # make sure the host is known so sftp wont have a user prompt
    ssh -o StrictHostKeyChecking=accept-new "$sip" echo hi
    echo true
else
    echo Not using sftp to get dns list
    if [ ! -f /app/custom.list ]; then echo $(date) - "Please make sure piholes local dns file(custom.list) is mounted" && exit; fi
fi
# Gets file from remote pihole using sftp
getsftp() {
    echo $(date) - getting dns list
    sftp "$sip":/etc/pihole <<EOF
get custom.list
EOF
}
# Puts file from remote pihole using sftp
putsftp() {
    echo $(date) - Uploading new dns list
    sftp "$sip":/etc/pihole <<EOF
rename custom.list custom.list.bak
put custom.list
EOF
}
# Checks to pihole custom dns list if the domain is set
checkdnsfile() {
    #makes sure input is not empty
    if [ "$1" == "" ]; then
        echo $(date) - "Missing <domain>"
        return 1
    fi
    echo $(date) - Checking \""$*"\"
    domain=$1
    checkdns() {
#dev        echo Checkdns input is \""$*"\"
#dev        echo test \""$1"\" - \""$2"\"
        if [ "$domain" == "$2" ]; then
            if [ "$ip" == "$1" ]; then
                echo $(date) - Found
            else
                # Found but IP doesnt match
                echo $(date) - Setting IP. Was "$1"
                #filters out the wrong listing
                grep -v "$1 $2" custom.list >>list
                # adds to correct one
                echo $(date) - "$ip" "$domain" >>list
                # renames it back
                cat list >custom.list
                # removes copy
                rm list
                # adds to the counter for total edited domains
                n=$((n + 1))
            fi
        else
            # not in pihole records
            echo $(date) - Not found adding.
            # adds IP and domain to file
            echo $(date) - "$ip" "$domain" >>custom.list
            # adds to the counter for total edited domains
            n=$((n + 1))
        fi
        echo
    }
    test=$(grep " $domain\$" custom.list)
    checkdns $test
}
main() {
#dev    echo Starting Check
    domains1=()
    # reads all the files in npm and gets the domains out of them then formats and puts them in the array
    for file in npm/*; do domains1+=("$(grep "server_name" "$file" | sed "s/  server_name //; s/;//")"); done
#dev   echo Found domains from npm
#dev    echo "this  - last"
#dev    echo "check - check"
#dev    echo "  ""${#domains1[@]}""   -   ""${#domains2[@]}"
    if [ "${domains1[*]}" != "${domains2[*]}" ]; then
#dev        echo found new domains
        if "$usftp"; then getsftp; fi
        for i in "${domains1[@]}"; do
            checkdnsfile "$i"
        done
        domains2=("${domains1[@]}")
        if [ $n != 0 ]; then
            echo $(date) - Updated $n records
            if "$usftp"; then putsftp; fi
        fi
    fi
    n=0
}

while true; do
    main
    echo $(date) - sleeping
    sleep 5
done
