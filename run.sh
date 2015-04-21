git config --global user.email "evgeniy.kazakov@gmail.com"
git config --global user.name "Evgeniy Kazakov"

ansible-playbook -K -i inventory playbook.yml --extra-vars "user=evgeniy"