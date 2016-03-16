docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp install -i --swarm-port 3377 --host-address $(docker-machine ip swarm-master)

eval $(docker-machine env swarm-agent1) && docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join -i --host-address $(docker-machine ip swarm-agent1)

eval $(docker-machine env swarm-agent2) && docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join -i --host-address $(docker-machine ip swarm-agent2)