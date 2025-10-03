#!/bin/bash
# Update packages
sudo dnf update -y

# Install nginx
sudo dnf install nginx -y

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create a simple index page
echo "<html>
  <head><title>Welcome</title></head>
  <body>
    <h1>Welcome to Utrains</h1>
    <p>You are redirected to $(hostname) to see how the load balancer is sharing the traffic.</p>
  </body>
</html>" | sudo tee /usr/share/nginx/html/index.html > /dev/null

# Install CloudWatch Agent
sudo dnf install -y amazon-cloudwatch-agent

# Create CloudWatch Agent config to monitor nginx logs
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/ec2/nginx/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/ec2/nginx/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch Agent
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent
