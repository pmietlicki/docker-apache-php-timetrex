FROM debian:buster

RUN apt-get update && apt-get install -y --force-yes apache2

RUN a2enmod rewrite && a2enmod headers
	
ENV UPGRADE true

# install the PHP extensions we need
RUN apt-get update && apt-get install -y --force-yes locales git libldb-dev unzip libxslt1.1 libxslt1-dev libldap2-dev libcurl4-gnutls-dev libxml2-dev libc-client-dev libkrb5-dev php7.3-cgi php7.3-cli php7.3-pgsql php7.3-pspell php7.3-gd php7.3-imap php7.3-intl php7.3-json php7.3-soap php7.3-zip php7.3-curl php7.3-ldap php7.3-xml php7.3-xsl php7.3-mbstring php7.3-bcmath vim libsqlite3-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpq-dev libexif-dev libmcrypt-dev libjpeg-dev && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

ADD https://www.timetrex.com/direct_download/TimeTrex_Community_Edition-manual-installer.zip /tmp/timetrex.zip
RUN if ${UPGRADE} -eq "true"; then unzip -f /tmp/timetrex.zip -d /var/www/html; fi

RUN mkdir -p /var/timetrex/storage
RUN mkdir /var/log/timetrex
RUN chgrp -R www-data /var/timetrex/
RUN chmod 775 -R /var/timetrex
RUN chgrp www-data /var/log/timetrex/
RUN chmod 775 /var/log/timetrex
RUN chgrp www-data -R /var/www/html

RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
locale-gen && \
update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR LC_ALL=fr_FR.UTF-8 && \
export LANG=fr_FR.UTF-8 LANGUAGE=fr_FR LC_ALL=fr_FR.UTF-8

ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR \
    LC_ALL=fr_FR.UTF-8

VOLUME /var/www/html
