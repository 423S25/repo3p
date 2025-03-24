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

# Install pnpm globally
RUN npm install -g pnpm

# Set working directory for frontend
WORKDIR /app

# Copy package.json and install dependencies
COPY frontend/package.json frontend/pnpm-lock.yaml ./

# Ensure correct pnpm version is used
RUN pnpm --version  # Debugging step (optional)

# Use pnpm to install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the project files
COPY . .

# Copy Volto project files
COPY frontend /app

# Build the frontend
RUN pnpm build

# Expose Volto’s default port
EXPOSE 3000

# Start both Plone and Volto using supervisord
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
