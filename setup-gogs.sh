#!/bin/bash

apt-get update


if [ "$(id -u)" != "0" ]; then
    echo "you should run this script with root!!! "
    exit 1
else


# Golang installation

# Download Go and extract the compressed file:

    donwload="go$VERSION.linux-amd64.tar.gz" 
    echo "$dowload is being downloaded !!!!"
    wget https://storage.googleapis.com/golang/$dowload -O /tmp/go.tar.gz

    tar -C "$HOME" -xzf /tmp/go.tar.gz
    mv "$HOME/go" "$HOME/.go"# Set the GOPATH environment variable to specify the location of our workspace.

    touch "$HOME/.${shell_profile}"
    {
        echo '# GoLang'
        echo 'export GOROOT=$HOME/.go'
        echo 'export PATH=$PATH:$GOROOT/bin'
        echo 'export GOPATH=$HOME/go'
        echo 'export PATH=$PATH:$GOPATH/bin'
    } >> "$HOME/.${shell_profile}"

    mkdir -p $HOME/go/{src,pkg,bin}
    rm -f /tmp/go.tar.gz

# git installation

    sudo apt-get install -y git
    adduser --disabled-login --gecos 'Gogs' git # When you install Go and Gogs, it will be under the user git.

# Gogs installation

    echo "" >>/etc/hosts
    echo "$1  $2" >>/etc/hosts
    hostnamectl set-hostname $2
    echo "$2" > /proc/sys/kernel/hostname

    apt-get install -y wget nginx git-core mysql-client mysql-server # Install nginx from the repository:

    cd /home/git
    wget --no-check-certificate https://dl.gogs.io/0.11.4/linux_amd64.tar.gz
    tar -xvf linux_amd64.tar.gz && rm -f linux_amd64.tar.gz

    echo "CREATE USER 'gogs'@'localhost' IDENTIFIED BY $3;" >>/home/git/gogs/scripts/mysql.sql
    echo "GRANT ALL PRIVILEGES ON gogs.* TO 'gogs'@'localhost';" >>/home/git/gogs/scripts/mysql.sql 

    mysql -p < /home/git/gogs/scripts/mysql.sql

    chmod +x /home/git/gogs/gogs
    mkdir -p /home/git/gogs/log

    chown -R git:git /home/git/gogs
    chown -R git:git /home/git/gogs/*
    cp /home/git/gogs/scripts/systemd/gogs.service /etc/systemd/system/ # Download and install Gogs
    sed -i 's|mysqld.service|mysqld.service mysql.service|' /etc/systemd/system/gogs.service

    systemctl daemon-reload
    systemctl enable gogs.service
    systemctl start gogs.service
    
# Set nginx as the reverse proxy for Gogs. Using sudo, create a new file named /etc/nginx/sites-available/gogs
   
   echo 'server {
        listen          IP:80;
        server_name     DOMAIN;

        proxy_set_header X-Real-IP  $remote_addr; # pass on real client IP

        location / {
            proxy_pass http://localhost:3000;
        }
    }' > /etc/nginx/sites-available/gogs.conf

    ln -s /etc/nginx/sites-available/gogs.conf /etc/nginx/sites-enabled/gogs.conf

    sed -i "s/IP/$1/" /etc/nginx/sites-available/gogs.conf
    sed -i "s/DOMAIN/$2/" /etc/nginx/sites-available/gogs.conf
    service nginx restart

    echo "installation completed"

    systemctl enable gogs.service
    systemctl start gogs.service

fi
