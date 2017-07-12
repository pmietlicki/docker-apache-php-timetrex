FROM php:7.0-apache

RUN a2enmod rewrite && a2enmod headers

RUN { \
		echo 'deb http://packages.dotdeb.org jessie all'; \
	} >> /etc/apt/sources.list
	
ENV UPDATE true

# install the PHP extensions we need
RUN apt-get update && apt-get install -y --force-yes locales git-core libldb-dev libxslt1.1 libxslt-dev libldap2-dev libcurl4-gnutls-dev libxml2-dev libc-client-dev libkrb5-dev php7.0-cgi php7.0-cli php7.0-pgsql php7.0-pspell php7.0-gd php7.0-gettext php7.0-imap php7.0-intl php7.0-json php7.0-soap php7.0-zip php7.0-mcrypt php7.0-curl php7.0-ldap php7.0-xml php7.0-xsl php7.0-mbstring php7.0-bcmath vim libsqlite3-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev libpq-dev libexif-dev libmcrypt-dev libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

RUN docker-php-ext-configure gd --with-png-dir=/usr --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include \
        && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
        && docker-php-ext-install gd mysqli calendar mcrypt gettext intl exif zip mbstring gettext imap intl json soap curl ldap xml xsl bcmath pdo pdo_mysql pdo_sqlite pdo_pgsql json

ADD https://www.timetrex.com/direct_download/TimeTrex_Community_Edition-manual-installer.zip /tmp/timetrex.zip
RUN if $UPDATE -eq "true"; then unzip -f /tmp/timetrex.zip -d /var/www/html; fi

RUN mkdir -p /var/timetrex/storage
RUN mkdir /var/log/timetrex
RUN chgrp -R www-data /var/timetrex/
RUN chmod 775 -R /var/timetrex
RUN chgrp www-data /var/log/timetrex/
RUN chmod 775 /var/log/timetrex
RUN chgrp www-data -R /var/www/html

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
RUN { \
		echo 'date.timezone=Pacific/Noumea'; \
	} > /usr/local/etc/php/conf.d/timezone.ini

RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
locale-gen && \
update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR LC_ALL=fr_FR.UTF-8 && \
export LANG=fr_FR.UTF-8 LANGUAGE=fr_FR LC_ALL=fr_FR.UTF-8

ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR \
    LC_ALL=fr_FR.UTF-8

VOLUME /var/www/html
