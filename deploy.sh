#!/bin/bash


#  Deploiement a la volée de container docker
#
#

# Functions

help(){
echo "

options : 
	- --create : lancer des containers

	- --drop : supprimer les containers creer par le deploy.sh

	- --infos : caracteristiques des containers (ip, nom, user ...)	

	- --start :redémarrage des containers

	- --ansible: déploiement arborescence ansible
"
}

createNodes() {
	#definition du nombre de container
	nb_machine=1
	[ "$1" != "" ] && nb_machine=$1
	#setting min/max
	min=1
	max=0

	# récuperation de idmax
	idmax=`docker ps -a --format '{{ .Names }}' | awk -F "-" -v user="$USER" '$0 ~ user"-debian" {print $3}' | sort -r |head -1`

	#redefinition de min et max
	min=$(($idmax +1))
	max=$(($idmax + nb_machine))

	#lancement des containers
	for i in $(seq $min $max);do
		docker run -tid --privileged --publish-all=true -v /srv/data:/srv/html -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name $USER-debian-$i -h $USER-debian-$i priximmo/buster-systemd-ssh
		docker exec -ti $USER-debian-$i /bin/sh -c "useradd -m -p sa3tHJ3/KuYvI $USER"
		docker exec -ti $USER-debian-$i /bin/sh -c "mkdir ${HOME}/.ssh && chmod 700 ${HOME}/.ssh && chown $USER:$USER $HOME/.ssh"
		docker cp $HOME/.ssh/id_rsa.pub $USER-debian-$i:HOME/.ssh/authorized_keys
		docker exec -ti $USER-debian-$i /bin/sh -c "chmod 600 ${HOME}/.ssh/authorized_keys && chown $USER:$USER $HOME/.ssh/authorized_keys"
		docker exec -ti $USER-debian-$i /bin/sh -c "echo '$USER ALL=(ALL) NOPASSWD: ALL'>>/etc/sudoers"
		docker exec -ti $USER-debian-$i /bin/sh -c "service ssh start"
		echo "Conteneur $USER-debian-$i créé"	
	done
	infosNodes

}

dropNodes(){
	echo "Supression des conteneurs..."
	docker rm -f $(docker ps -a | grep $USER-debian | awk '{print $1}')
	echo "Fin de la suppression"
}

startNodes(){
	echo ""
	docker start $(docker ps -a | grep $USER-debian | awk '{print $1}')
	for conteneur in $(docker ps -a | grep $USER -debian | awk '{print $1}');do
		docker exec -ti $conteneur /bin/sh -c "service ssh start"
	done
	echo ""
}

createAnsible(){
	echo "" 
	ANSIBLE_DIR="ansible_dir"
	mkdir -p $ANSIBLE_DIR
	echo "all:" > $ANSIBLE_DIR/00_inventory.yml
	echo " vars:" >>$ANSIBLE_DIR/00_inventory.yml
	echo "	ansible_python_interpreter: /usr/bin/python3" >> $ANSIBLE_DIR/00_inventory.yml
	echo "	hosts:" >> $ANSIBLE_DIR/00_inventory.yml
	for conteneur in $(docker ps -a | grep /home/khkk2022-debian | awk '{print $1}');do
		docker inspect -f '	=>{{.Name}} - {{.NetworkSetting.IPAddress }}:' $conteneur >> $ANSIBKLE_DIR/00_inventory.yml
	done
	mkdir -p $ANSIBLE_DIR/host_vars
	mkdir -p $ANSIBLE_DIR/group_vars
	echo ""
}

infosNodes(){
	echo ""
	echo "Information des conteneurs : "
	echo ""
	for conteneur in $(docker ps -a | grep $USER-debian | awk ' {print $1}');do
		docker inspect -f '  => {{.Name}} - {{.NetworkSettings.IPAddress }}' $conteneur
	done 
	echo ""
}

#si option --create
if [ "$1" == "--create" ];then
	createNodes $2

# si option --drop
elif [ "$1" == "--drop" ];then
	dropNodes

# si option --start
elif [ "$1" == "--start" ];then
	startNodes

# si option --ansible
elif [ "$1" == "--ansible" ];then
	createAnsible

# si option --infos
elif [ "$1" == "--infos" ];then
	infosNodes

# si aucune option affichage de l'aide
else
	help

fi



