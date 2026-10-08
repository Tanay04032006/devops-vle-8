pipeline {
    agent { label 'vle8-local' }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Verify Environment') {
            steps {
                sh '''
                    docker --version
                    kubectl get nodes
                    minikube status
                '''
            }
        }

        stage('Build Green') {
            steps {
                sh '''
                    docker build -t myapp:v2 \
                      --build-arg APP_VERSION=green ./app

                    minikube image load myapp:v2 --overwrite=true
                '''
            }
        }

        stage('Deploy Green') {
            steps {
                sh '''
                    kubectl apply -f k8s/deployment-green.yaml
                    kubectl rollout restart deployment/myapp-green
                '''
            }
        }

        stage('Verify Green') {
            steps {
                sh '''
                    kubectl rollout status deployment/myapp-green --timeout=180s
                    kubectl get pods -l app=myapp,color=green
                    kubectl get deployment myapp-green
                    kubectl get service myapp-service
                '''
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Green is ready. Switch production traffic from Blue to Green?',
                      ok: 'Switch to Green'
            }
        }

        stage('Switch Traffic') {
            steps {
                sh '''
                    kubectl patch service myapp-service \
                      -p '{"spec":{"selector":{"app":"myapp","color":"green"}}}'

                    kubectl get service myapp-service \
                      -o jsonpath='{.spec.selector.color}'
                    echo
                '''
            }
        }

        stage('Verify Traffic') {
            steps {
                sh '''
                    test "$(kubectl get service myapp-service \
                      -o jsonpath='{.spec.selector.color}')" = "green"

                    kubectl get endpointslices \
                      -l kubernetes.io/service-name=myapp-service
                '''
            }
        }
    }
}
