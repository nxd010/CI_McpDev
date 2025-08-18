pipeline {
    agent {
        docker {
            image 'python:3.11-slim'
            args '-u root'
        }
    }

    stages {        
        stage('Setup') {
            steps {
                sh 'apt-get update'
                sh 'apt-get install -y git zip binutils'
                sh 'apt-get install -y python3 python3-pip'
                sh 'pip3 install -r requirements.txt'
            }
        }
        
        stage('Build') {
            steps {
                sh 'pyinstaller mcp_server/server.py --onefile --distpath=dist'
            }
        }
        
        stage('Package') {
            steps {
                sh 'zip -r mcp_server.zip dist'
                archiveArtifacts artifacts: 'mcp_server.zip', followSymlinks: false
            }
        }
    }
}