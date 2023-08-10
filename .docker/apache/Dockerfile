FROM httpd:2.4

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install libcap2-bin -y

#Remove default httpd root directory
RUN rm -rf /usr/local/apache2/htdocs

#Clean up image
RUN apt-get autoremove -y --purge \
    && apt-get autoclean -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists /var/cache/apt /var/log/apt

RUN setcap 'cap_net_bind_service=+ep' /usr/local/apache2/bin/httpd

RUN useradd thelia -m \
    && usermod -a -G thelia thelia \
    && mkdir -p /application \
    && chown thelia:thelia -R /application \
    && chown -hR thelia:thelia /usr/local/apache2/logs \
    && touch /application/dummy.html

USER thelia