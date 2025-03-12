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

# Start Plone in the background
CMD ["start-plone"] &

# Install Node.js for Volto frontend
FROM node:20

RUN npm install -g yarn

RUN yarn install


# Enable Corepack globally
RUN corepack enable

# Set the correct Yarn version from package.json
RUN corepack prepare yarn@stable --activate

# Set working directory for frontend
WORKDIR /app

# Copy package.json and install dependencies
COPY frontend/package.json yarn.lock ./
RUN yarn install

# Copy the rest of the project files
COPY . .

# Copy Volto project files
COPY frontend /app

# Build the frontend
RUN yarn build

# Expose Volto’s default port
EXPOSE 3000

# Start Volto frontend
CMD ["yarn", "start"]
