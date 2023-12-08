FROM nginx:stable

# Remove the default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy your HTML files to the nginx HTML directory
COPY ./html /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]