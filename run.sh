git config --global user.email "evgeniy.kazakov@gmail.com"
git config --global user.name "Evgeniy Kazakov"

ansible-playbook -i inventory playbook.yml "${@}"
#--extra-vars "$1" --tags "$2"
