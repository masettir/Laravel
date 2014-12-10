#  --------------
# | source image |
#  --------------

FROM centos:centos6

# My info
MAINTAINER Ruddickmg@gmail.com

#  -------------
# | install php |
#  -------------

RUN yum -y install git wget;

# install php and php-fpm
RUN wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm;
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
RUN rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm;
RUN yum -y --enablerepo=remi,remi-php55 -y install php-fpm php-common php-soap php-mysql php-mcrypt php
RUN rm epel-release-6-8.noarch.rpm remi-release-6.rpm

#  ------------------
# | install composer |
#  ------------------

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer;
RUN composer self-update

#  -------------------
# | add shell scripts |
#  -------------------

ADD start.sh /bin/start.sh
RUN chmod +x /bin/start.sh
ADD install.sh /bin/install.sh
RUN chmod +x /bin/install.sh

#  ------------------
# | migrate db files |
#  ------------------

CMD /bin/start.sh
