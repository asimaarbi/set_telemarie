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

ID=$(/usr/bin/anydesk --get-id)
pass=$(openssl rand -hex 4)
echo $pass | anydesk --set-password

#switches=$(python3 switchState2.py)
switches=3
for switch in $switches; do
  emails=$(curl -s http://94.130.187.90:7777/api/recipients/9/2 | jq -r .emails[])
  phones=$(curl -s http://94.130.187.90:7777/api/recipients/9/2 | jq -r .phones[])
  echo $emails
  echo $switch
  for value in $emails; do
    echo $value
    curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from 'grandmahertha9@gmail.com' --mail-rcpt $value --user 'grandmahertha9@gmail.com:thomaspi' -T <(echo -e "From: grandmahertha9@gmail.com\nTo: thomasseher@gmx.de\nSubject:Telemarie 2 ist eingeschaltet\n\nAnydesk Id : $ID\nPassword  : $pass\nJitsi Link :  http://94.130.187.90:7300/connect/telemarie/jitsi/tm/2\n\nPower_off tm2 : http://94.130.187.90:7300/tm/2/poweroff\n\n Reboot tm2 : http://94.130.187.90:7300/tm/2/reboot\r\n")
  done
  sleep 20
  for value in $phones; do
    stty -F /dev/ttyUSB3 speed 9600 -brkint -icrnl ixoff -imaxbel -opost -onlcr -isig -icanon -echo -echoe
    tail -f /dev/ttyUSB3 &
    phone="+"$value
    echo $phone
    echo -e "AT+CMGF=1\r\n" >/dev/ttyUSB3
    echo -e "AT+CMGS=\"$phone\"\r\n" >/dev/ttyUSB3
    echo -e "Telemarie2 eingeschaltet\nAnydeskId:$ID\nPassword:$pass\nMeet: 94.130.187.90:7300/connect/telemarie/jitsi/tm/2\nPoweroff: 94.130.187.90:7300/tm/2/poweroff\032\r\n" >/dev/ttyUSB3
    sleep 10
  done
done
