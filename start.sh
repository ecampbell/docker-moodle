#!/bin/bash
if [ ! -f /var/www/html/config.php ]; then
  #mysql has to be started this way as it doesn't work to call from /etc/init.d
  /usr/bin/mysqld_safe &
  sleep 10s
  # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
  MOODLE_DB="moodle"
  MYSQL_PASSWORD=`pwgen -c -n -1 12`
  MOODLE_PASSWORD=`pwgen -c -n -1 12`
  # SSH_PASSWORD=`pwgen -c -n -1 12`
  #This is so the passwords show up in logs.
  echo mysql root password: $MYSQL_PASSWORD
  echo moodle password: $MOODLE_PASSWORD
  # echo ssh root password: $SSH_PASSWORD
  # echo root:$SSH_PASSWORD | chpasswd
  echo $MYSQL_PASSWORD > /mysql-root-pw.txt
  echo $MOODLE_PASSWORD > /moodle-db-pw.txt
  # echo $SSH_PASSWORD > /ssh-pw.txt

  sed -e "s/pgsql/mysqli/
  s/'username'/'moodle'/
  s/'password'/'$MOODLE_PASSWORD'/
  s,example.com/moodle,$MOODLE_HOSTNAME,
  s/\/home\/example\/moodledata/\/var\/moodledata/" /var/www/html/config-dist.php > /var/www/html/config.php

  # sed -i 's/PermitRootLogin without-password/PermitRootLogin Yes/' /etc/ssh/sshd_config

  chown www-data:www-data /var/www/html/config.php

  mysqladmin -u root password $MYSQL_PASSWORD
  mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE moodle; GRANT ALL PRIVILEGES ON moodle.* TO 'moodle'@'localhost' IDENTIFIED BY '$MOODLE_PASSWORD'; FLUSH PRIVILEGES;"
  killall mysqld

  # Configure ssmtp to forward mail to Amazon SES SMTP server
  # cf. http://edoceo.com/howto/ssmtp#ses
  if [ ! -z "$MAIL_HOST"  -a ! -z "$MAIL_USER" -a ! -z "$MAIL_PASS" ]; then
    sed -ri -e "s/^(mailhub=).*/\1$MAIL_HOST/" \
      -e "s/^#(FromLineOverride)/\1/" \
      /etc/ssmtp/ssmtp.conf

    # Amazon SES specific mail settings
    if [[ $MAIL_HOST = *amazonaws* ]]; then
      sed -ri -e "/^(hostname=)/ s/$/\nAuthUser=$MAIL_USER\nAuthPass=$MAIL_PASS\nUseTLS=YES/" \
        -e "s/^(hostname=).*/\1$MOODLE_HOSTNAME/" \
        -e "s/^#(rewriteDomain=)/\1$MOODLE_HOSTNAME/" \
        /etc/ssmtp/ssmtp.conf
    fi

    # GMail specific mail settings
    if [[ $MAIL_HOST = *gmail* ]]; then
      sed -ri -e "s/^(hostname=).*/\1$MAIL_USER/" \
        -e "/^(hostname=)/ s/$/\nAuthUser=$MAIL_USER\nAuthPass=$MAIL_PASS\nUseTLS=YES\nUseSTARTTLS=YES/" \
        -e "s/^#(rewriteDomain=)/\1gmail.com/" \
        etc/ssmtp/ssmtp.conf
    fi

    # Reverse aliases
    echo "root:postmaster@$MOODLE_HOSTNAME:$MAIL_HOST" >>/etc/ssmtp/revaliases
    echo "www-data:postmaster@$MOODLE_HOSTNAME:$MAIL_HOST" >>/etc/ssmtp/revaliases

    # Tell PHP to send emails using ssmtp, not sendmail
    sed -ri -e 's,^;(sendmail_path).*,\1 =/usr/sbin/ssmtp -t,' /etc/php5/apache2/php.ini
    echo Mail host: $MAIL_HOST
  fi

  # Change the web server port from the default
  if [ ! -z "$WEB_PORT" ]; then
    sed -ri -e "s/^(Listen).*/\1 $WEB_PORT/" /etc/apache2/ports.conf
    sed -ri -e "s/^(<VirtualHost \*):.*>/\1:$WEB_PORT>/" /etc/apache2/sites-available/000-default.conf
    echo Apache port: $WEB_PORT
  fi

  # Install Moodle non-interactively if an administration email address and password are provided
  if [ ! -z "$MOODLE_ADMIN_EMAIL" -a ! -z "$MOODLE_ADMIN_PASS" ]; then
    cd /var/www/html
    # Set an explicit port for Moodle wwwroot if port 80 not used
    if [ ! -z "$WEB_PORT" ]; then
      VIRTUAL_PORT=:$WEB_PORT
    fi

    echo Moodle configuration started
    /usr/bin/php admin/cli/install.php --lang=en --wwwroot=http://$MOODLE_HOSTNAME$VIRTUAL_PORT --dataroot=/var/moodledata --dbuser=moodle --dbpass=$MOODLE_PASSWORD --dbport=3306 --adminpass=$MOODLE_ADMIN_PASS --adminemail=$MOODLE_ADMIN_EMAIL  --non-interactive --agree-license --allow-unstable
    echo Moodle configuration completed
  fi


fi
# start all the services
/usr/local/bin/supervisord -n
