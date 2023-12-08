# Use the official Debian Bullseye image as a base
FROM debian:bullseye

# Update the package list and install netcat
RUN apt-get update && \
    apt-get install -y netcat && \
    rm -rf /var/lib/apt/lists/*
