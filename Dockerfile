FROM ubuntu:12.04.5
MAINTAINER eduStack Project "http://edustack.org"
RUN apt-get update
RUN apt-get install -y curl
RUN curl https://get.docker.io/builds/Linux/x86_64/docker-latest -o /usr/local/bin/docker
RUN chmod +x /usr/local/bin/docker
ENV HOME /root
RUN git clone -b docker_release https://github.com/appsembler/configuration
RUN docker -H unix:///docker.sock run -i -t -d -v /configuration:/configuration phusion/baseimage /sbin/my_init --enable-insecure-key
RUN IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" `docker ps | cut -c1-20 | awk 'NR==2 {print}'`)
RUN curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/insecure_key
RUN chmod 600 insecure_key
RUN ssh -i insecure_key root@$IP apt-get update && apt-get install -y python-dev python-setuptools python-apt gcc && easy_install pip
RUN ssh -i insecure_key root@$IP cd /configuration && pip install -r requirements.txt
RUN ssh -i insecure_key root@$IP cd /configuration/playbooks && ansible-playbook -vv -c local -i "127.0.0.1," docker_lite.yml
