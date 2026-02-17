pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    IMAGE_REPO = 'docker.io/${DOCKERHUB_REPO}'
    IMAGE_TAG = "${env.GIT_COMMIT}"
    IMAGE = "${IMAGE_REPO}:${IMAGE_TAG}"
    APP_NAME = 'trov-tver'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('CI - Backend') {
      steps {
        dir('backend') {
          sh 'npm ci'
          sh 'npm test'
          sh 'npm run build --if-present'
        }
      }
    }

    stage('CI - Frontend') {
      steps {
        dir('frontend') {
          sh 'npm ci'
          sh 'npm test -- --watchAll=false --passWithNoTests'
          sh 'npm run build --if-present'
        }
      }
    }

    stage('Docker Build & Push') {
      when {
        anyOf {
          branch 'staging'
          branch 'main'
        }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker build -t "$IMAGE" .
            docker push "$IMAGE"
            docker tag "$IMAGE" "${IMAGE_REPO}:latest"
            docker push "${IMAGE_REPO}:latest"
          '''
        }
      }
    }

    stage('CD - Deploy to Droplet') {
      when {
        anyOf {
          branch 'staging'
          branch 'main'
        }
      }
      steps {
        sshagent(credentials: ['droplet-ssh-key']) {
          sh '''
            ssh -o StrictHostKeyChecking=no ${DROPLET_USER}@${DROPLET_HOST} \
              "APP_NAME='${APP_NAME}' IMAGE='${IMAGE}' APP_PORT='${APP_PORT}' CONTAINER_PORT='3001' MONGO_URI='${MONGO_URI}' NODE_ENV='${DEPLOY_ENV}' bash -s" \
              < scripts/deploy-on-droplet.sh
          '''
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
    success {
      echo "Pipeline completed. Deployed image: ${IMAGE}"
    }
  }
}
