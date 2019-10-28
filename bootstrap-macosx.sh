#!/bin/bash

function error_message() {
  echo -e "Script failed on line $1 of the deployment script"
}

trap 'error_message $LINENO' ERR

set -o pipefail
set -e

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew tap homebrew/cask-cask
brew install ansible

TEMPLATE="
Host localhost
  ForwardAgent yes

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/github_rsa
  IdentityFile ~/.ssh/bitbucket_rsa
"

DESTINATION="${HOME}/.ssh/config"

printf "\n******** Generate github access key\n"
ssh-keygen -N "" -t rsa -b 4096 -f ~/.ssh/github_rsa -C "github.com key by evgeniy.kazakov@gmail.com"

printf "\n******** Generate bitbucket access key\n"
ssh-keygen -N "" -t rsa -b 4096 -f ~/.ssh/bitbucket_rsa -C "bitbucket.org key by evgeniy.kazakov@gmail.com"

printf "\n******** Run ssh-agent\n"
eval "$(ssh-agent -s)"

printf "\n******** Add keys to ssh-agent\n"
ssh-add -K ~/.ssh/github_rsa
ssh-add -K ~/.ssh/bitbucket_rsa

printf "\n******** Create user ssh config\n"

mkdir -p "${HOME}/.ssh"
if [ -f "${DESTINATION}" ]; then
	mv "${DESTINATION}" "${DESTINATION}_old"
fi

echo "${TEMPLATE}" > "${DESTINATION}"