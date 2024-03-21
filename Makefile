default:
	echo "What do you want to build?"

systemd_install: docker
	cp bimivalidator.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable bimivalidator.service
	systemctl start bimivalidator.service

docker_install_image:
  docker run --rm --user nobody --entrypoint mailbimi marcbradshaw/bimivalidator:latest --version

docker_build_image:
	perl docker_build.pl build

docker_push_image:
	perl docker_build.pl push

docker_manifest:
	docker manifest create \
		marcbradshaw/bimivalidator:latest \
		--amend marcbradshaw/bimivalidator:latest-amd64 \
		--amend marcbradshaw/bimivalidator:latest-arm64
	docker manifest push marcbradshaw/bimivalidator:latest