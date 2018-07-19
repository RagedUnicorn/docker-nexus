FROM ragedunicorn/openjdk:1.0.2-jdk-stable

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

#     _   __
#    / | / /__  _  ____  _______
#   /  |/ / _ \| |/_/ / / / ___/
#  / /|  /  __/>  </ /_/ (__  )
# /_/ |_/\___/_/|_|\__,_/____/

# image args
ARG NEXUS_USER=nexus
ARG NEXUS_GROUP=nexus

# software versions
ENV \
  NEXUS_VERSION=3.11.0-01 \
  SU_EXEC_VERSION=0.2-r0

ENV \
  SONATYPE_DIR=/opt/sonatype \
  NEXUS_USER="${NEXUS_USER}" \
  NEXUS_GROUP="${NEXUS_GROUP}" \
  NEXUS_HOME=/opt/sonatype/nexus \
  NEXUS_DATA_DIR=/nexus-data \
  SONATYPE_WORK=/opt/sonatype/sonatype-work \
  NEXUS_SHASUM=c9cd1c40861480ab6f36e22f9f69825d3af418d8

# explicitly set user/group IDs
RUN addgroup -S "${NEXUS_GROUP}" -g 9999 && adduser -S -G "${NEXUS_GROUP}" -u 9999 "${NEXUS_USER}"

RUN \
  set -ex; \
  apk add --no-cache su-exec="${SU_EXEC_VERSION}"

# install nexus
RUN \
  set -ex; \
  mkdir -p "${NEXUS_HOME}"; \
  wget -qO nexus.tar.gz "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"; \
  echo "${NEXUS_SHASUM} *nexus.tar.gz" | sha1sum -c -; \
  tar xzf nexus.tar.gz -C "${NEXUS_HOME}" --strip-components=1; \
  rm nexus.tar.gz; \
  chown -R "${NEXUS_USER}":"${NEXUS_GROUP}" "${NEXUS_HOME}"; \
  mkdir -p "${SONATYPE_WORK}"; \
  chown -R "${NEXUS_USER}":"${NEXUS_GROUP}" "${SONATYPE_WORK}"; \
  mkdir -p "${NEXUS_DATA_DIR}" "${NEXUS_DATA_DIR}/etc" "${NEXUS_DATA_DIR}/log" "${NEXUS_DATA_DIR}/tmp"; \
  chown -R "${NEXUS_USER}":"${NEXUS_GROUP}" "${NEXUS_DATA_DIR}"; \
  ln -sf "${NEXUS_DATA_DIR}" "${SONATYPE_WORK}/nexus3"

# add healthcheck script
COPY docker-healthcheck.sh /

# add launch script
COPY docker-entrypoint.sh /

# add configuration for nexus
COPY config/nexus.properties "${SONATYPE_WORK}/nexus3/etc/nexus.properties"

RUN \
  chmod 755 /docker-entrypoint.sh && \
  chmod 755 /docker-healthcheck.sh

VOLUME ["${NEXUS_DATA_DIR}"]

EXPOSE 8081

ENTRYPOINT ["/docker-entrypoint.sh"]
