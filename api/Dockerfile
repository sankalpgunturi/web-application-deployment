FROM node:12 AS build
WORKDIR /srv
ADD package.json .
RUN npm install

FROM node:12-alpine
COPY --from=build /srv .
ADD ./index.js index.js
EXPOSE 80
CMD ["node", "index.js"]