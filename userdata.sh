#!/bin/bash
sudo apt install containerd -y
sudo apt update
sudo apt install docker.io -y
sudo apt install --reinstall ca-certificates -y
sudo update-ca-certificates
sudo systemctl restart docker
sudo usermod -aG docker $USER

mkdir -p /home/ubuntu/devlake 
cd /home/ubuntu/devlake

# Create docker-compose.yml for OpenProject
cat > docker-compose.yml << 'EOF'
#
version: "3"
services:
  mysql:
    image: mysql:8
    volumes:
      - mysql-storage:/var/lib/mysql
    restart: always
    ports:
      - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: admin
      MYSQL_DATABASE: lake
      MYSQL_USER: merico
      MYSQL_PASSWORD: merico
      TZ: UTC
    command: --character-set-server=utf8mb4
      --collation-server=utf8mb4_bin
      --skip-log-bin

  grafana:
    image: devlake.docker.scarf.sh/apache/devlake-dashboard:v1.0.3-beta5
    ports:
      - 3002:3000
    volumes:
      - grafana-storage:/var/lib/grafana
    environment:
      GF_SERVER_ROOT_URL: "http://localhost:4000/grafana"
      GF_USERS_DEFAULT_THEME: "light"
      MYSQL_URL: mysql:3306
      MYSQL_DATABASE: lake
      MYSQL_USER: merico
      MYSQL_PASSWORD: merico
      TZ: UTC
    restart: always
    depends_on:
      - mysql

  devlake:
    image: devlake.docker.scarf.sh/apache/devlake:v1.0.3-beta5
    ports:
      - 8080:8080
    restart: always
    volumes:
      - devlake-log:/app/logs
    env_file:
      - ./.env
    environment:
      LOGGING_DIR: /app/logs
      ENCRYPTION_SECRET: "IIUHPSBLAOQGNSJUKTYWHNFOLCCOMXBDUWUUAWWGKISEXHLBKEINIDJKRTMBQNGVPQBTABEHGHGQDLESQKZCWRBXTYGWHNNOZPLFLMMPJCTIJOWYHOBJQSBYKJEJNSCZ" 
      TZ: UTC
    depends_on:
      - mysql

  config-ui:
    image: devlake.docker.scarf.sh/apache/devlake-config-ui:v1.0.3-beta5
    ports:
      - 4000:4000
    env_file:
      - ./.env
    environment:
      DEVLAKE_ENDPOINT: devlake:8080
      GRAFANA_ENDPOINT: grafana:3000
      TZ: UTC
      #ADMIN_USER: devlake
      #ADMIN_PASS: merico
    depends_on:
      - devlake

volumes:
  mysql-storage:
  grafana-storage:
  devlake-log:
EOF

cat > .env << 'EOF'

# Lake plugin dir, absolute path or relative path
PLUGIN_DIR=bin/plugins
REMOTE_PLUGIN_DIR=python/plugins

# Lake Database Connection String
DB_URL=mysql://merico:merico@mysql:3306/lake?charset=utf8mb4&parseTime=True&loc=UTC
E2E_DB_URL=mysql://merico:merico@mysql:3306/lake_test?charset=utf8mb4&parseTime=True&loc=UTC
# Silent Error Warn Info
DB_LOGGING_LEVEL=Error
# Skip to update progress of subtasks, default is false (#8142)
SKIP_SUBTASK_PROGRESS=false

# Lake REST API
PORT=8080
MODE=release

NOTIFICATION_ENDPOINT=
NOTIFICATION_SECRET=

API_TIMEOUT=120s
API_RETRY=3
API_REQUESTS_PER_HOUR=10000
PIPELINE_MAX_PARALLEL=1
# resume undone pipelines on start
RESUME_PIPELINES=true
# Debug Info Warn Error
LOGGING_LEVEL=
LOGGING_DIR=./logs
ENABLE_STACKTRACE=true
FORCE_MIGRATION=false

# Lake TAP API
TAP_PROPERTIES_DIR=

DISABLED_REMOTE_PLUGINS=

##########################
# Sensitive information encryption key
##########################
ENCRYPTION_SECRET=

##########################
# Security settings
##########################
# Set if skip verify and connect with out trusted certificate when use https
IN_SECURE_SKIP_VERIFY=false
# Forbid accessing sensity networks, CIDR form separated by comma: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
ENDPOINT_CIDR_BLACKLIST=
# Do not follow redirection when requesting data source APIs
FORBID_REDIRECTION=false

##########################
# In plugin gitextractor, use go-git to collector repo's data
##########################
USE_GO_GIT_IN_GIT_EXTRACTOR=false
# NOTE that COMMIT_FILES is part of the COMMIT_STAT
SKIP_COMMIT_STAT=false
SKIP_COMMIT_FILES=true

# Set if response error when requesting /connections/{connection_id}/test should be wrapped or not
##########################
WRAP_RESPONSE_ERROR=

# Enable subtasks by default: plugin_name:subtask_name:enabled
ENABLE_SUBTASKS_BY_DEFAULT="jira:collectIssueChangelogs:true,jira:extractIssueChangelogs:true,jira:convertIssueChangelogs:true,tapd:collectBugChangelogs:true,tapd:extractBugChangelogs:true,tapd:convertBugChangelogs:true,zentao:collectBugRepoCommits:true,zentao:extractBugRepoCommits:true,zentao:convertBugRepoCommits:true,zentao:collectStoryRepoCommits:true,zentao:extractStoryRepoCommits:true,zentao:convertStoryRepoCommits:true,zentao:collectTaskRepoCommits:true,zentao:extractTaskRepoCommits:true,zentao:convertTaskRepoCommits:true"
EOF

sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

sudo docker-compose up -d
