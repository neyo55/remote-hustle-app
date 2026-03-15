
---


# Remote Hustle - Infrastructure & Deployment Pipeline

This repository contains the source code and infrastructure documentation for the Remote Hustle application. It demonstrates a complete, automated DevOps pipeline including CI/CD deployment, automated off-site backups, and strict security configurations.

## Architecture & Tech Stack
* **Frontend Hosting:** Vercel (Platform-as-a-Service)
* **Version Control & CI/CD:** GitHub
* **Backup Storage:** AWS S3
* **Automation:** Linux `cron`, Bash scripting (via AWS CloudShell)
* **Monitoring:** UptimeRobot

---

## Step 1: Frontend Application Setup
To simulate the application, a lightweight HTML file was created and pushed to the `main` branch.

### `index.html`
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Remote Hustle</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #0070f3; }
    </style>
</head>
<body>
    <h1>Welcome to Remote Hustle</h1>
    <p>The best place to find your next remote job.</p>
    <p><em>Environment: Production</em></p>
</body>
</html>

```

---

## Step 2: Continuous Deployment (CI/CD)

**Deployment Process Guide:**
To keep deployments secure and automated, we have implemented a Git-based Continuous Deployment (CD) pipeline. No developer is required to manually transfer files via FTP. 

**How to deploy an update:**
1. **Push to GitHub:** Developers push their committed changes to the `main` branch (for production) or a `staging` branch (for testing) on GitHub. 
2. **Automated Build:** Our hosting provider (Vercel) detects the push via webhook, automatically pulls the latest code, and initiates the build process. 
3. **Live Release:** Once the build passes without errors, the platform atomically swaps the old version with the new version. This results in zero downtime for Remote Hustle users. 
4. **Rollbacks:** If a bug makes it to production, any admin can go into the hosting dashboard and click "Rollback" on the previous deployment to instantly revert the site to the last stable state.

**Live Production URL:** https://remote-hustle-app.vercel.app/

`[Vercel Dashboard showing successful deployment]`
![live Production](images/Live%20Production.JPG)

---

## Step 3: Automated Backups to AWS S3

To protect user data, a disaster recovery pipeline was built to automatically compress data and push it off-site to an AWS S3 bucket.

### 1. The Backup Script (`backup.sh`)

This bash script zips the application data, uploads it to S3, and emails a status report.
*(Note: If replicating this, replace `remote-hustle-backup-neyo55-2026` with your own S3 bucket name).*

```bash
#!/bin/bash
# Remote Hustle Daily Backup Script

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="remote-hustle-data"
ZIP_NAME="backup_$TIMESTAMP.zip"
S3_BUCKET="s3://remote-hustle-backup-neyo55-2026"

echo "Zipping data..."
zip -r $ZIP_NAME $BACKUP_DIR

echo "Uploading to AWS S3..."
aws s3 cp $ZIP_NAME $S3_BUCKET/

echo "Backup successful: $ZIP_NAME uploaded to S3" | mail -s "Backup Success" kbneyo55@gmail.com

```

### 2. Automation via Cronjob

Using a Linux server (AWS CloudShell), we automated the script to run daily at 2:00 AM.

**Setup Commands:**

```bash
# Install cron and mail utilities
sudo yum install cronie mailx -y

# Make script executable
chmod +x backup.sh

# Open crontab
crontab -e

# Add the following schedule:
0 2 * * * /home/cloudshell-user/backup.sh

```

`Terminal showing 'crontab -l' output]`
![Cronjob at 2am](images/Cronjob%20at%202am.JPG)

`AWS S3 Dashboard showing the uploaded zip file]`
![S2 Bucket file](images/S3%20backup%20file.JPG)

### 3. Disaster Recovery Testing

To verify the integrity of the backups, a simulated disaster recovery was performed. The local data was deleted, then restored entirely from the AWS S3 zip file.

`[Terminal showing successful aws s3 cp download and unzip restore]`
![S2 Bucket file](images/backup%20file-upload%20and%20unzip.JPG)

---

## Step 4: Security Implementation

Foundational security measures were implemented to enforce access control and data protection.

1. **Encryption in Transit:** Let's Encrypt SSL certificate applied via Vercel.
2. **Role-Based Access Control (RBAC):** Root access is restricted.
3. **Branch Protection:** The `main` branch is locked. Developers cannot push directly to production; they must submit a Pull Request.

`[GitHub Branch Protection Rules showing "Require a pull request before merging"]`
![user access role](images/user%20role%20and%20access%20control.JPG)
`[Browser padlock showing valid SSL]`
![https secure](images/https%20secure.jpeg)
---

## Step 5: Bonus Implementations

To future-proof the application, additional DevOps best practices were configured:

* **Staging Environment:** A parallel `staging` branch was created. Vercel automatically generates preview URLs for QA testing before code merges to production.
* **Staging URL:** https://remote-hustle-app-git-staging-neyo55s-projects.vercel.app/
![Staging Branch](images/Staging%20branch.JPG)


* **Uptime Monitoring:** Configured UptimeRobot to ping the production URL every 5 minutes and alert the engineering team of any downtime.

`[UptimeRobot Dashboard showing 100% uptime]`
![uptime monitor](images/uptime%20monitor%20dashboard.JPG)

