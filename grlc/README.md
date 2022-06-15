# Default grlc server for the FDP

This is optional, and can be run in-parallel with the FAIR in a box.  It will connect to the F-i-a-b GraphDB network, and attempt to query the 
CDE database using the username/password indicated in `config.ini`

For example, to run it over the World Duchenne Organization's set of queries in gitHub, you would start this docker compose (with your GitHub access token in the `docker-compose.yml`) then surf to:

http://localhost:8088/api-local/queries

You should see a Swagger interface for your queries.


# How to initialize the grlc-queries folder

note that grlc-queries is a Git submodule of https://github.com/World-Duchenne-Organization/grlc-queries

To initialize it and fill it with the queries, you need to
```
      $ cd grlc-queries
      $ git submodule init
      $ git submodule update
```

      