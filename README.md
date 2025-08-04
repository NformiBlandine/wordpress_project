

---

````markdown
# 📘 Deploying a Cloud-Portable, Persistent WordPress LMS Site with Backup & Restore

This guide provides a comprehensive walkthrough for deploying and managing a **cloud-portable**, **persistent**, WordPress-based Learning Management System (LMS). The setup is designed to work seamlessly across various cloud VM providers (AWS, GCP, Azure, DigitalOcean) with built-in **backup** and **disaster recovery** support.

---

## 1. 📌 Project Overview

This project uses **Docker** and **Docker Compose** to provision a LEMP stack (Linux, Nginx, MySQL, PHP) that hosts a WordPress LMS, typically powered by plugins such as **LearnPress**.

### 🔧 Key Components:
- **Persistent Storage**: Uses Docker volumes for WordPress files and MySQL data.
- **Automated Provisioning**: The entire stack is defined in code for easy bootstrapping.
- **Flexible Backups**: Supports manual, daily, or scheduled backups via script.
- **Portability**: Easily replicable across different cloud environments.
- **Disaster Recovery**: Backup restore scripts reduce downtime during failure recovery.

---

## 2. 🚀 Deployment Guide

### 2.1. ✅ Requirements
```
| Component | Minimum Requirement |
|----------|---------------------|
| OS | Linux VM (Ubuntu recommended) |
| Software | Docker, Docker Compose |
| Network | Port 80 or 8080 open |
| Hardware | 2 CPU cores, 4 GB RAM |
```
---

### 2.2. 📁 Folder Structure

```bash
wordpress_project/
├── docker-compose.yml
├── .env
├── backups/
├── volume-backup.sh
├── volume-restore.sh
└── Nginx-config/
    └── nginx.conf
````

---

 Docker Setup

####  `.env` File

Stores sensitive credentials:

```env
DB_HOST=db
DB_PORT=3306
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=your_db_user
MYSQL_PASSWORD=your_db_password
```

**Note:** Avoid committing `.env` to version control. Use `.gitignore` to exclude it.



#### ➤ `docker-compose.yml`

Defines the WordPress and MySQL services with volume persistence:

```yaml
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: ${DB_HOST}:${DB_PORT}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: wpdb
    volumes:
      - wordpress-project_wordpress:/var/www/html

  db:
    image: mysql:5.7
    container_name: mysql
    restart: always
    environment:
      MYSQL_DATABASE: wpdb
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - wordpress-project_dbdata:/var/lib/mysql

volumes:
  wordpress-project_wordpress:
  wordpress-project_dbdata:
```



 Start the Stack

```bash
docker compose up -d
```

Access the site at:
`http://<your-server-ip>:8080`

From the WordPress dashboard, install the **LearnPress** plugin or your LMS of choice.

---

Backup & Restore

Backup Script: `volume-backup.sh`

This script creates `.tar.gz` backups of your volumes:

* `backups/db-volume-YYYY-MM-DD-HHMM.tar.gz`
* `backups/wp-volume-YYYY-MM-DD-HHMM.tar.gz`

Run the script:

```bash
./volume-backup.sh
```



### 3.2. ☁️ Store Backups in S3

#### Requirements:

* AWS Account
* AWS CLI configured (`aws configure`)

#### Upload Command:

```bash
aws s3 cp ./backups s3://your-s3-bucket-name/wordpress-backups/ --recursive
```



**Restoration Process**

1. **Provision a New VM**: Ensure Docker, Docker Compose, and AWS CLI are installed.
2. **Clone Project Repo**:

   ```bash
   git clone <your-project-repo>
   cd wordpress_project
   ```
3. **Download Backup Files**:

   ```bash
   aws s3 cp s3://your-s3-bucket-name/wp-volume-2025-07-17-1123.tar.gz ./backups/
   aws s3 cp s3://your-s3-bucket-name/db-volume-2025-07-17-1123.tar.gz ./backups/
   ```
4. **Restore Volumes**:


Create Docker Volumes (If Not Already Done)
```
docker volume create wordpress
docker volume create dbdata
```

#Restore Backups into These Volumes
volume for wordpress
```
docker run --rm \
  -v wordpress:/wpdata \
  -v "$(pwd)/backups:/backup" \
  ubuntu \
  bash -c "rm -rf /wpdata/* && tar -xzf /backup/wp-volume-YYYY-MM-DD-HHMM.tar.gz -C /"
```
volume for db
```
docker run --rm \
  -v dbdata:/dbdata \
  -v "$(pwd)/backups:/backup" \
  ubuntu \
  bash -c "rm -rf /dbdata/* && tar -xzf /backup/db-volume-YYYY-MM-DD-HHMM.tar.gz -C /"
```


Redeploy the app
   ```bash
   chmod +x volume-restore.sh
   ./volume-restore.sh wp-volume-2025-07-17-1123.tar.gz db-volume-2025-07-17-1123.tar.gz
   ```



*Automation via Cron*

To schedule daily backups at 2:00 AM:

```bash
crontab -e
```

Add this line:

```bash
0 2 * * * /full/path/to/volume-backup.sh >> /var/log/wp-backup.log 2>&1
```



*Security Considerations*

| Risk                      | Solution                             |
| ------------------------- | ------------------------------------ |
| Credentials in plain text | Use `.env` + `.gitignore`            |
| Exposed HTTP              | Use Nginx + SSL (Let’s Encrypt)      |
| Image vulnerabilities     | Build a hardened custom Docker image |

*Disaster Recovery Plan*

| Task                       | Estimated Time   |
| -------------------------- | ---------------- |
| VM re-provisioning         | \~5 minutes      |
| Docker stack redeployment  | \~2 minutes      |
| Restore from backup        | \~1–2 minutes    |
| **Total Time to Recovery** | **\~10 minutes** |



*Troubleshooting*

| Issue                       | Solution                                         |
| --------------------------- | ------------------------------------------------ |
| Permission denied on Docker | Add your user to the `docker` group and re-login |
| DB connection failed        | Check `.env` values for database                 |
| Port 80 already in use      | Change `8080:80` in `docker-compose.yml`         |
| No backups created          | Verify volume names and paths                    |
| LMS plugin issues           | Ensure plugin is installed and activated         |



*Conclusion*

This setup provides a **scalable**, **portable**, and **disaster-resilient** LMS solution using WordPress. Backup and restoration are simple and fast, and the structure is portable across cloud providers.





