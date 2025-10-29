## Task Description

 - Write a solution using Docker + Ansible
 - The Solution should spin up a Linux host which will show the newest/last frame from the given stream
 - Stream URL: https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
 - For web hosting NGINX can be used, and for stream processing ffmpeg docker image can be used
 - The frame should be shown at the index level
 - NGINX Configuration should not affect the availability of the solution
 - If I got everything right should be this image

# 🎬 Video Frame Extractor - Terraform + Ansible + Docker

> *Because sometimes you just need that one perfect frame, automated and containerized.*

A fully automated solution that deploys an FFMPEG + NGINX stack to AWS EC2, extracting and displaying the latest frame from a video stream. Built with Terraform for infrastructure, Ansible for deployment, and Docker for containerization.

---

## 🎯 What Does This Do?

This project spins up a complete web server on AWS that:
- 📹 Extracts the last frame from a video stream using FFMPEG
- 🖼️ Displays it on a clean web interface via NGINX
- 🐳 Runs everything in isolated Docker containers
- 🤖 Deploys automatically with Ansible
- ☁️ Infrastructure managed as code with Terraform

**Live Demo:** Once deployed, just visit `http://<your-ec2-ip>` and boom - there's your frame!

---

## 📋 Prerequisites

Before you begin, make sure you have these tools installed:

- **Ansible** - For automated deployment
- **Terraform** - For infrastructure provisioning
- **Docker** - For local testing (optional but recommended)
- **Python** - Required by Ansible
- **AWS CLI** - Configured with valid credentials
  - *In this project, Terraform authenticates via the default AWS profile at `~/.aws/credentials`*

---

## 🏗️ Project Structure
```
.
├── app/
│   ├── Dockerfile                 # Custom FFMPEG image
│   ├── docker-compose.yaml        # Service orchestration
│   ├── ffmpeg-lastframe.sh        # Frame extraction script
│   └── index.html                 # Web interface
├── terraform-infra/
│   ├── vpc.tf                     # VPC and networking
│   ├── ec2.tf                     # EC2 instance configuration
│   ├── keys.tf                    # SSH key pair generation
│   ├── outputs.tf                 # Terraform outputs (IP, SSH command)
│   └── variables.tf               # Configurable variables
├── ansible/
│   ├── inventory.ini              # Target hosts configuration
│   └── deploy.yml                 # Deployment playbook
└── README.md                      # You are here!
```

---

## 🚀 How It Works

### Part 1: The FFMPEG Magic ✨

The heart of this project is the frame extraction script (`ffmpeg-lastframe.sh`):

1. **Get video duration** using `ffprobe`:
```bash
   DURATION=$(ffprobe -v error -show_entries format=duration \
     -of default=noprint_wrappers=1:nokey=1 "$INPUT_VIDEO")
```

2. **Calculate seek time** (duration - 0.1 seconds) using `bc`:
```bash
   SEEK_TIME=$(echo "$DURATION - 0.1" | bc -l)
```

3. **Extract the frame** using `ffmpeg`:
```bash
   ffmpeg -ss "$SEEK_TIME" -i "$INPUT_VIDEO" -vframes 1 -q:v 1 -y "$OUTPUT_IMAGE"
```

This grabs the very last frame from the video with high quality (`-q:v 1`).

---

### Part 2: Docker Image 🐳

Built on top of the official `jrottenberg/ffmpeg:7-ubuntu` image, our custom Dockerfile:

- 📦 Uses the official FFMPEG image as base
- 💾 Mounts an `/output` volume for frame storage
- 📂 Sets working directory to `/ffmpeg/`
- 📄 Copies the `ffmpeg-lastframe.sh` script
- 🔧 Installs `bc` for mathematical calculations
- 🧹 Removes `/var/lib/apt/lists/*` (reduces image size by cleaning up package metadata after installation)
- ⚡ Makes the script executable
- 🎬 Runs the script on container start

**Why remove apt lists?** This metadata is only needed during package installation. Removing it keeps the Docker image lean and production-ready.

---

### Part 3: Docker Compose Orchestra 🎼

The `docker-compose.yaml` orchestrates two services:

**FFMPEG Service:**
- Builds our custom image
- Extracts the last frame to a shared volume
- Runs once and exits (`restart: no`)

**NGINX Service:**
- Uses official `nginx:latest` image
- Mounts the shared volume to access `last_frame.jpg`
- Serves `index.html` on port 80
- Displays the extracted frame in a clean web interface

