FROM cmangos-builder:latest AS builder

ARG CMANGOS_CORE=classic
ARG CORE_COMMIT_HASH=HEAD
ARG DB_COMMIT_HASH=HEAD
ARG BUILD_PLAYERBOT=OFF
ARG BUILD_AHBOT=OFF
ARG BUILD_METRICS=OFF


RUN mkdir -p /opt/src && \
	git clone https://github.com/davidonete/mangos-${CMANGOS_CORE}.git -b modules /opt/src/cmangos && \
	if [ "$CORE_COMMIT_HASH" != "HEAD" ]; then cd /opt/src/cmangos; git checkout ${CORE_COMMIT_HASH}; fi

RUN mkdir -p /opt/src && \
	git clone https://github.com/cmangos/${CMANGOS_CORE}-db.git /opt/src/database && \
	if [ "$DB_COMMIT_HASH" != "HEAD" ]; then cd /opt/src/database; git checkout ${DB_COMMIT_HASH}; fi

RUN mkdir -p /opt/src/cmangos/build && \
	cd /opt/src/cmangos/build && \
	cmake /opt/src/cmangos -DCMAKE_INSTALL_PREFIX=/opt/cmangos \
	-DBUILD_LOGIN_SERVER=OFF \
	-DBUILD_PLAYERBOT=${BUILD_PLAYERBOT} \
	-DBUILD_AHBOT=${BUILD_AHBOT} \
	-DBUILD_METRICS=${BUILD_METRICS} \
	-DBUILD_MODULES=ON \
	-DBUILD_MODULE_DUALSPEC=ON \
	&& \
	make -j $(nproc) && make install

# Copy config and sql scripts
RUN cp -r /opt/cmangos/etc /opt/cmangos/configs
RUN mkdir -p /opt/cmangos/sql && \
	cp -r /opt/src/cmangos/sql /opt/cmangos

# Remove .git dir to minimize size
RUN rm -rfv /opt/src/database/.git

FROM debian:latest

ARG CMANGOS_CORE
ENV CMANGOS_CORE=${CMANGOS_CORE}

RUN apt update; \
	apt install -y \
		mariadb-client \
		libmariadb3 \
		wget \
		unzip \
		dos2unix \
	; rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/cmangos /opt/cmangos
COPY --from=builder /opt/src/cmangos/src/modules /opt/modules
# COPY --from=builder /opt/src/cmangos/modules/dualspec/src/dualspec.conf.dist.in /opt/cmangos/etc/dualspec.conf
COPY --from=builder /opt/src/database /opt/database
COPY InstallFullDB.diff /opt/database/InstallFullDB.diff
RUN dos2unix /opt/database/InstallFullDB.diff

RUN cp /opt/modules/dualspec/src/dualspec.conf.dist.in /opt/cmangos/etc/dualspec.conf

# enables legacy support on openssl3 to stop server from crashing on startup
COPY openssl.cnf /etc/ssl/temp_openssl.cnf
RUN dos2unix /etc/ssl/temp_openssl.cnf
RUN mv -f /etc/ssl/temp_openssl.cnf /etc/ssl/openssl.cnf


VOLUME [ "/opt/cmangos/etc" ]

# Copy over init scripts, remove dos line endings and make them executable
COPY 00_init.sh /00_init.sh
COPY install_module_database.sh /install_module_database.sh
COPY wait-for-it.sh /wait-for-it.sh
RUN dos2unix /00_init.sh && dos2unix /wait-for-it.sh && dos2unix /install_module_database.sh
RUN chmod +x /00_init.sh && chmod +x /wait-for-it.sh && chmod +x /install_module_database.sh

# Add Tini
ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/00_init.sh"]

EXPOSE 8085