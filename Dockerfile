from ubuntu:12.04.5
maintainer  eduStack Project "http://eduStack.org"
run apt-get update
run apt-get upgrade -y
run apt-get install -y bash sudo openssl ca-certificates build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev libfreetype6-dev python-pip python-apt python-dev
run pip install --upgrade pip
run pip install --upgrade virtualenv
run (cd /var/tmp && git clone -b docker_release https://github.com/eduStack/configuration)
run (cd /var/tmp/configuration && pip install -r requirements.txt)
workdir /var/tmp/configuration/playbooks
run ansible-playbook -vv -c local -i inventory.ini docker_lite.yml -e 'validate_certs=no'
