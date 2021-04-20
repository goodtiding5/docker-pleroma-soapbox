FROM alpine:3

LABEL maintainer="ken@epenguin.com"

ARG FLAVOUR=amd64-musl

ARG UID=1000
ARG GID=1000
ARG HOME=/opt/pleroma
ARG DATA=/var/lib/pleroma
ARG SOAPBOX=v1.2.3

ENV DOMAIN=localhost \
    INSTANCE_NAME="Pleroma" \
    ADMIN_EMAIL="admin@localhost" \
    NOTIFY_EMAIL="info@localhost" \
    DB_HOST="db" \
    DB_NAME="pleroma" \
    DB_USER="pleroma" \
    DB_PASS="pleroma" \
    SOAPBOX_FE_VERSION=$SOAPBOX

RUN set -eux \
&&  echo "http://nl.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
&&  apk --update add --no-cache tini su-exec ncurses postgresql-client imagemagick ffmpeg exiftool libmagic \
&&  addgroup --gid "$GID" pleroma \
&&  adduser --disabled-password --gecos "Pleroma" --home "$HOME" --ingroup pleroma --uid "$UID" pleroma \
&&  wget -q -O /tmp/pleroma.zip "https://git.pleroma.social/api/v4/projects/2/jobs/artifacts/stable/download?job=$FLAVOUR" \
&&  unzip -q /tmp/pleroma.zip -d /tmp/ \
&&  (cd /tmp/release; mv * ${HOME}) \
&&  mkdir -p ${HOME}/dist \
&&  wget -q -O ${HOME}/dist/soapbox-fe.zip "https://gitlab.com/soapbox-pub/soapbox-fe/-/jobs/artifacts/$SOAPBOX_FE_VERSION/download?job=build-production"  \
&&  chown -R pleroma:pleroma ${HOME} \
&&  mkdir -p /etc/pleroma \
&&  wget -q -O /etc/pleroma/config.exs "https://git.pleroma.social/pleroma/pleroma/-/raw/stable/config/docker.exs" \
&&  chown -R pleroma:0 /etc/pleroma \
&&  mkdir -p ${DATA}/uploads ${DATA}/static \
&&  chown -R pleroma:pleroma ${DATA} \
&&  ln -f -s ${DATA} ${HOME}/instance

COPY ./bin /usr/local/bin
COPY ./entrypoint.sh /entrypoint.sh

VOLUME $DATA

EXPOSE 4000

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=10m \
    --interval=5m \ 
    CMD curl --fail http://localhost:4000/api/v1/instance || exit 1

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
