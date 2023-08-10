FROM node:14 as thelia_node

ENV NODE_ENV development
ENV YARN_CACHE_FOLDER /application/cache
ARG ACTIVE_FRONT_TEMPLATE
ENV ACTIVE_FRONT_TEMPLATE=${ACTIVE_FRONT_TEMPLATE:-modern}

WORKDIR /application

EXPOSE 8081

COPY templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/package.json ./application/templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/
COPY templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/yarn.lock ./application/templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/
RUN mkdir /application/cache

RUN set -eux; \
	yarn --production=false

COPY .docker/node/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-node
RUN chmod +x /usr/local/bin/docker-entrypoint-node

COPY . ./

ENTRYPOINT ["docker-entrypoint-node"]
CMD ["yarn", "start"]

