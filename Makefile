default:
	echo "What do you want to build?"

systemd_install:
  docker run --rm --user nobody --entrypoint mailbimi marcbradshaw/bimivalidator:latest --version
	cp bimivalidator.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable bimivalidator.service
	systemctl start bimivalidator.service

systemd_update:
	systemctl stop bimivalidator.service
	docker image rm marcbradshaw/bimivalidator:latest
	docker run --rm --user nobody --entrypoint mailbimi marcbradshaw/bimivalidator:latest --version
	systemctl start bimivalidator.service

docker_install_image:
  docker run --rm --user nobody --entrypoint mailbimi marcbradshaw/bimivalidator:latest --version

docker_image: docker_build_image docker_push_image docker_manifest

docker_build_image:
	perl docker_build.pl build

docker_push_image:
	perl docker_build.pl push

docker_manifest:
	docker pull marcbradshaw/bimivalidator:latest-amd64
	docker pull marcbradshaw/bimivalidator:latest-arm64
	docker manifest create \
		marcbradshaw/bimivalidator:latest \
		--amend marcbradshaw/bimivalidator:latest-amd64 \
		--amend marcbradshaw/bimivalidator:latest-arm64
	docker manifest push marcbradshaw/bimivalidator:latest

local_dev:
	curl -o htdocs/jquery-3.5.1.min.js \
            https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js
	curl -o htdocs/spectrum.js \
            https://raw.githubusercontent.com/bgrins/spectrum/9aa028de7e8039c41ac792485a928edb97d4ac40/spectrum.js
	curl -o htdocs/spectrum.css \
            https://raw.githubusercontent.com/bgrins/spectrum/9aa028de7e8039c41ac792485a928edb97d4ac40/spectrum.css
