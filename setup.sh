#!/bin/bash

# Start MariaDB service
sudo service mysql start

# Start Redis service
redis-server &

# Start ERPNext
cd /home/erpnext/frappe-bench
bench start
