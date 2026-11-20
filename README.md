# inet4031-team-1


| Name | Email |
|---|---|
| Tim Revnew |revne003@umn.edu |TrevnewUMN |
| Aisha |abdul785@umn.edu |
| Mohamud |abdal110@umn.edu |
| Jama | aden0100@umn.edu|
| Anwar | ahme1221@umn.edu| 


Port: 8081

Project Board: https://github.com/users/TrevnewUMN/projects/2

Google Doc Link: https://docs.google.com/document/d/1jXFGI4mOJ7J8z_GTm8XBg73XenUyOn21bZ06uHsus9M/edit?usp=sharing

## Project Overview

This repository contains Team 1's work for INET 4031. Our project uses a three-tier application with Nginx as the frontend, Flask as the backend, and PostgreSQL as the database.

Throughout the labs, we worked with Docker Compose, Kubernetes (k3d), Ansible, and OpenTofu to deploy and manage the application.

## Application Architecture

The application has three main components:

- **Frontend:** Nginx serves the application and forwards API requests to Flask.
- **Backend:** Flask processes application requests and communicates with the database.
- **Database:** PostgreSQL stores application data.

The goal of this project is to automate deployment, keep the application running, and make it easier to rebuild the environment when needed.


## Week 2 - Docker Compose

During Week 2, our team worked on deploying a three-tier application using Docker Compose.

- Set up the Nginx frontend, Flask backend, and PostgreSQL database.
- Used Docker Compose to run the application services together.
- Added health checks to help monitor the containers.
- Used a persistent volume for database storage.
- Worked with Ansible to automate the deployment process.

The Week 2 application files are located in the `week-2/` folder.

## Week 3 - Kubernetes and k3d

During Week 3, our team worked on moving the application from Docker Compose to Kubernetes using k3d.

- Created a Kubernetes cluster using k3d.
- Worked on deploying the Nginx, Flask, and PostgreSQL components.
- Used Kubernetes services to connect the application components.
- Worked with health checks, replicas, and persistent database storage.
- Started organizing Kubernetes configuration files in the `manifests/` folder.

Some Week 3 setup files and automation still need to be checked and completed.

## Week 4 - OpenTofu

During Week 4, our team worked on using OpenTofu to manage part of our Kubernetes deployment.

- Added OpenTofu configuration files in the `infrastructure/` folder.
- Configured the Kubernetes provider and local state backend.
- Updated the Flask configuration to use three replicas.
- Added an Ansible role for installing OpenTofu.
- Added a Week 4 validation script and QA report.

The OpenTofu changes were merged into the main branch through pull request #32. The remaining checker failures and full rebuild still need to be verified.


## Ansible Automation

The `ansible/` folder holds our automation playbooks and roles. As the Week 1 Wiki instructs, they are written and committed for reference and for rebuilding on an empty VM, but they are **not run on the shared lab VM**. Bringing the app up does not depend on them.

`ansible/site.yml` grows one play per week (Weeks 1 to 4), run with `ansible/inventory` (localhost):

| Week | Play (role) | What it does |
| --- | --- | --- |
| 1 | Baseline environment setup | Installs baseline packages (curl, git, vim, Python), EPEL, ansible-core and Docker CE; starts Docker and adds the user to the `docker` group |
| 2 | Deploy application stack (`app-stack`) | Brings up the Docker Compose stack. Commented out in Week 3 because the app now runs on Kubernetes |
| 3 | Set up k3d cluster (`k3d-setup`) | Installs k3d if missing and creates the `team1` cluster (2 agents, port 8091, subnet 100.97.1.0/24) |
| 4 | Initialize OpenTofu (`opentofu-setup`) | Confirms OpenTofu is installed and runs `tofu init` in `infrastructure/` |

Other playbooks, separate from `site.yml`:

- `ansible/lab5-node-exporter.yml` (inventory `ansible/inventory-lab5`, role `node-exporter`): Lab 5 Canvas Task 1, turns on node-exporter for every node of the `team1` cluster and checks `/metrics` on port 9100. It uses Helm and kubectl as the logged-in user, and is the one playbook we ran on the lab VM.
- `ansible/firewall-hardening.yml` (role `firewall-hardening`): Lab 7 Canvas Task 1, a ufw default-deny policy for web, app and db hosts. Reference only: the shared lab VM has no separate web, app or db hosts.

## Environment Recovery

One goal of this project is to make it possible to rebuild the application using the files stored in GitHub.

The main project folders are:

- `week-2/` - Docker Compose application files.
- `manifests/` - Kubernetes configuration files.
- `infrastructure/` - OpenTofu configuration files.
- `ansible/` - Automation playbooks and roles.
- `scripts/` - Validation and checking scripts.
- `docs/` - QA reports and project documentation.

### Recovery Plan

1. Clone the team GitHub repository.
2. Install the required tools, including Docker, Ansible, kubectl, k3d, and OpenTofu.
3. Review the Ansible playbooks and configuration files.
4. Recreate the Kubernetes cluster using the completed k3d setup process.
5. Deploy the application using the appropriate Kubernetes and OpenTofu configurations.
6. Run the validation scripts and check the application health.

This is our planned recovery process. A complete rebuild still needs to be tested.

## Known Issues and Remaining Work

- The shared VM has experienced low disk space, which caused Kubernetes pods to be evicted.
- The Flask container image needs to be restored before the application can run successfully.
- Week 3 Kubernetes manifests and Ansible automation need to be reviewed.
- The Week 3 validation script and QA report still need to be completed and checked.
- The Flask image name needs to be consistent between the Kubernetes cluster and OpenTofu configuration.
- The full environment recovery process still needs to be verified.
