# Vagrant PHP7 

A simple Vagrant LAMP setup running PHP7.

## What's inside?

- Ubuntu 14.04.3 LTS (Trusty Tahr)
- Vim, Git, Curl, etc.
- Apache
- PHP7 with some extensions
- MySQL 5.6
- Node.js with NPM
- RabbitMQ
- Redis
- Composer
- phpMyAdmin

## How to use

- Clone this repository into your project
- Run ``vagrant up``
- Add the following lines to your hosts file:
````
192.168.100.100 app.local
192.168.100.100 phpmyadmin.local
````
- Navigate to ``http://app.local/`` 
- Navigate to ``http://phpmyadmin.local/`` (both username and password are 'root')
