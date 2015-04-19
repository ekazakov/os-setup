# !/bin/bash

git config --global user.email "evgeniy.kazakov@gmail.com"
git config --global user.name "Evgeniy Kazakov"

sudo add-apt-repository ppa:rquillo/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y
sudo ansible-playbook -K -i inventory playbook.yml --extra-vars "user=evgeniy"