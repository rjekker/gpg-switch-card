#! /bin/bash

createmenu ()
{
    echo
    select option; do # in "$@" is the default
        if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $(($#)) ];
        then
            echo "You selected $option"
            break;
        else
            echo "Incorrect Input: Select a number 1-$#"
        fi
    done
}

IFS=$'\n' keys_list=($(gpg2 --list-secret-keys --with-colons | egrep '^uid:' | cut -d: -f10))
PS3='For which id do you want to remove the secret keys?'

createmenu "${keys_list[@]}"
YUBI_ID=${keys_list[$(($REPLY-1))]}


# This function returns an awk script
# That parses gpg output to find keygrips
# It's an ugly way to include a nicely indented awk script here
get_awk_source() {
    cat <<EOF
BEGIN { 
  FS = ":";
}

/^ssb/ { 
    # Found a subkey
    key = \$5;
}

/^grp/ && key {
    # Found a keygrip
    grip = \$10;
    if(key in grips){
           print "Warning: found multiple grips for same key";
           print "Skipping grip" grip;
    } else {
        grips[key] = grip;
    }
}

END {
    for(k in grips){
        print k ":" grips[k];
    }
}
EOF
}

get_active_yubi_grips () {
    gpg2 --with-keygrip --list-secret-keys --with-colons "${YUBI_ID}" | awk -f <(get_awk_source)
}
IFS=$'\n' grips=($(get_active_yubi_grips))

echo
echo "----- Listing selected keys -----"
gpg2  --with-keygrip --list-secret-keys "${YUBI_ID}"
echo "---------------------------------"
echo

echo "Given the data above, please approve removing key files"
for keygrip in "${grips[@]}"
do
    key=$(echo $keygrip | cut -d: -f1)
    grip=$(echo $keygrip | cut -d: -f2)

    echo "Key: $key"
    file="$HOME/.gnupg/private-keys-v1.d/$grip.key"
    rm -i $file
done
