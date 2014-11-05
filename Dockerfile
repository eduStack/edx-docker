FROM ubuntu:14.04.1
RUN apt-get update && apt-get install -y curl
RUN curl -sSL https://get.docker.com/ | sh
ENV HOME /root
RUN (cd /var/tmp && git clone -b docker_release https://github.com/eduStack/configuration)
RUN docker run -i -t -d -v /var/tmp/configuration:/configuration phusion/baseimage /sbin/my_init --enable-insecure-key
RUN docker inspect -f "{{ .NetworkSettings.IPAddress }}" `docker ps | cut -c1-20 | awk 'NR==2 {print}'` >IP
RUN curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/insecure_key
RUN chmod 600 insecure_key
RUN ssh -i insecure_key root@`cat IP` apt-get update
RUN ssh -i insecure_key root@`cat IP` apt-get upgrade -y && apt-get install -y openssl ca-certificates build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev libfreetype6-dev python-pip python-apt python-dev
RUN ssh -i insecure_key root@`cat IP` pip install --upgrade pip && pip install --upgrade virtualenv
RUN ssh -i insecure_key root@`cat IP` cd /configuration && pip install -r requirements.txt
RUN ssh -i insecure_key root@`cat IP` cd /configuration/playbooks && ansible-playbook -vv -c local -i "127.0.0.1," docker_lite.yml
