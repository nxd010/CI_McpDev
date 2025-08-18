pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                script {
                    sh 'git rev-parse HEAD'
                }
            }
        }
        
        stage('Setup') {
            steps {
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
                archiveArtifacts artifacts: 'mcp_server_build.zip', followSymlinks: false
            }
        }
    }
}