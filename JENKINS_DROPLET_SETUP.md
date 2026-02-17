# Jenkins + Droplet CI/CD Setup (Mirror of `.github/workflows`)

This setup mirrors your GitHub Actions phases:

1. **CI phase**: install, test, build backend + frontend
2. **CD phase**: build Docker image, push registry, deploy to node

## 1) What to configure in GitHub

## Repository settings
- Keep source code in GitHub as now.
- Branches:
  - `staging` for staging deployment
  - `main` for production deployment

## Optional webhook to Jenkins
- In GitHub repo: **Settings → Webhooks → Add webhook**
- Payload URL: `https://<jenkins-domain>/github-webhook/`
- Content type: `application/json`
- Events: push + pull request

> If webhook is not used, Jenkins can poll SCM.

---

## 2) What to configure in Jenkins

## Required plugins
- Pipeline
- Git
- GitHub Integration
- Credentials Binding
- SSH Agent
- Workspace Cleanup

## Global tools
- NodeJS 18 (or available equivalent)
- Docker CLI available on Jenkins executor

## Credentials
Create these credentials IDs exactly:

1. `dockerhub-creds` (Username + Password)
   - Username: Docker Hub username
   - Password: Docker Hub token/password

2. `droplet-ssh-key` (SSH Username with private key)
   - Username: droplet user (example `deploy`)
   - Private key: key that can SSH into droplet

## Jenkins job (Pipeline from SCM)
- Type: **Pipeline**
- SCM: Git
- Repository: your GitHub repo URL
- Script Path: `Jenkinsfile`
- Trigger: GitHub webhook (recommended) or poll SCM

## Jenkins environment variables (Job/Folder level)
Define these:

- `DOCKERHUB_REPO` → e.g. `yourdockeruser/trov-tver`
- `DROPLET_HOST` → droplet public IP or DNS
- `DROPLET_USER` → e.g. `deploy`
- `APP_PORT` → host port, e.g. `3001`
- `MONGO_URI` → Mongo connection string for target env
- `DEPLOY_ENV` → `staging` or `production`

> For per-branch env separation, use separate Jenkins jobs or conditional env mapping.

---

## 3) What to configure on the droplet node

Run as root once:

```bash
sudo bash scripts/droplet-setup.sh <dockerhub_username> <deploy_user>
```

Example:

```bash
sudo bash scripts/droplet-setup.sh mydockeruser deploy
```

This script:
- installs Docker Engine + Compose plugin
- creates deploy user and adds to docker group
- opens firewall ports (22, 80, 443, 3001)
- prepares `/opt/trov-tver`

After that, login once on droplet as deploy user:

```bash
docker login -u <dockerhub_username>
```

---

## 4) Deployment behavior on the droplet

Jenkins runs `scripts/deploy-on-droplet.sh` remotely over SSH.

Deployment logic:
- pull `${IMAGE}`
- remove old container if exists
- run new container with:
  - `--restart unless-stopped`
  - `-p APP_PORT:3001`
  - `MONGO_URI` and `NODE_ENV`
- verify container is up

Container naming:
- `${APP_NAME}-app` (default app name in Jenkinsfile is `trov-tver`)

---

## 5) Phase mapping from GitHub Actions to Jenkins

From `.github/workflows/ci-pipeline.yml`:
- Backend `npm ci`, `npm test`, optional build
- Frontend `npm ci`, `npm test -- --watchAll=false --passWithNoTests`, optional build

From `.github/workflows/cd-pipeline.yml`:
- test gate first
- Docker build + push image
- deploy to environment

In Jenkinsfile:
- `CI - Backend`
- `CI - Frontend`
- `Docker Build & Push`
- `CD - Deploy to Droplet`

---

## 6) First run checklist

1. Push `Jenkinsfile` + `scripts/` to GitHub.
2. Ensure Jenkins agent has Docker CLI and can run docker.
3. Add Jenkins credentials + env vars.
4. Test SSH from Jenkins to droplet using `droplet-ssh-key`.
5. Trigger pipeline on `staging` branch.
6. Verify app responds at `http://<droplet-host>:<APP_PORT>/api/health`.
