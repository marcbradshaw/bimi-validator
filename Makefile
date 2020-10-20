install:
	mkdir -p /opt/bimivalidator
	cp bimivalidator.run /opt/bimivalidator/
	cp validator.pl /opt/bimivalidator/
	chmod 755 /opt/bimivalidator/validator.pl
	cp bimivalidator.run /opt/bimivalidator/
	chmod 755 /opt/bimivalidator/bimivalidator.run
	cp bimivalidator.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable bimivalidator.service
	systemctl start bimivalidator.service
