FROM buildpack-deps:stable

ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
	apt update && apt full-upgrade -y && apt install -y \
	binutils \
	build-essential \
	cmake \
	git-core \
	grep \
	libboost-all-dev \
	libmariadb-dev \
	libmariadb-dev-compat \
	mariadb-server \
	subversion \
	&& rm -rf /var/lib/apt/lists/*;