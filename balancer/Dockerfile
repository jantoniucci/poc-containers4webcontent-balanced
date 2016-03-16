FROM nginx:1.8

#Install Curl
RUN apt-get update -qq && apt-get -y install curl && apt-get -y install unzip && apt-get -y install wget  

#Download and Install Consul Template
ENV CT_URL https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip
RUN wget $CT_URL 
RUN unzip consul-template_0.14.0_linux_amd64.zip -d /usr/local/bin

#Setup Consul Template Files
RUN mkdir /etc/consul-templates
ENV CT_FILE /etc/consul-templates/nginx.conf

#Setup Nginx File
ENV NX_FILE /etc/nginx/conf.d/app.conf

#Default Variables
ENV CONSUL consul:8500
ENV SERVICE consul-8500

# Command will
# 1. Write Consul Template File
# 2. Start Nginx
# 3. Start Consul Template

CMD echo "upstream app {                                          \n\
  least_conn;                                                     \n\
  {{range service \"$SERVICE\"}}                                  \n\
  server  {{.Address}}:{{.Port}};                                 \n\
  {{else}}server 127.0.0.1:65535;{{end}}                          \n\
}                                                                 \n\
server {                                                          \n\
  listen 80 default_server;                                       \n\
  location / {                                                    \n\
    proxy_pass http://app;                                        \n\
  }                                                               \n\
}" > $CT_FILE; \
/usr/sbin/nginx -c /etc/nginx/nginx.conf \
& CONSUL_TEMPLATE_LOG=debug consul-template \
  -consul=$CONSUL \
  -template "$CT_FILE:$NX_FILE:/usr/sbin/nginx -s reload";