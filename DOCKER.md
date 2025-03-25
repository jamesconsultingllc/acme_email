# Docker Setup for ACME Email S/MIME Client

This document explains how to use Docker to run the ACME Email S/MIME client.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)

## Building and Running

### Using Helper Scripts (Windows)

For Windows users, we've provided two helper scripts to make running the containerized application easier:

1. Batch file (CMD):
   ```cmd
   docker-run.bat cert -e your-email@domain.com [other options]
   ```

2. PowerShell script:
   ```powershell
   .\docker-run.ps1 cert -e your-email@domain.com [other options]
   ```

These scripts will automatically:
- Check if Docker is installed
- Create necessary directories
- Build the Docker image if it doesn't exist
- Run the container with the proper volume mounts

### Using Docker Compose (Recommended)

1. Build the Docker image:
   ```bash
   docker compose build
   ```

2. Run the client with your desired parameters:
   ```bash
   docker compose run --rm acme-email-client cert -e your-email@domain.com [other options]
   ```

   For example, to run with IMAP authentication:
   ```bash
   docker compose run --rm acme-email-client cert -e your-email@domain.com --contact contact@domain.com --imap --login imap_user --password imap_password --host imap.domain.com --ssl --smtp-method STARTTLS --smtp-host smtp.domain.com --smtp-port 587
   ```

### Using Docker Directly

1. Build the Docker image:
   ```bash
   docker build -t acme-email-client .
   ```

2. Run the container:
   ```bash
   docker run --rm -v $(pwd)/letsencrypt:/etc/letsencrypt -v $(pwd)/letsencrypt-lib:/var/lib/letsencrypt -v $(pwd)/letsencrypt-log:/var/log/letsencrypt acme-email-client cert -e your-email@domain.com [other options]
   ```

## Directory Structure

The Docker setup creates these volume mounts for persistent storage:

- `./letsencrypt:/etc/letsencrypt` - Stores certificates and related files
- `./letsencrypt-lib:/var/lib/letsencrypt` - Stores intermediate files
- `./letsencrypt-log:/var/log/letsencrypt` - Stores log files

## Windows-Specific Instructions

When using Docker on Windows, use the appropriate path syntax:

```cmd
docker run --rm -v %cd%\letsencrypt:/etc/letsencrypt -v %cd%\letsencrypt-lib:/var/lib/letsencrypt -v %cd%\letsencrypt-log:/var/log/letsencrypt acme-email-client cert -e your-email@domain.com [other options]
```

Or with PowerShell:

```powershell
docker run --rm -v ${PWD}/letsencrypt:/etc/letsencrypt -v ${PWD}/letsencrypt-lib:/var/lib/letsencrypt -v ${PWD}/letsencrypt-log:/var/log/letsencrypt acme-email-client cert -e your-email@domain.com [other options]
```

## Example Commands

Here are some common command examples:

1. Getting a certificate using IMAP authentication:
   ```
   docker-run.bat cert -e your-email@domain.com --contact contact@domain.com --imap --login your-username --password your-password --host imap.domain.com --ssl --smtp-method STARTTLS --smtp-host smtp.domain.com --smtp-port 587
   ```

2. Revoking a certificate:
   ```
   docker-run.bat revoke --cert-path ./letsencrypt/live/your-email@domain.com/cert.p12 --passphrase your-passphrase
   ```

3. Testing with the staging server:
   ```
   docker-run.bat cert -e your-email@domain.com -t [other options]
   ```

## Limitations

- The Outlook authenticator requires running with Administrator privileges on Windows, which is not compatible with Docker. Use the Interactive or IMAP authenticator instead when running in Docker.
- For the Thunderbird authenticator, you'd need X11 forwarding which is beyond the scope of this basic setup.

## Accessing Certificates

Your certificates will be stored in the `./letsencrypt` directory on your host machine. To find the exact location of your certificates, check the output after successfully running the client. 