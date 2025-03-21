#git config --global user.email "evgeniy.kazakov@gmail.com"
#git config --global user.name "Evgenii Kazakov"

ansible-playbook -i hosts playbook.yml "${@}"
#--extra-vars "$1" --tags "$2"
