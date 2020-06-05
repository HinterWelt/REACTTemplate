FROM node:12

WORKDIR /usr/src/app

# Copy the package and package-lock to the local working dir on the container.
COPY package*.json ./

# Run install for prod env
RUN npm ci --only=production

# Copy source to image, note: this copies from wherever the file is
COPY . .

EXPOSE 3001

CMD [ "node", "server.js" ]