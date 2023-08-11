FROM node:14

ENV NODE_ENV development
ENV YARN_CACHE_FOLDER /application/cache
ARG ACTIVE_FRONT_TEMPLATE
ENV ACTIVE_FRONT_TEMPLATE=${ACTIVE_FRONT_TEMPLATE:-modern}

RUN mkdir -p /application/templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/
RUN useradd thelia -m
RUN usermod -a -G thelia thelia
RUN chown thelia:thelia -R /application

USER thelia
WORKDIR /application/templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/

COPY --chown=thelia:thelia templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/package.json .
COPY --chown=thelia:thelia templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/yarn.lock .

RUN set -eux
RUN yarn install --production=false
RUN mkdir -p /application/templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/src
RUN echo 'console.log("Hello world!");' > /application/templates/frontOffice/${ACTIVE_FRONT_TEMPLATE}/src/index.js

CMD ["yarn", "build"]