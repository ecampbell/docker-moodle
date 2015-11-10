docker-moodle-ssmtp
===================

Moodle on an Amazon AMI with Apache, PHP, MySQL and ssmtp

## Installation

```
git clone https://github.com/ecampbell/docker-moodle-ssmtp.git
cd docker-moodle-ssmtp
docker build -t moodle3b_ssmtp .
```

## Usage

To spawn a new instance of Moodle using port 81 as the web server port:

```
docker run --name moodle3b81_ses \
  -e MOODLE_HOSTNAME=moodle.domain.com \
  -e MOODLE_ADMIN_EMAIL=MOODLE_EMAIL \
  -e MOODLE_ADMIN_PASS='MOODLE_PASS' \
  -e MAIL_HOST=email-smtp.eu-west-1.amazonaws.com:465 \
  -e MAIL_USER=MAILUSER -e MAIL_PASS='MAILPASSWORD' \
  -e WEB_PORT=81 --expose=81 -p 81:81 \
  -d -t moodle3b_ssmtp
```

You can then visit the following URL in a browser to log in to your fully installed Moodle server:

```
http://moodle.domain.com:81/
```

Alternatively, spawn a new instance of Moodle using port 82 and Gmail:
```
docker run --name moodle3b82_gmail \
  -e MOODLE_HOSTNAME=moodle.domain.com \
  -e MOODLE_ADMIN_EMAIL=MOODLE_EMAIL \
  -e MOODLE_ADMIN_PASS=MOODLE_PASS \
  -e MAIL_HOST=smtp.gmail.com:567 \
  -e MAIL_USER=youremail@gmail.com -e MAIL_PASS=MAILPASSWORD \
  -e WEB_PORT=82 --expose=82 -p 82:82 \
  -d -t moodle3b_ssmtp
```

## Implementation details

This configuration is tuned for use on an Amazon AMI, using either the Amazon SES (Simple Email Service)
or Gmail to send out-bound emails from the server for user registration, news, etc.

## Pre-requisites

* You must have an Amazon AWS account (cf. https://aws.amazon.com/).
* If you want to use a port number other than 80, you will need to edit the Amazon security group
settings for your AMI instance to add it in,
or you won't be able to access it externally.
* You must register for the Amazon SES service in order to get 
SES SMTP server authentication details to be able to send emails
(cf. http://docs.aws.amazon.com/ses/latest/DeveloperGuide/Welcome.html).
The details you need include the name of the SMTP mail server, a username and a password.
* You must register any email addresses you want to use for testing on the Amazon SES also
(cf. http://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses.html).
Verify your from and to email addresses using the Amazon console, 
or your message will be rejected by the Amazon SES SMTP server.

## Further information

You can test sending emails and watch the progress (-v) using the following command
(cf. http://www.havetheknowhow.com/Configure-the-server/Install-ssmtp.html):

```
ssmtp -v success@simulator.amazonses.com << EMAIL
To: success@simulator.amazonses.com
From: admin@moodle.domain.com
Subject: Test from moodle on docker using ssmtp

Hello, world.

EMAIL
```

See also the ssmtp-howto.md file
for more detailed instructions on getting Gmail and Amazon SES to accept emails from your server.

## Acknowledgements

Thanks to [sergiogomez](https://github.com/sergiogomez) for his Dockerfile.
The sSMTP service is configured using information from http://edoceo.com/howto/ssmtp.
For PHP/ssmtp configuration, see https://reidliujun.wordpress.com/2014/07/24/ubuntu-email-server/.

