FROM alpine:3.21@sha256:b97e2a89d0b9e4011bb88c02ddf01c544b8c781acf1f4d559e7c8f12f1047ac3
LABEL   \
        org.label-schema.name="cnf/ipsec" \
        org.label-schema.vendor="Travelping GmbH" \
        org.label-schema.description="Creates IPSEC connections to other sites or hosts using Strongswan" \
        org.label-schema.url="https://github.com/openvnf/vnf-ipsec" \
        org.label-schema.vcs-url="https://github.com/openvnf/vnf-ipsec" \
        maintainer="juergen.krutzler@travelping.com"

COPY MANIFEST /root/MANIFEST

RUN apk update && apk upgrade --no-cache  && ( cat /root/MANIFEST | xargs apk add)
RUN mkdir -p /etc/ipsec.secrets.d && \
        mkdir -p /etc/ipsec.config.d && \
        mkdir -p /etc/confd/conf.d && \
        mkdir -p /etc/confd/templates && \
        mkdir -p /etc/confd/conf.d.disabled

RUN wget -O confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 && \
        echo "255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334  confd" | sha256sum -c - && \
        mv confd /usr/local/bin/ && \
        chmod +x /usr/local/bin/confd

COPY files/ipsec.conf /etc/ipsec.conf
COPY files/ipsec.secrets /etc/ipsec.secrets
COPY config/*.tmpl /etc/confd/templates/
COPY files/strongswan.psk-template.config.toml /etc/confd/conf.d.disabled/
COPY files/strongswan.psk-template.secret.toml /etc/confd/conf.d.disabled/
COPY files/charon.conf.toml /etc/confd/conf.d.disabled/
COPY config/*.conf /etc/strongswan.d/charon/
COPY files/start-strongswan.sh /usr/local/bin
COPY files/freeze_apk_versions /usr/local/bin

ENTRYPOINT ["/usr/local/bin/start-strongswan.sh"]
