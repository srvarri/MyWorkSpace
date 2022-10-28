pipeline {
    agent { label 'JDK11' }
    stages {
        stage('vcs') {
            steps {
                git branch: 'main', url:'https://github.com/srvarri/js-e2e-express-server.git'
            }

        }
        stage('npm build') {
            steps {
                sh """export PATH="/home/ubuntu/.nvm/versions/node/v16.18.0/bin:$PATH"
                      npm install
                      npm run build
                      npm test"""
            }
        }
    }
}    