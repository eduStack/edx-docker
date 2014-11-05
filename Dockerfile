FROM phusion/baseimage
MAINTAINER  eduStack Project "http://eduStack.org"
ENV HOME /root
CMD ["/sbin/my_init --enable-insecure-key"]
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server rsyslog bash sudo openssl ca-certificates build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev libfreetype6-dev python-pip python-apt python-dev
RUN pip install --upgrade pip
RUN pip install --upgrade virtualenv
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
RUN (cd /var/tmp && git clone -b docker_release https://github.com/eduStack/configuration)
RUN (cd /var/tmp/configuration && pip install -r requirements.txt)
RUN ssh root@localhost cd /var/tmp/configuration/playbooks && ansible-playbook -vvvv -c local --limit "localhost:127.0.0.1" -i "localhost," docker_lite.yml
