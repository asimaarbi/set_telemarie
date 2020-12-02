#!/usr/bin/env bash
set -e

while ! ping -c 1 -W 1 8.8.8.8; do
    echo "Waiting for 1.2.3.4 - network interface might be down..."
    sleep 1
done

if [[ $(id -u) -ne 0 ]]; then
    echo Must run as root
    exit 1
fi

#ID=$(/usr/bin/anydesk --get-id)
#pass=$(openssl rand -hex 4)
#echo $pass | anydesk --set-password

#email=thomasseher@gmx.de

#phone=+491788773695
#email=$(sqlite3 /home/pi/recipient.db "SELECT email FROM recipient")
email=(asimfarooq5@gmail.com)

for value in $email
do
    echo $value
    curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd   --mail-from 'grandmahertha9@gmail.com'   --mail-rcpt $value   --user 'grandmahertha9@gmail.com:thomaspi'   -T <(echo -e "From:
                   grandmahertha9@gmail.com\nTo: bernhardweb@web.de\nSubject:Time to Meet\n\nAnydesk Id : $ID\nPassword  : $pass\nJitsi Link :  
                   http://codebase.pk:7300/connect/telemarie/jitsi\nAdmin panel link : http://codebase.pk:7778/admin")
done

#stty -F /dev/ttyUSB3 speed 9600 -brkint -icrnl ixoff -imaxbel -opost -onlcr -isig -icanon -echo -echoe
#tail -f /dev/ttyUSB3 &
#echo -e "AT+CMGF=1\r\n" > /dev/ttyUSB3
#echo -e "AT+CMGS=\"$phone\"\r\n" > /dev/ttyUSB3
#echo -e "Hey, Time to meet with Grandma\n Id : $ID\n pass: $pass\nJitsi Link: http://codebase.pk:7300/connect/telemarie/jitsi\032\r\n" > /dev/ttyUSB3
