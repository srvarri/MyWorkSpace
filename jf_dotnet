pipeline {
    agent { label 'JDK11' }
    stages {
        stage('vcs') {
            steps {
                git branch: 'master', url:'https://github.com/srvarri/dotnetcore-docs-hello-world.git'
            }

        }
        stage('dotnet build') {
            steps {
                sh 'dotnet build dotnetcoresample.csproj'
                      
            }
        }
        stage('dotnet publish') {
           steps {
               sh 'dotnet publish dotnetcoresample.csproj'
           }
        }  
        stages('dotnet Archive artifacts') { 
           steps {
             sh 'publish/foo.dll'
           }   
        }    
    }
}    