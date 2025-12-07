FROM cmangos-builder:latest AS builder

ARG CMANGOS_CORE=classic
ARG CORE_COMMIT_HASH=HEAD
ARG DB_COMMIT_HASH=HEAD

RUN mkdir -p /opt/src && \
	git clone https://github.com/davidonete/mangos-${CMANGOS_CORE}.git -b modules /opt/src/cmangos && \
	if [ "$CORE_COMMIT_HASH" != "HEAD" ]; then cd /opt/src/cmangos; git checkout ${CORE_COMMIT_HASH}; fi

RUN mkdir -p /opt/src && \
	git clone https://github.com/cmangos/${CMANGOS_CORE}-db.git /opt/src/database && \
	if [ "$DB_COMMIT_HASH" != "HEAD" ]; then cd /opt/src/database; git checkout ${DB_COMMIT_HASH}; fi

RUN mkdir -p /opt/src/cmangos/build && \
	cd /opt/src/cmangos/build && \
	cmake /opt/src/cmangos \
	-DCMAKE_INSTALL_PREFIX=/opt/cmangos \
	-DBUILD_GAME_SERVER=OFF \
	-DBUILD_MODULES=ON && \
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
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/cmangos /opt/cmangos
COPY --from=builder /opt/src/database /opt/database

COPY InstallFullDB.diff /opt/database/InstallFullDB.diff
RUN dos2unix /opt/database/InstallFullDB.diff

# enables legacy support on openssl3 to stop server from crashing on startup
COPY openssl.cnf /etc/ssl/temp_openssl.cnf
RUN dos2unix /etc/ssl/temp_openssl.cnf
RUN mv -f /etc/ssl/temp_openssl.cnf /etc/ssl/openssl.cnf

VOLUME [ "/opt/cmangos/etc" ]

# Copy over init scripts, remove dos line endings and make them executable
COPY 00_init.sh /00_init.sh
COPY wait-for-it.sh /wait-for-it.sh
RUN dos2unix /00_init.sh && dos2unix /wait-for-it.sh
RUN chmod +x /00_init.sh && chmod +x /wait-for-it.sh

# Add Tini
ENV TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/00_init.sh"]

EXPOSE 3724