FROM debian:sid

RUN apt-get update && apt-get install -y build-essential dpkg-dev fakeroot gnupg dh-make apt-utils
# dpkg-buildpackage
