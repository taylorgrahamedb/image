#!/bin/bash
at_term() {
    echo 'Terminated.'
    exit 0
}
trap at_term TERM
echo $$


echo "Were are starting the init of the container v1.1"

echo "whoami: $(whoami)"
if [ -z "$MANAGE_CONFIG" ]
then
  printf "Not managing config\n"

  /config.sh
else
  printf "Config is managed \n"
fi

while true; do
    sleep 20
done
