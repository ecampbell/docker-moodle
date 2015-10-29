docker-moodle-ssmtp
===================

Moodle on an Amazon AMI with Apache, PHP, MySQL and ssmtp

## Installation

```
git clone https://github.com/ecampbell/docker-moodle-ssmtp.git
cd docker-moodle-ssmtp
docker build -t moodle .
```

## Usage

To spawn a new instance of Moodle:

```
docker run --name moodle1 -e VIRTUAL_HOST=moodle.domain.com -e MAIL_HOST=email-smtp.us-east-1.amazonaws.com:465 -e APACHE_PORT=81 -e AUTH_USER=MAILUSER -e AUTH_PASS=MAILPASSWORD --expose=81 -d -t -p 81:81 moodle3b_ssmtp
```

You can visit the following URL in a browser to get started:

```
http://moodle.domain.com/
```

## Implementation details

This configuration is tuned for use on an Amazon AMI, using the Amazon SES (Simple Email Service)
to send out-bound emails from the server for user registration, news, etc.

The SSH service is disabled on the instance, as this seems to be good practice, but it can be
easily re-instated by uncommenting it.

## Pre-requisites

* You must have an Amazon AWS account.
* If you want to use a port number other than 80, you will need to edit the Amazon security group
settings for your AMI instance to add it in,
or you won't be able to access it externally.
* You must register for the Amazon SES service in order to get 
SES SMTP server authentication details to be able to send emails.
* When testing the SES service from your Docker instance, you must first verify your from 
(and probably to) email address(es) using the Amazon console, or your message will be 
rejected.

You can test sending emails using the following command:

```
ssmtp -v success@simulator.amazonses.com << EMAIL
To: success@simulator.amazonses.com
From: admin@moodle.domain.com
Subject: Test from moodle on docker using ssmtp

Hello, world.

EMAIL
```

You can choose not to use the SES service, but another email provider instead. 
However, you'll have to figure out the exact email configuration yourself, and it's
not trivial.


## Acknowledgements

Thanks to [sergiogomez](https://github.com/sergiogomez) for his Dockerfile.