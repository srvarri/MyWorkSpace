pipeline {
    agent { label 'py3.9' }
    stages {
        stage('vcs') {
            steps {
                git branch: 'master', url:'https://github.com/srvarri/python-webcount.git'
            }

        }
        stage('build') {
            steps {
                sh '''pip3 install -r requirements.txt
                      tox'''
            }
        }

        stage('test reports') {
            steps {
                junit 'junit-py39.xml'
            }
        }
        stage('artifacts') {
            steps {
               archiveArtifacts artifacts: '**/webcount-0.1.zip'
            }
        }
    }
}            