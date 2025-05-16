@Library('my_ocp_sharelib') _  
import com.aviro.OpenShiftHelper  

pipeline {
    agent {
        label 'builder4'
    }
 
    environment {
        OC_TOKEN = credentials('kingopenshift-id')  // Jenkins credentials
        sonarqube_token = credentials('sonar-secret-id')
        OC_SERVER = "https://api.rm1.0a51.p1.openshiftapps.com:6443"
        PROJECT = "kekuda-king-dev"
        IMAGE_NAME = "molacon/paas:latest"
        APP_NAME = "web-terminal-tooling"
        APP_DEPLOYMENT = "workspace62e89aa8716c4c83"
    }
   
    tools {
        maven 'Maven'
    //    jdk 'JDK11'
    }
   
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
       
        stage('Login to OpenShift') {
            steps {
                script {
                    OpenShiftHelper.login(this, OC_TOKEN, OC_SERVER)
                }
            }
        }
       
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
       
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=simple-java-maven-app -Dsonar.projectName="simple-java-maven-app"'
                }
            }
        }
 
        stage('Connect to open shift') {
            steps {
                    sh "oc project ${project}"
            }
        }
 
        stage('Trivy Security Scan') {
 
                                        steps {
 
                                            sh '''
                                            sudo docker run --rm \
                                            -v /var/run/docker.sock:/var/run/docker.sock \
                                            -v $PWD:/root/reports \
                                            aquasec/trivy image \
                                            --format template \
                                            --template "@/contrib/html.tpl" \
                                            -o /root/reports/trivy-report.html \
                                            ${IMAGE_NAME}
                                            '''
 
                                        }
 
                                    }
                                    stage('Publish Trivy Report') {
 
                                        steps {
 
                                            publishHTML(target: [
                                            allowMissing: true,
                                            alwaysLinkToLastBuild: false,
                                            keepAll: true,
                                            reportDir: '.',
                                            reportFiles: 'trivy-report.html',
                                            reportName: 'Trivy Security Report',
                                            alwaysLinkToLastBuild: true
                                            ])
 
                                        }
 
                                    }
 
        //  Optional: Push Docker image to a registry
        // stage('sudo Push Docker Image') {
        //     steps {
        //         withCredentials([usernamePassword(
        //             credentialsId: 'docker-image-id',
        //             usernameVariable: 'DOCKER_USER',
        //             passwordVariable: 'DOCKER_PASS'
        //         )]) {
        //             sh '''
        //                 echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin
        //                 sudo docker push ${IMAGE_NAME}:${IMAGE_TAG}
        //             '''
        //         }
        //     }
        // }
 
        // stage('Deploy Docker Image') {
        //     steps {
        //             sh 'docker run ${IMAGE_NAME}:${IMAGE_TAG} -p 8888:8080'
        //     }
        // }
 
 
        stage('Push to openshift') {
            steps {
                script {
                    sh "oc new-app ${IMAGE_NAME} -name=${APP_NAME} --namespace=${PROJECT}"
                }
            }
        }
       
        // The good things at the end
        // stage('Quality Gate') {
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
 
    }
}
 