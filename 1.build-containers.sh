echo -------------------------------------------------
echo 1. Build & publish private images 
echo -------------------------------------------------
echo .
export CONTROL_MACHINE_IP=$(docker-machine ip control)
eval $(docker-machine env control)

echo - Building and Loading balancer
docker build -t localhost:5000/balancer:latest balancer/
docker push localhost:5000/balancer:latest

echo - Building and Loading statics
docker build -t localhost:5000/statics2:latest statics2 && docker push localhost:5000/statics2:latest
docker build -t localhost:5000/statics1:latest statics1 && docker push localhost:5000/statics1:latest
docker build -t localhost:5000/statics0:latest statics0 && docker push localhost:5000/statics0:latest

echo -
echo 1.C Launch registrator
echo -
docker $(docker-machine config control) run -d --name=registrator --volume=/var/run/docker.sock:/tmp/docker.sock localhost:5000/registrator:latest -ip $(docker-machine ip control) consul://$CONTROL_MACHINE_IP:8500
docker $(docker-machine config swarm-master) run -d --name=registrator --volume=/var/run/docker.sock:/tmp/docker.sock $CONTROL_MACHINE_IP:5000/registrator:latest -ip $(docker-machine ip swarm-master) consul://$CONTROL_MACHINE_IP:8500
docker $(docker-machine config swarm-agent1) run -d --name=registrator --volume=/var/run/docker.sock:/tmp/docker.sock $CONTROL_MACHINE_IP:5000/registrator:latest -ip $(docker-machine ip swarm-agent1) consul://$CONTROL_MACHINE_IP:8500
docker $(docker-machine config swarm-agent2) run -d --name=registrator --volume=/var/run/docker.sock:/tmp/docker.sock $CONTROL_MACHINE_IP:5000/registrator:latest -ip $(docker-machine ip swarm-agent2) consul://$CONTROL_MACHINE_IP:8500

echo -
echo 1.D Launch balancer: nginx + consul-template
echo -
docker $(docker-machine config control) run -d -p "80:80" --name balancer -e "CONSUL=$CONTROL_MACHINE_IP:8500" -e "SERVICE=statics0-80" localhost:5000/balancer:latest

echo -
echo 1.E Launch statics
echo -
eval $(docker-machine env --swarm swarm-master)

docker-compose up -d

# echo -------------------------------------------------
# echo 5. UCP install and node joins
# echo -------------------------------------------------
# 
# docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp install -i --swarm-port 3377 --host-address $(docker-machine ip swarm-master)
# 
# eval $(docker-machine env swarm-agent1) && docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join -i --host-address $(docker-machine ip swarm-agent1)
# 
# eval $(docker-machine env swarm-agent2) && docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join -i --host-address $(docker-machine ip swarm-agent2)

