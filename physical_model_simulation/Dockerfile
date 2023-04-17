# Use Node.js v14 as base image
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the working directory
COPY package.json package-lock.json /app/

# Install dependencies
RUN npm i

# Copy the rest of the application code to the working directory
COPY . /app/

# Expose the port that the application will listen on
EXPOSE 1883

# Start the application
CMD ["node", "sample_physical_model.js"]