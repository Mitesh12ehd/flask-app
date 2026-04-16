pipeline{
    agent any
    environment{
        DOCKER_REPO = "miteshch/demo-app"
        IMAGE_NAME = "flask-app-${BUILD_NUMBER}"
        TARGET_SERVER_PUBLIC_IP = "13.126.207.18"
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
        stage("Deploy application"){
            steps{
                script{
                    echo "Deploying application using new docker image"
                    sshagent(['ec2-server-key']){

                        // Copy docker compose file
                        sh """
                        scp -o StrictHostKeyChecking=no docker-compose.yaml \
                        ec2-user@${TARGET_SERVER_PUBLIC_IP}:/home/ec2-user/
                        """

                        withCredentials([usernamePassword(
                            credentialsId: 'docker-hub-cred',
                            usernameVariable: 'USER',
                            passwordVariable: 'PASS'
                        )]){

                            sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${TARGET_SERVER_PUBLIC_IP} \
                            "echo ${PASS} | docker login -u ${USER} --password-stdin && \
                            cd /home/ec2-user && \
                            docker compose down && \
                            DOCKER_REPO=${DOCKER_REPO} IMAGE_NAME=${IMAGE_NAME} docker compose up -d" && \
                            docker image prune -af
                            """
                        }
                    }
                }
            }
        }
    }
}