FROM centos:7
MAINTAINER vmzcloud

ENV TZ="Asia/Hong_Kong"
ENV WILDFLY_VERSION 25.0.1.Final
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

RUN yum -y --setopt=tsflags=nodocs install wget
RUN yum clean all

RUN groupadd -r jboss -g 1000
RUN useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss
RUN chmod 755 /opt/jboss

RUN wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz
RUN tar zxvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz
RUN rm OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz

RUN cd $HOME \
    && curl -L -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

EXPOSE 8080

ENV JAVA_HOME=/jdk-11.0.13+8
ENV PATH=$PATH:/jdk-11.0.13+8/bin

RUN /opt/jboss/wildfly/bin/add-user.sh 'admin' -p 'P@ssw0rd'

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