**Shared Volume:** Both services use a common volume to pass the extracted frame from FFMPEG to NGINX.

---

### Part 4: Terraform Infrastructure 🏗️

Terraform provisions everything on AWS using Anton Babenko's community modules:

**What gets created:**
- ☁️ **VPC** with public subnets across 2 availability zones
- 🖥️ **EC2 instance** (Ubuntu 22.04 on t2.micro)
- 🔐 **SSH key pair** (auto-generated and saved as `.pem` file)
- 🛡️ **Security group** with rules:
  - Port 22 (SSH) - for Ansible access
  - Port 80 (HTTP) - for web traffic

**Key Terraform Outputs:**
- Public IP address of the EC2 instance
- SSH command for manual access
- Path to the generated `.pem` key file

These outputs are used to configure Ansible's inventory file.

---

### Part 5: Ansible Deployment 🤖

Ansible automates the entire deployment process with a single playbook.

#### Step 1: Create the Inventory

The `inventory.ini` file tells Ansible where to deploy:
```ini
[webservers]
ec2-instance ansible_host=<PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=../terraform-infra/ffmpeg-project-key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

**Test the connection:**
```bash
ansible -i inventory.ini -m ping ec2-instance
```

You should get a `pong` response! 🏓

#### Step 2: Run the Deployment Playbook
```bash
ansible-playbook -i inventory.ini deploy.yml
```

**What `deploy.yml` does:**
1. ✅ Updates apt cache
2. ✅ Installs Docker and Docker Compose
3. ✅ Starts Docker service
4. ✅ Creates `/home/ffmpeg-app` directory
5. ✅ Copies all application files (Dockerfile, docker-compose.yaml, scripts, HTML)
6. ✅ Makes the FFMPEG script executable
7. ✅ Stops any existing containers
8. ✅ Builds and starts the new containers
9. ✅ Waits for port 80 to be accessible

---

## 📖 Complete Deployment Guide

### 1️⃣ Provision Infrastructure with Terraform
```bash
cd terraform-infra
terraform init
terraform plan
terraform apply
```

**Save these outputs:**
- Instance Public IP
- SSH command
- Path to `.pem` key file

### 2️⃣ Configure Ansible Inventory

Edit `ansible/inventory.ini` and replace `<PUBLIC_IP>` with your EC2 instance IP:
```ini
[webservers]
ec2-instance ansible_host=<PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=../terraform-infra/ffmpeg-project-key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### 3️⃣ Test Ansible Connection
```bash
cd ansible
ansible -i inventory.ini -m ping ec2-instance
```

Expected output: `ec2-instance | SUCCESS => { "ping": "pong" }`

### 4️⃣ Deploy the Application
```bash
ansible-playbook -i inventory.ini deploy.yml
```

Wait for the playbook to complete (usually 2-3 minutes).

### 5️⃣ Access Your Application

Open your browser and visit:
```
http://<your-ec2-public-ip>
```

You should see a beautiful web page displaying the last frame from the video! 🎉

---

## 🧹 Cleanup

To destroy all AWS resources and avoid charges:
```bash
cd terraform-infra
terraform destroy
```

Type `yes` when prompted.

---

## 🔧 Troubleshooting

**Ansible can't connect?**
- Verify the `.pem` file has correct permissions: `chmod 400 terraform-infra/*.pem`
- Test SSH manually: `ssh -i terraform-infra/ffmpeg-project-key.pem ubuntu@<PUBLIC_IP>`
- Check security group allows port 22 from your IP

**Docker containers not starting?**
- SSH into the instance and check logs: `docker-compose logs`
- Verify Docker service is running: `sudo systemctl status docker`

**Can't access the web page?**
- Verify security group allows port 80
- Check if NGINX is running: `docker ps`
- Test locally on the instance: `curl localhost`

---

## 🎯 Improvement Ideas

- [ ] Integrate Ansible with Terraform using `local-exec` provisioner (run everything with just `terraform apply`)
- [ ] Add health checks and auto-restart for containers
- [ ] Implement continuous frame updates for live streams
- [ ] Add SSL/TLS with Let's Encrypt
- [ ] Set up CloudWatch monitoring and alerting
- [ ] Use S3 for persistent frame storage
- [ ] Add CI/CD pipeline with GitHub Actions

---

## 🤝 Contributing

Feel free to open issues or submit pull requests if you find ways to improve this project!

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---

**Built with ❤️ using Terraform, Ansible, Docker, FFMPEG, and NGINX**
