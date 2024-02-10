# Set up PostgreSQL on Your Raspberry Pi

## Motivation

Databases are indispensable pieces of software that allow services to store and access data. I use [PostgreSQL](https://www.postgresql.org/) primarily because it's what I'm most familiar with, but it's also the most popular database technology according to Stack Overflow's [Developer Survey](https://survey.stackoverflow.co/2023/#section-most-popular-technologies-databases) -- so it's a good tool to keep in the toolbelt.

## Install and Configure PostgreSQL

1. Install PostgreSQL by running
    ```
    me@zero:~$ sudo apt install postgresql
    ```
2. Once installed, we need to set a password for the default `postgres` user by connecting to the default template database and configuring the user
    ```
    me@zero:~$ sudo -u postgres psql template1
    could not change directory to "/home/x": Permission denied
    psql (15.5 (Ubuntu 15.5-0ubuntu0.23.10.1))
    Type "help" for help.

    template1=# ALTER USER postgres with encrypted password 'your_password';
    ALTER ROLE
    ```
3. We can now connect to our `postgres` instance locally and allow our applications to read and write to their own databases
    ```
    me@zero:~$ psql --host 127.0.0.1 --username postgres
    Password for user postgres:
    psql (15.5 (Ubuntu 15.5-0ubuntu0.23.10.1))
    SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
    Type "help" for help.

    postgres=#
    ```
