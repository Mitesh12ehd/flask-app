pipeline{
    agent any
    environment{
        DOCKER_REPO = "miteshch/demo-app"
        IMAGE_NAME = "flask-app-$BUILD_NUMBER"
    }
    stages{
        stage("Build image"){
            steps{
                script{
                    echo "Building the docker images"
                    sh "docker build -t ${DOCKER_REPO}:${IMAGE_NAME} ."
                }
            }
        }
        stage("Pushing image to private repository"){
            steps{
                script{
                    echo "Pushing image to private docker hub repository"

                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub-cred',
                            usernameVariable: 'USER',
                            passwordVariable: 'PASS'
                        )
                    ]){
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                        sh "docker push ${DOCKER_REPO}:${IMAGE_NAME}"
                    }
                }
            }
        }
    }
}