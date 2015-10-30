How to configure Gmail or Amazon SES with sSMTP
===============================================

This note describes the steps to enable your server to use Gmail or Amazon SES
to send out-bound messages using sSMTP.

## Gmail
Gmail automatically prevents new devices from accessing email accounts 
until they are explicitly enabled, as a security measure.
Accessing Gmail from an Amazon AMI or hosted webserver counts as a new device.
To enable access from a new device, do the following steps.

1. In your web browser, log in to Gmail,
go to [Manage your account access and security settings](https://myaccount.google.com/security?pli=1),
scroll to the bottom of the page, 
and set "Allow less secure apps:" to ON by sliding the blue circle to the right.
2. Go to [Allow access to your Google account](https://accounts.google.com/DisplayUnlockCaptcha),
and click the 'Continue' button.
3. Log in to your Amazon AMI server and check your Gmail account using the following command,
supplying your Gmail password when prompted:
```
curl -u youremail@gmail.com --silent "https://mail.google.com/mail/feed/atom"

```
This registers your new 'device' with Gmail, so your Moodle server won't be blocked
when it tries to send registration verification details to new users later.
If it fails you will see a HTML message with Unauthorized in the title element,
otherwise you should see some HTML telling you how many messages are in your inbox.

### SSMTP configuration with Gmail
1. Install ssmtp using the command *apt-get install -y ssmtp*.
2. Edit the file /etc/ssmtp/revaliases and insert the following line, using your own Gmail address:
```
root:youremail@gmail.com:smtp.gmail.com:587
```
3. Edit the file /etc/ssmtp/ssmtp.conf to look like the following, using your own Gmail address and password:
```
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
#root=postmaster
root=youremail@gmail.com

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
mailhub=smtp.gmail.com:587
AuthUser=**youremail@gmail.com**
AuthPass=**yourgmailpassword**
UseTLS=YES
UseSTARTTLS=YES

# Where will the mail seem to come from?
rewriteDomain=gmail.com

# The full hostname
hostname=**youremail@gmail.com**

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=YES
```
4. Test that emails are successfully sent using the following command, replacing email addresses as appropriate:
```
ssmtp -v someone@somewhere.com << EMAIL
To: someone@somewhere.com
From: **youremail@gmail.com**
Subject: Test from Moodle server using ssmtp via Gmail

Hello, world.

EMAIL
```

Since your Gmail password is stored in the clear in /etc/ssmtp/ssmtp.conf, 
you should probably secure the file by restricting its read permissions.

## Amazon SES

* You must have an Amazon AWS account (cf. https://aws.amazon.com/).
* Register for the Amazon SES service in order to get 
SES SMTP server authentication details to be able to send emails
(cf. http://docs.aws.amazon.com/ses/latest/DeveloperGuide/Welcome.html).
* Pre-verify any email addresses you want to use for testing on the Amazon SES
(cf. http://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses.html).
Verify both your from and to email addresses or your message will be rejected by the Amazon SES SMTP server.

After verifying that the basic email service works, you need to request access to Amazon SES to send
emails to any address by applying to increase your service limit
(cf. https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html).

### SSMTP configuration with Amazon SES
1. Install ssmtp using the command *apt-get install -y ssmtp*.
2. Edit the file /etc/ssmtp/revaliases and insert the following line, using your own Gmail address:
```
root:admin@moodle.domain.com:email-smtp.eu-west-1.amazonaws.com
www-data:admin@moodle.domain.com:email-smtp.eu-west-1.amazonaws.com
```
3. Edit the file /etc/ssmtp/ssmtp.conf to look like the following, using your own Gmail address and password:
```
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=postmaster

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
mailhub=email-smtp.eu-west-1.amazonaws.com:465
AuthUser=*Amazon SES Username*
AuthPass=*Amazon SES Password*
UseTLS=YES

# Where will the mail seem to come from?
#rewriteDomain=

# The full hostname
hostname=*moodle.domain.com*

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=YES
```
4. Test that emails are successfully sent using the following command, replacing email addresses as appropriate:
```
ssmtp -v success@simulator.amazonses.com << EMAIL
To: success@simulator.amazonses.com
From: *verified@email.com*
Subject: Test from Amazon AMI using Amazon SES with ssmtp

Hello, world.

EMAIL
```

Since your Amazon SES password is stored in the clear in /etc/ssmtp/ssmtp.conf, 
you should probably secure the file by restricting its read permissions.


## References

* [How to Unlock Gmail for a New Email Program or Service](http://email.about.com/od/gmailtips/qt/How-To-Unlock-Gmail-For-A-New-Email-Program-Or-Service.htm)
* [Check your unread Gmail from the command line](http://www.commandlinefu.com/commands/view/3386/check-your-unread-gmail-from-the-command-line)
* [How to send email alerts from Ubuntu Server using ssmtp](cf. http://www.havetheknowhow.com/Configure-the-server/Install-ssmtp.html)
* [Ubuntu email server](https://reidliujun.wordpress.com/2014/07/24/ubuntu-email-server/) How to set up ssmtp with Gmail