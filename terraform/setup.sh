#!/bin/bash
set -e

# Install and start NGINX
sudo dnf update -y
sudo dnf install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Create index page with instance info
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "<html>
  <head><title>Welcome</title></head>
  <body>
    <h1>Welcome to NTC App</h1>
    <p>Instance: $INSTANCE_ID</p>
    <p>You are redirected to $(hostname) to see load balancer traffic distribution.</p>
  </body>
</html>" | sudo tee /usr/share/nginx/html/index.html > /dev/null

# Install and configure CloudWatch Agent
sudo dnf install -y amazon-cloudwatch-agent

cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/ec2/nginx/access",
            "log_stream_name": "$INSTANCE_ID"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/ec2/nginx/error",
            "log_stream_name": "$INSTANCE_ID"
          }
        ]
      }
    }
  }
}
EOF

sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

echo "Setup completed!"