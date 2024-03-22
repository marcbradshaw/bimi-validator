default:
	echo "What do you want to build?"

# wrappers around bimivalidator-helper for service management

systemd_install:
	perl bimivalidator-helper systemv_install

systemd_update:
	perl bimivalidator-helper systemv_update

install_docker_image:
	perl bimivalidator-helper install_docker_image

update_docker_image:
	perl bimibalidator-helper update_docker_image

# build and manage docker images

docker_image: docker_build_image docker_push_image docker_manifest

docker_build_image:
	perl docker_build.pl build

docker_push_image:
	perl docker_build.pl push

docker_manifest:
	docker pull marcbradshaw/bimivalidator:latest-amd64
	docker pull marcbradshaw/bimivalidator:latest-arm64
	docker manifest rm marcbradshaw/bimivalidator:latest
	docker manifest create \
		marcbradshaw/bimivalidator:latest \
		--amend marcbradshaw/bimivalidator:latest-amd64 \
		--amend marcbradshaw/bimivalidator:latest-arm64
	docker manifest push marcbradshaw/bimivalidator:latest

# Manage the local dev environment

local_dev:
	curl -o htdocs/jquery-3.5.1.min.js \
            https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js
	curl -o htdocs/spectrum.js \
            https://raw.githubusercontent.com/bgrins/spectrum/9aa028de7e8039c41ac792485a928edb97d4ac40/spectrum.js
	curl -o htdocs/spectrum.css \
            https://raw.githubusercontent.com/bgrins/spectrum/9aa028de7e8039c41ac792485a928edb97d4ac40/spectrum.css
