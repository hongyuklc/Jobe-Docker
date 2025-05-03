FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
        php php-cli php-mysql php-mbstring php-xml php-curl php-zip \
        libapache2-mod-php \
        octave nodejs git python3 build-essential \
        openjdk-11-jre openjdk-11-jdk python3-pip curl wget && \
    apt-get clean

# Install pylint and set config
RUN pip3 install pylint && \
    pylint --reports=no --generate-rcfile > /etc/pylintrc

# Copy jobe source files
ADD ./jobe /var/www/html/jobe/
WORKDIR /var/www/html/jobe/

# Apache setup
RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
    a2enconf fqdn

# Ensure python -> python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Patch: Add missing readoptarg.c for runguard to build
RUN mkdir -p /var/www/html/jobe/runguard && \
    wget -O /var/www/html/jobe/runguard/readoptarg.c https://raw.githubusercontent.com/trampgeek/jobe/master/runguard/readoptarg.c

# Make install script executable
RUN chmod +x ./install

# Expose port
EXPOSE 80

# Run install at container startup, then launch Apache
CMD ["/bin/bash", "-c", "service apache2 start && ./install && apache2ctl -D FOREGROUND"]
