# =============================================================================
# Local Development Docker DB Commands (pg, redis, mongo)
# Ported from config/fish/functions/pg.fish, redis.fish, mongo.fish
# =============================================================================

# -----------------------------------------------------------------------------
# PostgreSQL (the-postgres)
# -----------------------------------------------------------------------------
const PG_NAME = "the-postgres"
const PG_IMAGE = "postgres:16-alpine"

export def "pg start" [] {
    print "==> Starting PostgreSQL server"
    let started = (do -i { docker start $PG_NAME } | complete)
    if $started.exit_code != 0 {
        docker run -p 5432:5432 --name $PG_NAME -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_HOST_AUTH_METHOD=trust -v the-postgres:/var/lib/postgresql/data -d $PG_IMAGE
    }

    print "==> Waiting for ready..."
    loop {
        sleep 2sec
        let ping = (do -i { docker exec -it $PG_NAME psql --username=postgres -c 'select 1;' } | complete)
        if $ping.exit_code == 0 {
            print "\nready"
            break
        } else {
            print -n "."
        }
    }
}

export def "pg stop" [] {
    print "==> Stopping PostgreSQL server"
    docker stop $PG_NAME
}

export def "pg destroy" [] {
    print "==> Destroying PostgreSQL server"
    docker rm -f $PG_NAME
}

export def "pg logs" [] {
    docker logs -f $PG_NAME
}

export def "pg status" [] {
    let running = (do -i { docker ps | grep $PG_NAME } | complete)
    if $running.exit_code == 0 {
        let ping = (do -i { docker exec -it $PG_NAME psql --username=postgres -c 'select 1;' } | complete)
        if $ping.exit_code == 0 {
            print "ready"
        } else {
            print "not ready"
        }
    } else {
        print "not running"
    }
}

export def "pg createdb" [dbname: string] {
    docker exec -it $PG_NAME createdb --username=postgres $dbname
}

export def "pg psql" [...args: string] {
    docker exec -it $PG_NAME psql --username=postgres ...$args
}

export def pg [] {
    print "Usage: pg <start|stop|destroy|status|logs|createdb <dbname>|psql ...>"
}

# -----------------------------------------------------------------------------
# Redis (the-redis)
# -----------------------------------------------------------------------------
const REDIS_NAME = "the-redis"
const REDIS_IMAGE = "redis:alpine"

export def "redis start" [] {
    print "==> Starting Redis server"
    let started = (do -i { docker start $REDIS_NAME } | complete)
    if $started.exit_code != 0 {
        let dir = ($nu.home-dir | path join "docker" "redis")
        mkdir $dir
        docker run -p 6379:6379 --name $REDIS_NAME -v $"($dir):/data" -d $REDIS_IMAGE
    }
}

export def "redis stop" [] {
    print "==> Stopping Redis server"
    docker stop $REDIS_NAME
}

export def "redis destroy" [] {
    print "==> Destroying Redis server"
    docker rm -f $REDIS_NAME
}

export def "redis logs" [] {
    docker logs -f $REDIS_NAME
}

export def "redis cli" [] {
    docker exec -it $REDIS_NAME redis-cli
}

export def redis [] {
    print "Usage: redis <start|stop|destroy|logs|cli>"
}

# -----------------------------------------------------------------------------
# MongoDB (the-mongo)
# -----------------------------------------------------------------------------
const MONGO_NAME = "the-mongo"
const MONGO_IMAGE = "mongo:4.2.2-bionic"

export def "mongo start" [] {
    print "==> Starting MongoDB server"
    let started = (do -i { docker start $MONGO_NAME } | complete)
    if $started.exit_code != 0 {
        let dir = ($nu.home-dir | path join "docker" "mongo")
        mkdir $dir
        docker run -p 27017:27017 --name $MONGO_NAME -v $"($dir):/data" -d $MONGO_IMAGE
    }
}

export def "mongo stop" [] {
    print "==> Stopping MongoDB server"
    docker stop $MONGO_NAME
}

export def "mongo destroy" [] {
    print "==> Destroying MongoDB server"
    docker rm -f $MONGO_NAME
}

export def "mongo logs" [] {
    docker logs -f $MONGO_NAME
}

export def "mongo cli" [] {
    docker exec -it $MONGO_NAME mongo
}

export def mongo [] {
    print "Usage: mongo <start|stop|destroy|logs|cli>"
}
