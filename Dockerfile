# Stage and thin the application 
FROM icr.io/appcafe/open-liberty:full-java21-openj9-ubi-minimal AS staging

COPY --chown=1001:0 target/springboot-crac-demo-0.1.0.jar \
                    /staging/springboot-crac-demo-0.1.0.jar
                    
RUN springBootUtility thin \
 --sourceAppPath=/staging/springboot-crac-demo-0.1.0.jar \
 --targetThinAppPath=/staging/thin-springboot-crac-demo-0.1.0.jar \
 --targetLibCachePath=/staging/lib.index.cache

# Build the image
FROM icr.io/appcafe/open-liberty:kernel-slim-java21-openj9-ubi-minimal

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

LABEL \
  org.opencontainers.image.authors="Unai Mayo" \
  org.opencontainers.image.vendor="IBM" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/OpenLiberty/guide-spring-boot" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="IBM" \
  name="springboot-crac-demo" \
  version="$VERSION-$REVISION" \
  summary="Demo springboot application using JPA and CRaC" \
  description="This image contains a demo springboot application using using JPA and CRaC and running with the WebSphere Liberty runtime."

COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml

RUN features.sh

COPY --chown=1001:0 --from=staging /staging/lib.index.cache /lib.index.cache

COPY --chown=1001:0 --from=staging /staging/thin-springboot-crac-demo-0.1.0.jar \
                    /config/dropins/spring/thin-springboot-crac-demo-0.1.0.jar

RUN configure.sh 

# This script performs an InstantOn checkpoint of the application.
# The application can use beforeAppStart or afterAppStart to do the checkpoint.
# The default is beforeAppStart when not specified
RUN checkpoint.sh afterAppStart