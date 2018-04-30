# Vagrant PHP7 

A simple Vagrant LAMP setup running PHP7.

## What's inside?

- Ubuntu 16.04 LTS (Xenial Xerus)
- Vim, Git, Curl, etc.
- Apache
- PHP 7.1 with some extensions
- MySQL 5.7
- Node.js 8 with NPM
- RabbitMQ
- Redis
- Composer
- phpMyAdmin

## How to use

- Clone this repository into your project
- Run ``vagrant up``
- Add the following lines to your hosts file:
````
192.168.100.100 app.dev
192.168.100.100 phpmyadmin.dev
````
- Navigate to ``http://app.dev/`` 
- Navigate to ``http://phpmyadmin.dev/`` (both username and password are 'root')