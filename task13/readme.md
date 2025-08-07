# 📘 Task13 – Docker Swarm Cronjob Documentation

---

## 🐳 What is Docker Swarm Cronjob?

Docker Swarm Cronjob refers to the method of running **scheduled jobs (cronjobs)** in a **Docker Swarm cluster**.

In Linux, we use `cron` to schedule tasks like backups, cleanups, sending logs, etc.  
But **Docker Swarm does not support cronjobs natively**, unlike Kubernetes.

To solve this, we use workarounds or tools like:
•  Host-based crontab
• `swarm-cronjob` open-source service

In this task, I used the `swarm-cronjob` tool to run cron-like tasks inside Docker Swarm.

---

## ❓ Why We Use It?

•  Docker Swarm is used to deploy containerized applications across multiple nodes.
• Sometimes we need to run **background or scheduled jobs**, such as:
  - Printing logs every few minutes
  - Cleaning temporary files
  - Sending daily reports
•  Since Docker Swarm has no built-in cronjob system, we use `swarm-cronjob` to manage scheduled tasks.
---

## 🔧 Steps I Followed

✅ 1. Initialize Docker Swarm (if not already)

```bash
docker swarm init
```
✅ 2. Create docker-compose.yml file
Here’s a very simple example that uses swarm-cronjob and runs a busybox task every minute:
```bash
version: '3.8'

services:
  swarm-cronjob:
    image: crazymax/swarm-cronjob:latest
    deploy:
      placement:
        constraints:
          - node.role == manager
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  cronjob:
    image: busybox
    command: sh -c "date; echo Hello from Cronjob!"
    deploy:
      placement:
        constraints:
          - node.role == manager
    labels:
      - "swarm.cronjob.enable=true"
      - "swarm.cronjob.schedule=*/1 * * * *"
```
📝 This job will run every 1 minute, printing the current time and a message.

✅3: Understand What’s Inside the Compose File
🧩 Service 1: swarm-cronjob
Key	What it does
• image	Uses the prebuilt cronjob controller image from DockerHub
• deploy.constraint	Ensures it runs only on manager node
• volumes	Binds Docker socket so it can create/manage services inside the swarm

🧩 Service 2: cronjob
Key	What it does
• image	Uses lightweight busybox to run simple shell commands
• command	Prints date and "Hello from Cronjob!" when run
• labels	Tells the controller to run this every 1 minute like a cronjob

🕐 */1 * * * * = every 1 minute (Cron format)
Example: */1 * * * *
```bash
Field	Value	   Explanation

Minute	      */1  Every 1 minute (0, 1, 2, 3, ...)
Hour	      *	   Every hour
Day of Month  *	   Every day of the month
Month	      *	   Every month
Day of Week	  *	   Every day of the week (Mon–Sun)
```

🔁 So this means:

• Run the job every 1 minute, all day, every day, all year.

✅4: Deploy the Stack
Now deploy it using Docker Swarm:
```bash
docker stack deploy -c docker-compose.yml cronjob-stack
```
This will create a stack named cronjob-stack containing:
• swarm-cronjob controller
• cronjob scheduled service

✅5: Verify the Services
```bash
docker service ls
```
You should see:
• cronjob-stack_swarm-cronjob
• cronjob-stack_cronjob
• cronjob-stack_cronjob will be triggered automatically every 1 minute!

---And also use for scale up scale down and auo healing..
  Docker Swarm is a container orchestration tool built into Docker that lets you manage a cluster of Docker nodes as a single virtual system. It’s used to:

✅ Scale Up / Down Services:
You can increase or decrease the number of containers running for a service easily.
Example:
```docker service scale myservice=5
```
🔁 Promote and Demote Nodes:
Promote a node to manager:
```bash
docker node promote <node-name>
docker node demote <node-name>
```
⚖️ Load Balancing:
Swarm automatically load balances traffic across all running containers for a service.
It ensures high availability by distributing traffic to healthy instances.

🔄 Self-healing:
If a container crashes or a node fails, Swarm can restart containers or reassign services to other available nodes.

✅6:Check Logs of Cron Job
```bash
docker service logs cronjob-stack_cronjob
```
You should see output like:
date
Hello from Cronjob!

✅ Summary
Step	What you did
1. Swarm Init	Set up the Swarm manager
2. Compose File	Defined both cronjob controller & job
3. Deploy Stack	Ran both services in Swarm
4. Check Logs	Verified if the cronjob runs every 1 min


