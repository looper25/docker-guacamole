FROM ubuntu:14.04
MAINTAINER Boggart <github.com/Boggart>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
  supervisor wget make tomcat7 \
  libcairo2-dev libpng12-dev uuid libossp-uuid-dev \
  libfreerdp-dev freerdp-x11 libpango-1.0-0 libpango1.0-dev \
  libssh2-1 libssh2-1-dev libssh-dev libtelnet-dev libvncserver-dev \
  libpulse-dev libssl1.0.0 gcc libvorbis-dev

RUN wget -O guacamole-0.9.9.war http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-0.9.9.war/download && \
  wget -O guacamole-server-0.9.9.tar.gz http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-0.9.9.tar.gz/download && \
  tar -xzf guacamole-server-0.9.9.tar.gz && \
  cp guacamole-0.9.9.war /var/lib/tomcat7/webapps/guacamole.war && \
  cd guacamole-server-0.9.9 && \
  ./configure --with-init-dir=/etc/init.d && \
  make && \
  make install && \
  update-rc.d guacd defaults && \
  ldconfig && \
  mkdir /usr/share/tomcat7/.guacamole && \
  mkdir -p /etc/guacamole /var/lib/guacamole/classpath && \
  ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat7/.guacamole
  
ADD ./config/guacamole.properties /etc/guacamole/
ADD ./config/user-mapping.xml /etc/guacamole/
ADD ./supervisor/supervisor.conf /etc/supervisor/supervisor.conf
ADD ./supervisor/guacamole.sv.conf /etc/supervisor/conf.d/
ADD ./supervisor/tomcat7.sv.conf /etc/supervisor/conf.d/

ENV CATALINA_BASE /var/lib/tomcat7
ENV CATALINA_HOME /usr/share/tomcat7
ENV GUACAMOLE_HOME /etc/guacamole

EXPOSE 8080 
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf"]
