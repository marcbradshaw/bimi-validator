# syntax=docker/dockerfile:1
FROM marcbradshaw/mailbimi:latest

RUN cpanm Starlet
COPY validator.pl .
COPY htdocs htdocs/
RUN curl -o htdocs/jquery-3.5.1.min.js https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js
RUN curl -o htdocs/spectrum.js https://raw.githubusercontent.com/bgrins/spectrum/9aa028de7e8039c41ac792485a928edb97d4ac40/spectrum.js
RUN curl -o htdocs/spectrum.css https://raw.githubusercontent.com/bgrins/spectrum/9aa028de7e8039c41ac792485a928edb97d4ac40/spectrum.css
RUN chmod 755 validator.pl
EXPOSE 5000/tcp
ENTRYPOINT ["start_server",  "/usr/src/app/validator.pl"]
