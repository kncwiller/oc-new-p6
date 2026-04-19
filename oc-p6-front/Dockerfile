# Build stage
FROM node:22-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=build /app/dist/olympic-games-starter/browser/* /app
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

#Due to ng build, have to manually move static files to meet default architecture
RUN cd /app && \
    mkdir assets && \
    mv mock assets/

# Create nginx user and set permissions
RUN chown -R nginx:nginx /app && \
    chmod -R 755 /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
