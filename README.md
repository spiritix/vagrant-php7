# Vagrant PHP7 by Fersacom

A simple Vagrant devops LAMP setup running PHP7 on Ubuntu 14.04

## What's inside?

- Ubuntu 14.04.3 LTS (Trusty Tahr)
- Vim, Git, Curl, etc.
- Apache
- PHP7 with some extensions
- MySQL 5.6
- Node.js with NPM
- RabbitMQ
- Redis
- Elasticsearch 2.0
- Composer
- phpMyAdmin
- Symfony installer
- Symfony apache site

## How to use

- Clone this repository into your project
- Run ``vagrant up``
- Add the following lines to your hosts file:
````
192.168.100.100 app.dev
192.168.100.100 symfony.dev
````
- Navigate to ``http://app.dev/`` 
- Navigate to ``http://symfony.dev/`` 
