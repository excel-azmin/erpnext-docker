# Base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    gnupg \
    software-properties-common \
    cron

# Add deadsnakes PPA for Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa

# Install Python 3.11 and other dependencies
RUN apt-get update && apt-get install -y \
    redis-server \
    mariadb-server \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    build-essential \
    git

# Update alternatives to set python3.11 as the default Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

# Install pip for Python 3.11
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.11 get-pip.py

# Install Bench and other necessary packages
RUN pip install frappe-bench

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Create a user for ERPNext
RUN useradd -m -s /bin/bash erpnext && \
    usermod -aG sudo erpnext && \
    echo 'erpnext ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to erpnext user
USER erpnext
WORKDIR /home/erpnext

# Initialize Bench and create a new site
RUN bench init frappe-bench --frappe-branch version-14 && \
    cd frappe-bench && \
    bench new-site --mariadb-root-password root --admin-password admin localhost

# Set up ERPNext
RUN cd frappe-bench && \
    bench get-app erpnext --branch version-14 && \
    bench --site localhost install-app erpnext

# Copy the setup scripts
COPY setup.sh /home/erpnext/setup.sh
RUN chmod +x /home/erpnext/setup.sh

# Command to run ERPNext
CMD ["/home/erpnext/setup.sh"]
