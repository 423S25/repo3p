# Use Plone backend as the base image
FROM plone/plone-backend:6.0

# Install necessary backend dependencies
RUN pip install -U pip setuptools wheel

# Set environment variables for Plone
ENV SITE_ID=Plone \
    SITE_TITLE="My Plone Site" \
    ADMIN_USER=admin \
    ADMIN_PASSWORD=admin123 \
    ADDONS=""

# Expose Plone’s default port
EXPOSE 8080

# Install Node.js and Yarn for Volto frontend
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# Set working directory for frontend
WORKDIR /app

# Copy frontend package.json and install dependencies
COPY frontend/package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the frontend code and build it
COPY frontend /app
RUN yarn build

# Expose Volto’s default port
EXPOSE 3000

# Install supervisord to run both services
RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start both Plone and Volto using supervisord
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
