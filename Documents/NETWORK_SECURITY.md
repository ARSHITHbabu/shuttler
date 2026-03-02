# Network Security Configuration

This document outlines the network-level security configurations required for the Shuttler production environment.

## 1. Database Access Restriction (VPC)

The PostgreSQL database should NOT be public-facing.
- **Rule**: Restrict access to port `5432` to the Backend Server's Private IP only.
- **Implementation (AWS)**: Place RDS and EC2/Lambda in the same VPC. Use a Security Group for RDS that allows inbound TCP on 5432 only from the Backend Security Group ID.
- **Implementation (PaaS - Railway/Render)**: Use internal networking (private URIs) instead of public ones.

## 2. Enforced SSL/TLS (DB)

All database traffic must be encrypted to prevent eavesdropping on sensitive badminton academy data.
- **Backend Configuration**: Set `DB_SSLMODE=require` in `.env.prod`.
- **Database Configuration**: Configure the PostgreSQL server to reject non-SSL connections (`ssl = on` in `postgresql.conf` and `hostssl` in `pg_hba.conf`).

## 3. Intrusion Prevention (fail2ban)

To protect against brute-force attacks on SSH or specific API endpoints:
- **Jails**: Configure fail2ban to monitor `/var/log/auth.log` (for SSH) and the Backend application logs.
- **Ban Action**: Identify IPs with more than 5 failed attempts in 10 minutes and null-route them for 1 hour.
- **Config Sample (`/etc/fail2ban/jail.local`)**:
  ```ini
  [sshd]
  enabled = true
  port = ssh
  filter = sshd
  logpath = /var/log/auth.log
  maxretry = 3
  
  [shuttler-api]
  enabled = true
  port = 8000
  filter = shuttler-api
  logpath = /app/logs/access.log
  maxretry = 10
  ```

## 4. Web Application Firewall (WAF)

Deploy a WAF (Cloudflare is recommended) to filter malicious traffic before it reaches the origin server.
- **Rulesets**: Enable OWASP Top 10 protection rules.
- **DDoS Protection**: Enable "I'm Under Attack" mode if necessary.
- **IP Reputation**: Block traffic from known malicious IP lists or high-risk countries if the academy only operates in a specific region (e.g., India).
