FROM mariadb:11.1

WORKDIR "/application"

RUN useradd thelia -m \
    && usermod -a -G thelia thelia \
    && mkdir -p /application \
    && chown thelia:thelia -R /application

USER thelia