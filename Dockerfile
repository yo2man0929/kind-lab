FROM nginx:stable-alpine

# Create sample content
RUN echo 'Hello World' > /usr/share/nginx/html/index.html

# Add metadata labels
LABEL maintainer="Project Maintainer"
LABEL version="1.0.0"
LABEL description="Sample NGINX container for Kubernetes testing"

# Expose port 80
EXPOSE 80

# Default command to start NGINX
CMD ["nginx", "-g", "daemon off;"]