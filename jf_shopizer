pipeline {
    agent { label 'jdk11' }
    triggers { pollSCM('* * * * *') }
    stages {
        stage('vcs') {
            steps {
                git branch: 'develop', url:'https://github.com/srvarri/shopizer.git'
            }

        }
        stage('build') {
            steps {
                sh '/usr/share/maven/bin/mvn package'
            }
        }

        stage('archive results') {
            steps {
                junit '**/surefire-reports/*.xml'
            }
        }
		stage ( 'artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar'
            }
		}
    }    
}    