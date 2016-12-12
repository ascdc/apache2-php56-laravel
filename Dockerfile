FROM ubuntu:trusty
MAINTAINER ASCDC <asdc.sinica@gmail.com>

ADD run.sh /run.sh
ADD locale.gen /etc/locale.gen
ADD locale-archive /usr/lib/locale/locale-archive
ADD set_root_pw.sh /set_root_pw.sh

RUN DEBIAN_FRONTEND=noninteractive && \
	chmod +x /*.sh && \
	apt-get update && \
	apt-get -y install -y locales software-properties-common python-software-properties openssh-server pwgen wget curl vim git && \
	mkdir -p /var/run/sshd && \
	sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
	sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
	sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
	echo "cd /var/www/html" >> /root/.profile && \
	echo "alias ll='ls -al'" >> /root/.profile && \
	echo "export LANG=zh_TW.UTF-8" >> /root/.profile && \ 
	echo "export LANGUAGE=zh_TW" >> /root/.profile && \
	echo "export LC_ALL=zh_TW.UTF-8" >> /root/.profile && \
	echo "export PATH=$PATH:/root/.composer/vendor/bin" >> /root/.profile && \
	echo "export NVM_DIR=/root/.nvm" >> /root/.profile && \
	echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"" >> /root/.profile && \
	locale-gen zh_TW.UTF-8 && \
	dpkg-reconfigure locales && \
	export LANG=zh_TW.UTF-8 && \
	add-apt-repository -y ppa:ondrej/php && \
	add-apt-repository -y ppa:ondrej/apache2

RUN DEBIAN_FRONTEND=noninteractive && apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y apache2 php5.6 php5.6-common php5.6-json php5.6-opcache php5.6-zip php5.6-mysql php5.6-phpdbg php5.6-gd php5.6-imap php5.6-ldap php5.6-pgsql php5.6-pspell php5.6-recode php5.6-tidy php5.6-dev php5.6-intl php5.6-curl php5.6-mcrypt php5.6-xmlrpc php5.6-xsl php5.6-bz2 php5.6-mbstring pkg-config libmagickwand-dev imagemagick build-essential libsasl2-dev libpcre3-dev libapache2-mod-php5 && \
	echo 'autodetect'|pecl install imagick uploadprogress memcache mongodb-1.1.0 && \
	echo "extension=imagick.so" | sudo tee /etc/php/5.6/mods-available/imagick.ini && \
	echo "extension=uploadprogress.so" | sudo tee /etc/php/5.6/mods-available/uploadprogress.ini && \
	echo "extension=memcache.so" | sudo tee /etc/php/5.6/mods-available/memcache.ini && \
	echo "extension=mongodb.so" | sudo tee /etc/php/5.6/mods-available/mongodb.ini && \
	ln -sf /etc/php/5.6/mods-available/imagick.ini /etc/php/5.6/apache2/conf.d/20-imagick.ini && \
	ln -sf /etc/php/5.6/mods-available/uploadprogress.ini /etc/php/5.6/apache2/conf.d/20-uploadprogress.ini && \
	ln -sf /etc/php/5.6/mods-available/memcache.ini /etc/php/5.6/apache2/conf.d/20-memcache.ini && \
	ln -sf /etc/php/5.6/mods-available/mongodb.ini /etc/php/5.6/apache2/conf.d/20-mongodb.ini && \
	ln -sf /etc/php/5.6/mods-available/imagick.ini /etc/php/5.6/cli/conf.d/20-imagick.ini && \
	ln -sf /etc/php/5.6/mods-available/uploadprogress.ini /etc/php/5.6/cli/conf.d/20-uploadprogress.ini && \
	ln -sf /etc/php/5.6/mods-available/memcache.ini /etc/php/5.6/cli/conf.d/20-memcache.ini && \
	ln -sf /etc/php/5.6/mods-available/mongodb.ini /etc/php/5.6/cli/conf.d/20-mongodb.ini && \
	ln -s ../mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
	wget -qO /usr/local/bin/composer https://getcomposer.org/composer.phar && \
	chmod 755 /usr/local/bin/composer && \
	export PATH=$PATH:/root/.composer/vendor/bin && \
	composer global require "laravel/installer" && \
	mkdir /var/www/html/public && \
	mv /var/www/html/*.html /var/www/html/public && \
	sed -i "s/DocumentRoot.*/DocumentRoot \/var\/www\/html\/public/g" /etc/apache2/sites-available/000-default.conf && \
	sed -i "s/<\/VirtualHost>/\t<Directory \"\/var\/www\/html\/public\">\n\t\tAllowOverride All\n\t<\/Directory>\n<\/VirtualHost>/g" /etc/apache2/sites-available/000-default.conf && \
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash && \
	export NVM_DIR="/root/.nvm" && \
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
	nvm install v6.9.2 && \
	nvm use v6.9.2

ENV LANG zh_TW.UTF-8  
ENV LANGUAGE zh_TW
ENV LC_ALL zh_TW.UTF-8
ENV AUTHORIZED_KEYS **None**
ENV NVM_DIR /root/.nvm
	
EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/run.sh"]
