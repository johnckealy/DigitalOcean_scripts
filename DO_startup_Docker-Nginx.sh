############## Add to digitalOcean droplet before its creation #########

#!/bin/bash
set -euo pipefail
USERNAME=jokea
COPY_AUTHORIZED_KEYS_FROM_ROOT=true
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"
encrypted_root_pw="$(grep root /etc/shadow | cut --delimiter=: --fields=2)"
if [ "${encrypted_root_pw}" != "*" ]; then
    echo "${USERNAME}:${encrypted_root_pw}" | chpasswd --encrypted
    passwd --lock root
else
    passwd --delete "${USERNAME}"
fi
chage --lastday 0 "${USERNAME}"
home_directory="$(eval echo ~${USERNAME})"
mkdir --parents "${home_directory}/.ssh"
if [ "${COPY_AUTHORIZED_KEYS_FROM_ROOT}" = true ]; then
    cp /root/.ssh/authorized_keys "${home_directory}/.ssh"
fi
for pub_key in "${OTHER_PUBLIC_KEYS_TO_ADD[@]}"; do
    echo "${pub_key}" >> "${home_directory}/.ssh/authorized_keys"
done
chmod 0700 "${home_directory}/.ssh"
chmod 0600 "${home_directory}/.ssh/authorized_keys"
chown --recursive "${USERNAME}":"${USERNAME}" "${home_directory}/.ssh"
sed --in-place 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
if sshd -t -q; then
    systemctl restart sshd
fi
ufw allow OpenSSH
ufw --force enable
ufw allow 443/tcp






#################### Docker ####################

echo "############## apt updating.." &&
sudo apt update  &&
echo "############## installing dependencies..." &&
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg-agent -y &&
echo "############## Adding docker key..." &&
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -  &&
echo "############## Adding docker repository..." &&
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" -y &&
echo "Apt updating again..." &&
sudo apt update &&
echo "############## Installing docker..." &&
sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
echo "############## Cache policy..." &&
sudo apt-cache policy docker-ce &&
echo "############## Giving docker to ${USER}..." &&
sudo usermod -aG docker ${USER} && 
echo "############## Installing compose..." && 
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && 
echo "############## Changing permissions for compose..." && 
sudo chmod +x /usr/local/bin/docker-compose && 
echo "############## Linking directories..." && 
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose &&
echo "############## Done installing docker."
echo "Creating /var/www for $USER"
sudo mkdir /var/www
sudo chown -R $USER /var/www



# scp 
tar -zcvf numpy.tar.gz numpy_temperature_files && scp numpy.tar.gz jokea@161.35.171.118:/var/www/climo/api/data 






###################################################
# Add to .bashrc in new droplets

alias gst="git status"
alias gl="git log"

alias venv="source ${PWD}/*/bin/activate"
alias dotvenv="source ${PWD}/.*/bin/activate"


# function to nuke docker stuff
docker-armageddon() {
    docker-compose down -v
    docker-compose -f docker-compose.prod.yml down -v
    docker stop -f $(docker ps -a -q)
    docker rm -f $(docker ps -a -q)
    docker network prune -f
    docker rmi -f $(docker images --filter dangling=true -qa)
    docker volume rm $(docker volume ls --filter dangling=true -q)
    docker rmi -f $(docker images -qa)
}



#########################################