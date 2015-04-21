# !/bin/bash

git config --global user.email "evgeniy.kazakov@gmail.com"
git config --global user.name "Evgeniy Kazakov"

sudo add-apt-repository ppa:rquillo/ansible -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y