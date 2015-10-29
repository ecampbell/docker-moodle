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
docker run --name moodle3b_ssmtp \
  -e VIRTUAL_HOST=moodle.domain.com -e MAIL_HOST=email-smtp.us-east-1.amazonaws.com:465 \
  -e APACHE_PORT=81 -e AUTH_USER=MAILUSER -e AUTH_PASS=MAILPASSWORD \
  --expose=81 -d -t -p 81:81 moodle3b_ssmtp
```

You can then visit the following URL in a browser to get started:

```
http://moodle.domain.com:81/
```

## Implementation details

This configuration is tuned for use on an Amazon AMI, using the Amazon SES (Simple Email Service)
to send out-bound emails from the server for user registration, news, etc.

The SSH service is disabled in the instance, as this seems to be good Docker practice, 
but it can be easily re-instated by uncommenting it
(you will need to edit Dockerfile, start.sh and supervisord.conf).

## Pre-requisites

* You must have an Amazon AWS account (cf. https://aws.amazon.com/).
* If you want to use a port number other than 80, you will need to edit the Amazon security group
settings for your AMI instance to add it in,
or you won't be able to access it externally.
* You must register for the Amazon SES service in order to get 
SES SMTP server authentication details to be able to send emails
(cf. http://docs.aws.amazon.com/ses/latest/DeveloperGuide/Welcome.html).
The details you need include the name of the SMTP mail server, a username and a password.
(cf. 
* You must register any email addresses you want to use for testing on the Amazon SES also
(cf. http://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses.html).
Verify your from (and probably to) email address(es) using the Amazon console, 
or your message will be rejected by the Amazon SES SMTP server.

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

The sSMTP service is configured using information from http://edoceo.com/howto/ssmtp#ses.
You can choose not to use the Amazon SES service, and use another email provider instead. 
For example, instructions for GMail are available at https://wiki.archlinux.org/index.php/SSMTP


## Acknowledgements

Thanks to [sergiogomez](https://github.com/sergiogomez) for his Dockerfile.