## Prerequisites

[VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/), tested with VirtualBox 5.0.20 and Vagrant 1.8.1.

## Up and SSH

To start the vagrant box run:

    vagrant up

To log in to the machine run:

    vagrant ssh

AddressBook application will be available on host machine on port 80

## Tomcat
Controlled by

    sudo -H -u tomcat7 sh -c "/opt/apache-tomcat-7.0.69/bin/shutdown.sh"
    sudo -H -u tomcat7 sh -c "/opt/apache-tomcat-7.0.69/bin/startup.sh"

