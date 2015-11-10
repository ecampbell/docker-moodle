FROM ubuntu:14.04
MAINTAINER Eoin Campbell <ecampbell@xmlw.ie>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
 
# Basic Requirements
RUN apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip

# Moodle Requirements, using ssmtp instead of postfix
RUN apt-get -y install apache2 php5 php5-gd libapache2-mod-php5 ssmtp php5-xsl wget supervisor php5-pgsql vim libcurl3 libcurl3-dev php5-curl php5-xmlrpc php5-intl php5-mysql

# SSH
# RUN apt-get -y install openssh-server
# RUN mkdir -p /var/run/sshd

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# Grab the latest Moodle and make it the root website
ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
RUN rm -rf /var/www/html
RUN cd /var/www; tar zxf moodle-latest.tgz; mv /var/www/moodle /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN mkdir /var/moodledata
RUN chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata

RUN easy_install supervisor
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

CMD ["/bin/bash", "/start.sh"]

