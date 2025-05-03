FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y \
        php php-cli php-mysql php-mbstring php-xml php-curl php-zip \
        libapache2-mod-php \
        octave nodejs git python3 build-essential \
        openjdk-11-jre openjdk-11-jdk python3-pip curl && \
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

# Ensure install script is executable and run it
RUN chmod +x ./install && ./install

# Expose port and run Apache in foreground
EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
