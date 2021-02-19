# sillywebsite
FROM registry.access.redhat.com/ubi8/ubi:8.0

LABEL Component="httpd" \
      Name=sillywebsite" \
      Version="1.0" \
      Release="1" \
      io.k8s.description="A basic Apache HTTP Server S2I builder image" \
      io.k8s.display-name="Apache HTTP Server S2I builder image for DO288 Exam Section 2" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,httpd,httpd24"

# Apache HTTP Server DocRoot
ENV DOCROOT /var/www/html

RUN yum install -y --nodocs --disableplugin=subscription-manager httpd && \
    yum clean all --disableplugin=subscription-manager -y && \
    sed -i "s/Listen 80/Listen 8080/g" /etc/httpd/conf/httpd.conf

# Copy the S2I scripts to /usr/libexec/s2i, since the image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

ENV APP_DIRS /var/www/ /run/httpd/ /etc/httpd/logs/ /var/log/httpd/

# TODO: Drop the root user and make the content of APP_DIRS owned by user 1001
RUN chown -R 1001:1001 $APP_DIRS && \
    chgrp -r 0 $APP_DIRS && \
    chmod -R g=u $APP_DIRS && \
    chmod +x /usr/libexec/s2i/assemble /usr/libexec/s2i/run /usr/libexec/s2i/usage

# This default user is created in the rhel7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
