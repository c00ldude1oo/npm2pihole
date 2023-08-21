#!/usr/bin/env bash
sleep 1
n=0
declare -a dlist1
declare -a dlist2
echo Starting
#checks if using sftp
if "$USFTP"; then
    echo Using sftp to get dns list
    # checks if ssh key has been made
    if [ ! -f /root/.ssh/id_rsa ]; then
        # generate ssh key
        ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa
        touch INSTALL_SSH_KEY
        echo install ssh key and restart container. run ssh-copy-id -i ssh/id_rsa "$SFTPIP"
        exit 1
    fi
    # make sure the host is known so sftp wont have a user prompt
    ssh -o StrictHostKeyChecking=accept-new "$SFTPIP" echo hi
    echo true
else
    echo Not using sftp to get dns list
    if [ ! -f /app/custom.list ]; then echo "Please make sure piholes local dns file(custom.list) is mounted" && exit; fi
fi
# Gets file from remote pihole using sftp
getsftp() {
    echo getting dns list
    sftp "$SFTPIP":/etc/pihole <<EOF
get custom.list
EOF
}
# Puts file from remote pihole using sftp
putsftp() {
    echo Uploading new dns list
    sftp "$SFTPIP":/etc/pihole <<EOF
put custom.list
EOF
}
# Checks to pihole custom dns list if the domain is set
checkdnsfile() {
    #makes sure input is not empty
    if [ "$1" == "" ]; then
        echo "Missing <domain>"
        return 1
    fi
    echo Checking \""$*"\"
    domain=$1
    checkdns() {
        #echo Checkdns input is \""$*"\"
        #echo test \""$1"\" - \""$2"\"
        if [ "$domain" == "$2" ]; then
            if [ "$IP" == "$1" ]; then
                echo Found
            else
                # Found but IP doesnt match
                echo Setting IP. Was "$1"
                #filters out the wrong listing
                grep -v "$1 $2" custom.list >>list
                # adds to correct one
                echo "$IP" "$domain" >>list
                # renames it back
                cat list >custom.list
                # removes copy
                rm list
                # adds to the counter for total edited domains
                n=$((n + 1))
            fi
        else
            # not in pihole records
            echo Not found adding.
            # adds IP and domain to file
            echo "$IP" "$domain" >>custom.list
            # adds to the counter for total edited domains
            n=$((n + 1))
        fi
        echo
    }
    test=$(grep " $domain\$" custom.list)
    # shellcheck disable=SC2086
    checkdns $test
}
main() {
    echo Starting Check
    dlist1=()
    # reads all the files in npm and gets the domains out of them then formats and puts them in the array
    for file in npm/*; do dlist1+=("$(grep "server_name" "$file" | sed "s/  server_name //; s/;//")"); done
    echo Found domains from npm
    echo "this  - last"
    echo "check - check"
    echo "  ""${#dlist1[@]}""   -   ""${#dlist2[@]}"
    if [ "${dlist1[*]}" != "${dlist2[*]}" ]; then
        echo found new domains
        for i in "${dlist1[@]}"; do
            checkdnsfile "$i"
        done
        dlist2=("${dlist1[*]}")
        if [ $n != 0 ]; then
            echo Updated $n records
            if "$USFTP"; then putsftp; fi
        fi
    fi
}

while true; do
    main
    echo sleeping
    sleep 300
done
