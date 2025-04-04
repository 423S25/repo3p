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

# Enable Corepack globally to manage pnpm
RUN corepack enable

# Set environment variable to allow unsafe custom URLs for pnpm
ENV COREPACK_ENABLE_UNSAFE_CUSTOM_URLS=1

# Install pnpm globally (without forcing version)
RUN npm install -g pnpm --force

# Set working directory for frontend
WORKDIR /app

# Copy package.json and pnpm-lock.yaml
COPY frontend/package.json frontend/pnpm-lock.yaml ./

# Ensure correct pnpm version is used (via Corepack)
RUN pnpm --version  # Debugging step (optional)

# Install frontend dependencies using pnpm
RUN pnpm install --frozen-lockfile

# Copy the rest of the project files
COPY . .

# Copy Volto project files
COPY frontend /app

# Build the frontend
RUN pnpm run build

# Expose Volto’s default port
EXPOSE 3000

# Start both Plone and Volto using supervisord
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
