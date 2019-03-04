#!/bin/bash
#docker run -p 80:8080 -e SWAGGER_JSON=/TASk/1.yaml -v /Users/nrm/Sources/mdpm/projects/TASk/etc/data:/TASk swaggerapi/swagger-ui
docker run -p 80:8080 -e SWAGGER_JSON=/TASk/1.tweaked.yaml -v /Users/nrm/Sources/mdpm/projects/TASk/etc/data:/TASk swaggerapi/swagger-ui
