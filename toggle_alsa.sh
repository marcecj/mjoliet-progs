#!/usr/bin/env/ bash

FILES=($(ls $HOME/.asoundrc_*))

for i in ${!FILES[@]}; do
  echo -e "$(($i+1))\t${FILES[$i]}"
done

echo "Please set the new asoundrc: "
read -e choice

ln -sf ${FILES[$choice-1]} /home/marcec/.asoundrc
echo "Done!"
