# Use a base image for Python (Plone backend)
FROM plone/plone-backend:6.0

# Install necessary backend dependencies (if any)
RUN pip install -U pip setuptools wheel

# Set environment variables for Plone
ENV SITE_ID=Plone \
    SITE_TITLE="My Plone Site" \
    ADMIN_USER=admin \
    ADMIN_PASSWORD=admin123 \
    ADDONS=""

# Expose Plone's default port
EXPOSE 8080

# Copy and configure supervisord to manage both Plone and Volto
COPY supervisord.conf /etc/supervisord.conf

# Install Node.js for Volto frontend
FROM node:20

# Install a specific version of Yarn
RUN npm install -g yarn@9.1.1

# Set working directory for frontend
WORKDIR /app

# Copy package.json and install dependencies
COPY frontend/package.json yarn.lock ./

# Ensure correct Yarn version is used
RUN yarn --version  # Debugging step (optional)
RUN yarn install --frozen-lockfile

# Copy the rest of the project files
COPY . .

# Copy Volto project files
COPY frontend /app

# Build the frontend
RUN yarn build

# Expose Volto’s default port
EXPOSE 3000

# Start both Plone and Volto using supervisord
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
