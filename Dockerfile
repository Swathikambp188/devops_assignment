# Use Node.js base image with Alpine for a smaller footprint
FROM node:18-alpine

# Set the working directory to /app
WORKDIR /app

# Copy package.json and package-lock.json from the root of the repository
COPY package*.json ./

# Install dependencies for the entire workspace
RUN npm install

# Copy the entire repository into the container
COPY . .

# Install global dependencies for Nx and TypeScript
RUN npm install -g nx typescript

# Build the nft-bridge app using Nx (run the build command from the root)
RUN nx build nft-bridge

# Set the working directory to the build output (dist)
WORKDIR /app/dist/apps/nft-bridge

# Expose the port the app will run on
EXPOSE 3001

# Command to start the application
CMD ["node", "main.js"]
