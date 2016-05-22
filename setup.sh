#!/bin/bash

apt-get update	
apt-get install -y nginx unzip

#Mysql
debconf-set-selections <<< 'mysql-server mysql-server/root_password password abc123'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password abc123'
apt-get -y install mysql-server
mysql -u root -pabc123 -e 'CREATE DATABASE /*\!32312 IF NOT EXISTS*/ `grannydb` /*\!40100 DEFAULT CHARACTER SET latin1 */'
mysql -u root -pabc123 -e "GRANT ALL PRIVILEGES ON grannydb.* To 'demo'@'localhost' IDENTIFIED BY 'demodemo'"
mysql -u root -pabc123 -e 'FLUSH PRIVILEGES'

#JDK
mkdir /opt/jdk
wget -o /dev/null --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz --directory-prefix=/opt/jdk
tar xf /opt/jdk/jdk-7u79-linux-x64.tar.gz -C /opt/jdk
update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.7.0_79/bin/java 1
update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.7.0_79/bin/javac 1
update-alternatives --set java /opt/jdk/jdk1.7.0_79/bin/java
update-alternatives --set javac /opt/jdk/jdk1.7.0_79/bin/javac

#Tomcat
wget -o /dev/null http://apache.mirrors.lucidnetworks.net/tomcat/tomcat-7/v7.0.69/bin/apache-tomcat-7.0.69.tar.gz --directory-prefix=/opt/
tar xf /opt/apache-tomcat-7.0.69.tar.gz -C /opt/
sed -i 's/Connector port="8080"/Connector port="9000"/' /opt/apache-tomcat-7.0.69/conf/server.xml
useradd -d /opt/apache-tomcat-7.0.69/ tomcat7
chown -R tomcat7:tomcat7 /opt/apache-tomcat-7.0.69
#Add xerces libs which are required by addressbook app
wget -o /dev/null http://mirrors.sonic.net/apache/xerces/j/binaries/Xerces-J-bin.2.11.0.tar.gz --directory-prefix=/tmp/
cd /tmp/
tar xvf Xerces-J-bin.2.11.0.tar.gz xerces-2_11_0/xercesImpl.jar xerces-2_11_0/xml-apis.jar
cp xerces-2_11_0/{xercesImpl.jar,xml-apis.jar} /opt/apache-tomcat-7.0.69/lib/
sudo -H -u tomcat7 sh -c "/opt/apache-tomcat-7.0.69/bin/startup.sh"

#Address Book
wget -o /dev/null http://www.cumulogic.com/download/Apps/Granny-Addressbook.zip --directory-prefix=/tmp/
cd /tmp/
unzip /tmp/Granny-Addressbook.zip
sudo -H -u tomcat7 sh -c "cp Granny-Addressbook/granny.war /opt/apache-tomcat-7.0.69/webapps/"
sleep 15
sudo -H -u tomcat7 sh -c "cp /vagrant/context.xml /opt/apache-tomcat-7.0.69/webapps/granny/META-INF/"
sudo -H -u tomcat7 sh -c "/opt/apache-tomcat-7.0.69/bin/shutdown.sh"
sleep 15
sudo -H -u tomcat7 sh -c "/opt/apache-tomcat-7.0.69/bin/startup.sh"

#Nginx
cp /vagrant/reverse_proxy /etc/nginx/sites-available/
unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/reverse_proxy /etc/nginx/sites-enabled/
/etc/init.d/nginx restart

