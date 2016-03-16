# Set the base image to Ubuntu
FROM nginx

# File Author / Maintainer
MAINTAINER javier.antoniucci@gmail.com

# Copy custom configuration file from the current directory
COPY nginx.conf /etc/nginx/nginx.conf
COPY html /usr/share/nginx/html

# Exposes HTTP port
EXPOSE 80

