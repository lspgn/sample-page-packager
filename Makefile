.PHONY: gpg
gpg:
	
	#gpg-agent --daemon
	#export GNUPGHOME=/work/gpg
	#mkdir -p gpg
	#gpgconf --launch gpg-agent
	gpg --batch --passphrase='' --quick-generate-key "PackageRepoKey <example@example.com>" ed25519 sign never
	gpg --armor --export > ./local.gpg
	# cert,sign,encrypt,authenticate
	#gpgconf --kill gpg-agent

.PHONY: prep-deb
prep-deb:
	USER=root cd debian && /usr/bin/dh_make -p helloworld_1.0.0 -e example@example.com --createorig --single --yes

.PHONY: build-deb
build-deb:
	#cd debian && dpkg-buildpackage -b --sign-keyfile=F13D94621682FB699798B2DCEC097F52EEF3EC55 --force-sign
	cd debian && dpkg-buildpackage -b
	dpkg -c helloworld_1.0.0-1_amd64.deb

.PHONY: apt-repo
apt-repo:
	mkdir -p apt-repo/pool
	mkdir -p apt-repo/dists/stable/main/binary-amd64

	cp *.deb apt-repo/pool

	cd apt-repo && apt-ftparchive packages pool > dists/stable/main/binary-amd64/Packages
	cd apt-repo && gzip -c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz

	cd apt-repo/dists/stable && apt-ftparchive release -o APT::FTPArchive::Release::Suite=stable . > Release

	# https://manpages.debian.org/stretch/apt/apt-secure.8.en.html
	gpg --clearsign -o apt-repo/dists/stable/InRelease apt-repo/dists/stable/Release
	gpg -abs -o apt-repo/dists/stable/Release.gpg apt-repo/dists/stable/Release
