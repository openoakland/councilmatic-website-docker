# councilmatic-website-docker
Dev environment for Councilmatic website

[image1]: ./imgs/psequel.png "PSequel - New Window"
[image2]: ./imgs/docker_control.png "Docker Control"
[image3]: ./imgs/docker_app.png "Docker App"

## Initial Setup

First, make sure you have Docker installed.  If you do not have Docker installed, download and install it from [here](https://www.docker.com/community-edition).

Once you have Docker installed, you will need to create the following directories and clone the following repos:

1. Councilmatic website docker repo (this repo)
2. Postgres data directory
3. Solr data directory 
4. Councilmatic Django website repo

### 1. Create base Councilmatic directory

Create directory:

```
mkdir -p ~/work/councilmatic
```

### 2. Clone Docker repo

```
cd ~/work/councilmatic
git clone git@github.com:ekkus93/councilmatic-website-docker.git
```

### 3. Make Postgres data directory

```
cd ~/work/councilmatic
mkdir councilmatic-website-data
```

### 4. Make Solr data directory

```
cd ~/work/councilmatic
mkdir councilmatic-solr
```

### 5. Clone Councilmatic Django website repo

```
cd ~/work/councilmatic
git clone https://github.com/openoakland/councilmatic.git
```

### Set up docker-compose.yml

In the councilmatic-website-docker directory, there is a file called 'docker-compose.yml'.  You will need to edit this file with a text editor to update the volume mapping for your computer.  The docker containers will read and write to these directories that you mapped on your host machine.  When you shut down the docker instances, the data should still persist in these directories on your host. 

Open the docker-compose.yml with a text editor and replace "phillipcchin" with your username.

## Starting up the Councilmatic website environment for the first time

You will need to initialize the database and set up django for the first time.

### Start up the Councilmatic website environment

To start the Councilmatic website environment, cd into the councilmatic-website-docker directory and run the following command:
```
docker-compose up
```

You should check the logs for the containers in the output.  Just take a quick look at the output and make sure that there aren't any errors.

### Create database

First, log into the database container:

```
docker exec -it -u postgres `docker ps | grep councilmatic_postgres | cut -f1 -d ' '` bash
```

After you are logged into the container, run the following command:

```
createdb oakland_councilmatic
```

It should run without any errors.  After you're done, run the following command to log out of the container:
```
exit
```

Log into the webserver container:
```
docker exec -it `docker ps | grep councilmatic_website | cut -f1 -d ' '` bash
```

Run the following commands:
```
python manage.py migrate --noinput
python manage.py createcachetable
```

### Create Admin User for the webserver

You should still be logged into the webserver container.  Run the following command to set the username and password for your admin user:
```
python manage.py createsuperuser
```

After you're done, run the following command to log out of the container:
```
exit
```

### Shut down web environment
```
cd ~/work/councilmatic
docker-compose down
```

# Starting up the Councilmatic website environment

To start the Councilmatic website environment, run the following commands:
```
cd ~/work/councilmatic
docker-compose up
```

**_To force downloading the latest version of the docker container:_**
```
docker-compose pull && docker-compose up
```

You should the logs for the containers in the output.  Just take a quick look at the output and make sure that there aren't any errors.

## Stopping the Councilmatic website environment

```
docker-compose down
```

## Logging into the database container

After the Councilmatic website environment is up and running, you can log into the database container with the following command:
```
docker exec -it -u postgres `docker ps | grep councilmatic_postgres | cut -f1 -d ' '` bash
```

## Logging into the webserver container

After the Councilmatic website environment is up and running, you can log into the database container with the following command:
```
docker exec -it `docker ps | grep councilmatic_website | cut -f1 -d ' '` bash
```

## Logging into the solr container

After the Councilmatic website environment is up and running, you can log into the database container with the following command:
```
docker exec -it `docker ps | grep councilmatic_solr | cut -f1 -d ' '` bash
```

You shouldn't really need to log into the solr container though.  You can access the Solr's web admin with the following url:
```
http://localhost:8983/solr/
```

## Connecting to Postgres

There are a couple of different ways in which you can connect to the Postgres database:
1. From the Postgres container 
2. From the webserver container
3. From the host 

### From the Postgres container 

1. Log into the Postgres container (see above)
2. Run the following command:
```
psql -d oakland_councilmatic
```

### From the webserver container

1. Log into the webserver container (see above)
2. Run the following command:
```
psql -U postgres -d oakland_councilmatic -h postgres
```

The password is:
```
str0ng*p4ssw0rd
```

### From the host

The internal port for Postgres on the Postgres container is the default port, 5432.  In the docker-compose.yml, it's mapped to 6432 on the host machine.  (This was changed to deal with issues with people running a Postgres database on their host machine.)

If you're using a Mac, you can download the following app,
[PSequel](http://www.psequel.com/).

When you go to "File/New Window", you should see something like this:
![PSequel - New Window][image1]

To log in remotely to the Postgres database, use the following settings:

Name | Value 
-----|---------------
Host | 127.0.0.1 
Port | 6432
User | postgres  
Password | str0ng*p4ssw0rd 
Database | opencivicdata 

_If you want to set a different password, you can change it in the docker-compose.yml file.  If you change the password, you will also have to change the database password in "councilmatic/councilmatic/settings_deployment.py" for Django otherwise, the webserver will not be able to connect to the database._

If you restarted your webserver environment and cannot connect to the database port, 6432, from your host, try restarting Docker.  See the "Gotchas" section below. 

# Viewing the Website with Your Browser

Port 8000 from the django container is mapped to your host's port 8000.  To view the website with your browser, go to:
```
http://127.0.0.1:8000/
```

# Debugging Django

Port 8001 from the django container is also mapped to your host's port 8001.  You can start a second instance of django by doing the following:

1. Log into the webserver container:

```
docker exec -it `docker ps | grep councilmatic_website | cut -f1 -d ' '` bash
```

2. Manually start a second instance of django on port 8001:
```
python manage.py runserver 0.0.0.0:8001
```

3. Open a browser and go to:
```
http://127.0.0.1:8001
```

4. Check the console for errors in django's logs.

# Gotchas

On Mac OS, Docker Compose has this bug where sometimes it doesn't release the mapped ports after you do "docker-compose down". 

1. Quit Docker from the menu bar:

![Docker Control][image2]

2. Restart it from Applications:

![Docker app][image3]

Docker might take a little while to restart.

3. Try starting up your webserver environment again