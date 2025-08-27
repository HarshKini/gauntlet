FROM node:20-alpine
WORKDIR /app
COPY server.js package.json ./
RUN npm install --omit=dev
EXPOSE 8080
CMD ["node", "server.js"]
