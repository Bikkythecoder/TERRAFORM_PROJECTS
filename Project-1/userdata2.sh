```bash
#!/bin/bash

# Update packages and install Apache + curl
apt update
apt install -y apache2 curl

# Get the IMDSv2 token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get the EC2 Instance ID using IMDSv2
INSTANCE_ID=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

# Create the HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
  <style>
    @keyframes colorChange {
      0% { color: red; }
      50% { color: green; }
      100% { color: blue; }
    }

    h1 {
      animation: colorChange 2s infinite;
    }
  </style>
</head>

<body>
  <h1>Terraform Project Server 1</h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <p>Welcome to the world of AZURE</p>
</body>
</html>
EOF

# Start Apache and enable it at boot
systemctl start apache2
systemctl enable apache2
```
