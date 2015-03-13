# ejabberd, confd and supervisord on trusty
FROM markusma/confd:0.8.0
MAINTAINER Markus Mattinen <docker@gamma.fi>

RUN addgroup ejabberd \
 && adduser --system --ingroup ejabberd --home /opt/ejabberd --disabled-login ejabberd \
 && mkdir -p /var/run/ejabberd \
 && chown ejabberd:ejabberd /var/run/ejabberd

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential m4 git libncurses5-dev libssh-dev libyaml-dev libexpat-dev screen \
 && mkdir -p /tmp/erlang \
 && cd /tmp/erlang \
 && curl -sSL http://erlang.org/download/otp_src_R16B03-1.tar.gz > otp_src_R16B03-1.tar.gz \
 && tar xf otp_src_R16B03-1.tar.gz \
 && cd otp_src_R16B03-1 \
 && ./configure \
 && make -j4 \
 && make install \
 && mkdir -p /tmp/ejabberd \
 && cd /tmp/ejabberd \
 && curl -sSL "http://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/13.12/ejabberd-13.12.tgz" > ejabberd-13.12.tgz \
 && tar xf ejabberd-13.12.tgz \
 && cd ejabberd-13.12 \
 && ./configure --enable-user=ejabberd \
 && make -j4 \
 && make install \
 && cd / \
 && rm -rf /tmp/erlang /tmp/ejabberd \
 && apt-get purge -y build-essential m4 git \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && chmod 775 /var/run/screen \
 && mkdir -p /var/run/ejabberd \
 && chown ejabberd:ejabberd /var/run/ejabberd

ADD config/etc/ejabberd /etc/ejabberd
ADD config/etc/confd /etc/confd
ADD config/usr/local/bin /usr/local/bin
ADD config/etc/supervisor/conf.d /etc/supervisor/conf.d

RUN chown -R root:ejabberd /etc/ejabberd

EXPOSE 5222 5269 5280
VOLUME [ "/var/lib/ejabberd", "/usr/local/etc/ssl/private" ]
