FROM python:3.6-jessie
MAINTAINER Phil Chin <ekkus93@gmail.com>

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install wget screen -y
RUN apt-get install lsb-core -y

# postgres client
RUN apt-get install postgresql-client -y

# jdk
RUN apt-get install openjdk-7-jre-headless -y

#emacs
# update again otherwise emacs might fail to install
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install emacs -y --fix-missing

# text editors
RUN apt-get install vim nano -y

# lynx
RUN apt-get install lynx -y

# telnet
RUN apt-get install telnet -y

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./version.txt /tmp/version.txt

RUN useradd -ms /bin/bash django
RUN mkdir -p /home/django/councilmatic && chown django /home/django/councilmatic
RUN chown -R django /usr/local/lib/python3.6/site-packages/councilmatic_core

VOLUME ["/home/django/councilmatic"]

USER django

WORKDIR /home/django/councilmatic

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

EXPOSE 8000 8001



