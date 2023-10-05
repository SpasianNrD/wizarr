# Build Stage
FROM python:3.12.0-alpine

#######################
# Backend Build Stage #
#######################

# Copy only the necessary files for building
WORKDIR /data/backend
COPY ./backend ./

# Install build dependencies
RUN apk add --no-cache libffi-dev g++ nmap tzdata nginx

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt


########################
# Frontend Build Stage #
########################

# Copy only the necessary files for building
WORKDIR /data/frontend
COPY ./frontend/ ./

# Install build dependencies
RUN apk add --no-cache nodejs npm

# Node.js and Frontend build
RUN npm install && npm run build


#################
# Runtime Stage #
#################

WORKDIR /data

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Setup timezone
RUN cp /usr/share/zoneinfo/UTC /etc/localtime \
    && echo UTC > /etc/timezone

# Set environment variables
ENV TZ=Etc/UTC

# Expose ports
EXPOSE 5690
WORKDIR /data/backend

# Start Nginx in the background and Gunicorn in the foreground
CMD [ "sh", "-c", "nginx && gunicorn --worker-class geventwebsocket.gunicorn.workers.GeventWebSocketWorker --bind 0.0.0.0:5000 -m 007 run:app" ]
