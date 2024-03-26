FROM node:lts AS development

WORKDIR /usr/src/app

# Copy the package and package-lock to the local working dir on the container.
COPY package.json /usr/src/app/package.json
COPY package-lock.json /usr/src/app/package-lock.json

# Run install for prod env
RUN npm ci

ENV CI=true
ENV PORT=3001

# Copy source to image, note: this copies from wherever the file is
COPY . /usr/src/app/

EXPOSE 3001

CMD [ "node", "start" ]

FROM development AS build

RUN npm run build

FROM development as dev-envs
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends git
EOF

RUN <<EOF
useradd -s /bin/bash -m vscode
groupadd docker
usermod -aG docker vscode
EOF
# install Docker tools (cli, buildx, compose)
COPY --from=gloursdocker/docker / /
CMD [ "npm", "start" ]

# 2. For Nginx setup
FROM nginx:alpine

# Copy config nginx
COPY --from=build /app/.nginx/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy static assets from builder stage
COPY --from=build /app/build .

# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]