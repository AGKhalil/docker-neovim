pipeline {
    triggers {
        pollSCM('H/15 * * * *')
    }
    environment {
        registry = "thornycrackers/neovim"
            registryCredential = 'dockerhub'
    }
    agent any
        stages {
            stage('Cloning Git') {
                steps {
                    git 'https://github.com/thornycrackers/docker-neovim'
                }
            }
            stage('Build') {
                steps {
                    sh 'make setup'
                        sh 'make build'
                }
            }
            stage('Push Image'){
                steps {
                    script {
                        docker.withRegistry( '', registryCredential ) {
                            sh 'make push'
                        }
                    }

                }
            }
        }
}
