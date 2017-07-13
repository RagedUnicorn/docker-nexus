FROM ragedunicorn/java:1.0.0-stable

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>" \
  com.ragedunicorn.version="1.0"

#     _   __
#    / | / /__  _  ____  _______
#   /  |/ / _ \| |/_/ / / / ___/
#  / /|  /  __/>  </ /_/ (__  )
# /_/ |_/\___/_/|_|\__,_/____/


ENV \
  NEXUS_VERSION=3.4.0-02 \
  SU_EXEC_VERSION=0.2-r0 \
  CURL_VERSION=7.54.0-r0

ENV \
  SONATYPE_DIR=/opt/sonatype \
  NEXUS_USER=nexus \
  NEXUS_GROUP=nexus \
  NEXUS_HOME=/opt/sonatype/nexus \
  NEXUS_DATA_DIR=/nexus-data \
  SONATYPE_WORK=/opt/sonatype/sonatype-work

# explicitly set user/group IDs
RUN addgroup -S "${NEXUS_GROUP}" -g 9999 && adduser -S -G "${NEXUS_GROUP}" -u 9999 "${NEXUS_USER}"

RUN \
  set -ex; \
  apk add --no-cache su-exec="${SU_EXEC_VERSION}"

  # install nexus
RUN \
  set -ex; \
  apk add --no-cache \
    curl="${CURL_VERSION}"; \
  mkdir -p "${NEXUS_HOME}"; \
  curl --location --retry 3 \
    -o nexus.tar.gz "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"; \
  tar xzf nexus.tar.gz -C "${NEXUS_HOME}" --strip-components=1; \
  rm nexus.tar.gz; \
  chown -R "${NEXUS_USER}":"${NEXUS_GROUP}" "${NEXUS_HOME}"

# add launch script
COPY docker-entrypoint.sh /

# add configuration for nexus
COPY conf/nexus.properties "${SONATYPE_WORK}/nexus3/etc/nexus.properties"

RUN \
  chown -R "${NEXUS_USER}":"${NEXUS_GROUP}" "${SONATYPE_WORK}"; \
  chmod 755 docker-entrypoint.sh; \
  ln -sf "${NEXUS_DATA_DIR}" "${SONATYPE_WORK}/nexus3" \

VOLUME "${NEXUS_DATA_DIR}"

EXPOSE 8081

CMD ["/bin/sh"]
