install: htdocs/jquery-3.5.1.min.js
	mkdir -p /opt/bimivalidator
	cp bimivalidator.run /opt/bimivalidator/
	cp validator.pl /opt/bimivalidator/
	chmod 755 /opt/bimivalidator/validator.pl
	cp bimivalidator.run /opt/bimivalidator/
	chmod 755 /opt/bimivalidator/bimivalidator.run
	cp bimivalidator.service /etc/systemd/system/
	mkdir -p /var/www/html/bimivalidator
	cp -r htdocs/* /var/www/html/bimivalidator/
	systemctl daemon-reload
	systemctl enable bimivalidator.service
	systemctl start bimivalidator.service

htdocs/jquery-3.5.1.min.js:
	curl -o htdocs/jquery-3.5.1.min.js https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js
