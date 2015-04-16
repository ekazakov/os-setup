# !/bin/bash
sudo add-apt-repository ppa:rquillo/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y
ansible-playbook -K -i inventory playbook.yml