pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "swathikambam/test" // Docker Hub repository name
        TAG = "${BUILD_NUMBER}" // Image tag
        AWS_REGION = 'us-east-1' // Your AWS region
        EKS_CLUSTER_NAME = 'my-cluster1' // Your EKS cluster name
        HELM_CHART_PATH = 'helm-nft' // Path to the Helm chart in the repo (helm-nft directory)
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone the GitHub repository
                git url: 'https://github.com/Swathikambp188/devops_assignment.git', branch: 'main'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_IMAGE}:${TAG} ."
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    // Log in to Docker Hub using Jenkins credentials
                    withDockerRegistry([credentialsId: 'docker-cred', url: '']) {
                        // Push the Docker image to Docker Hub
                        sh "docker push ${DOCKER_IMAGE}:${TAG}"
                    }
                }
            }
        }

        stage('Setup AWS Credentials') {
            steps {
                script {
                    // Fetch AWS credentials and update the kubeconfig for EKS
                    withCredentials([usernamePassword(credentialsId: 'aws-cred', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            # Ensure AWS CLI uses the correct credentials
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            export AWS_DEFAULT_REGION=${AWS_REGION}
                            
                            # Update kubeconfig to access the EKS cluster
                            aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME} --kubeconfig .kube/config
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS via Helm') {
            steps {
                script {
                    // Navigate to the Helm chart directory and deploy using Helm
                    dir(HELM_CHART_PATH) {
                        // Deploy to EKS using Helm, passing the Docker image and tag as values
                        sh """
                            helm upgrade --install my-release ./ --set image.repository=${DOCKER_IMAGE} --set image.tag=${TAG} --kubeconfig .kube/config
                        """
                    }
                }
            }
        }
        stage('Deploy Kubernetes monitoring Resources') {
            steps {
                script {
                    // Deploy additional YAML files to the EKS cluster
                    sh """
                        kubectl apply -f ns.yaml --kubeconfig .kube/config
                        kubectl apply -f elstic.yaml --kubeconfig .kube/config
                        kubectl apply -f kibana.yaml --kubeconfig .kube/config
                        kubectl apply -f kibana-svc.yaml --kubeconfig .kube/config
                        kubectl apply -f logstash-cm.yaml --kubeconfig .kube/config
                        kubectl apply -f logstash.yaml --kubeconfig .kube/config
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
