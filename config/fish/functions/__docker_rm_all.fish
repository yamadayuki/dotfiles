function __docker_rm_all --description 'Remove all docker containers, images, or networks'
    if not type -q docker
        echo "docker command not installed"
        return 1
    end

    switch $argv[1]
        case containers
            docker rm -f (docker ps -aq)
        case images
            docker rmi -f (docker images -aq)
        case networks
            docker network rm (docker network ls -q)
    end
end
