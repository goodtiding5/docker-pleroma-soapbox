#!/bin/ash

set -e

WORKDIR=/opt/pleroma
DATADIR=/var/lib/pleroma
INSTDIR=/opt/pleroma/instance
SOAPBOX_FE_VERSION=${SOAPBOX_FE_VERSION:-latest}

PATH=$PATH:$WORKDIR/bin; export PATH

[ -d $DATADIR/static ]	|| mkdir -p $DATADIR/static
[ -d $DATADIR/uploads ]	|| mkdir -p $DATADIR/uploads

chown -R pleroma:pleroma $DATADIR

FLAGFILE="$INSTDIR/.soapbox_${SOAPBOX_FE_VERSION}_ready"
if [ ! -f $FLAGFILE ]; then
    unzip -q -o $WORKDIR/dist/soapbox-fe.zip -d $INSTDIR
    touch $FLAGFILE
    chown -R pleroma:pleroma $INSTDIR
fi

if [[ -t 0 || -p /dev/stdin ]]; then
    # we have an interactive session
    export PS1='[\u@\h : \w]\$ '
    if [[ $@ ]]; then
	eval "exec $@"
    else
	exec /bin/sh
    fi
else
    if [[ $@ ]]; then
	eval "exec $@"
    else
	exec su-exec pleroma /usr/local/bin/start_pleroma.sh
    fi
fi

# Will never reach here
exit 0



