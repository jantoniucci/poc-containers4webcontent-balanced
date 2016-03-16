echo -------------------------------------------------
echo 1. Creating a Control machine
echo -------------------------------------------------
docker-machine create -d virtualbox control

echo "  - List machines"
docker-machine ls

eval $(docker-machine env control)
export CONTROL_MACHINE_IP=$(docker-machine ip control)

echo "-"
echo "1.A Launching Consul"
echo "-"
docker $(docker-machine config control) run -d -p "8500:8500" -h "consul" progrium/consul -server -bootstrap

echo "-"
echo "1.B Launching Registry"
echo "-"
docker $(docker-machine config control) run -dit -p "5000:5000" -v /tmp/registry:/tmp/registry -e GUNICORN_OPTS='["--preload"]' --restart=always --name=registry registry

echo "-"
echo "1.C Loagin base images to Registry"
echo "-"
docker pull gliderlabs/registrator
docker tag gliderlabs/registrator localhost:5000/registrator
docker push localhost:5000/registrator

docker tag progrium/consul localhost:5000/consul
docker push localhost:5000/consul

echo -------------------------------------------------
echo 2. Creating Swarm machines & declare insecure registry <<< TBD
echo -------------------------------------------------
echo   - master
docker-machine create -d virtualbox --swarm --swarm-master --swarm-discovery="consul://$CONTROL_MACHINE_IP:8500" --engine-opt="cluster-store=consul://$CONTROL_MACHINE_IP:8500" --engine-opt="cluster-advertise=eth1:2376" --engine-insecure-registry $CONTROL_MACHINE_IP:5000 swarm-master
echo   - agent 1
docker-machine create -d virtualbox --swarm --swarm-discovery="consul://$CONTROL_MACHINE_IP:8500" --engine-opt="cluster-store=consul://$CONTROL_MACHINE_IP:8500" --engine-opt="cluster-advertise=eth1:2376" --engine-insecure-registry $CONTROL_MACHINE_IP:5000 swarm-agent1
echo   - agent 2
docker-machine create -d virtualbox --swarm --swarm-discovery="consul://$CONTROL_MACHINE_IP:8500" --engine-opt="cluster-store=consul://$CONTROL_MACHINE_IP:8500" --engine-opt="cluster-advertise=eth1:2376" --engine-insecure-registry $CONTROL_MACHINE_IP:5000 swarm-agent2
echo   - List machines
docker-machine ls
echo   - Docker info
eval $(docker-machine env --swarm swarm-master)
docker info

