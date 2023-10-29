// def podTemplate = libraryResource('podTemplate.yaml')
def podTemplate = "podTemplate.yaml"
// def createPrAndAddLabelsScript = libraryResource "CreatePrAndAddLabelsWithOop.py"
// def requirementsTxt = libraryResource "RequirementsWithOop.txt"
// def dockerfile = libraryResource "DockerfileJavaMaven"
def jobNameParts = env.JOB_NAME.split('/')

pipeline {

    agent any

    environment {
        NAME = "${jobNameParts[0]}"
        DEPLOYMENT_NAME = "devsecops"
        CONTAINER_NAME = "devsecops-container"
        VERSION = "${env.GIT_COMMIT}-${env.BUILD_ID}"
        IMAGE_REPO = "sarthaksatish"
        GITHUB_TOKEN = credentials('githubpat')
        SERVICE_NAME = "devsecops-svc"
        APPLICATION_URL="http://34.28.94.32"
        APPLICATION_URI="increment/99"
    }

    stages {
      
        stage('Maven build') {
            steps {
              sh "printenv"
              sh "mvn clean package -DskipTests"
            }
        }

        stage('Maven Test') {
            steps {
              sh "mvn test"
            }
            post{
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }

        stage('Mutation Test - Pit') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post{
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
        }

        // Below stage is without wait timeout it doesnt fail pipeline if sonar is failed
        // stage('SonarQube Analysis') {
        //   steps {
        //     script {
        //         container(name: 'maven') {
        //             sh """
        //             mvn clean verify sonar:sonar \
        //             -Dsonar.projectKey=kubernetes-devops-security \
        //             -Dsonar.projectName='kubernetes-devops-security' \
        //             -Dsonar.host.url=http://34.28.94.32:9000 \
        //             -Dsonar.token=sqp_95c7d3f3a89f89b14c4a7c7d65012b7625119bfd
        //             """
        //         }
        //     }
        //   }
        // }

        stage('SonarQube Analysis') {
          steps {
            withSonarQubeEnv('SonarQube'){
              sh """
              mvn clean verify sonar:sonar \
              -Dsonar.projectKey=kubernetes-devops-security \
              -Dsonar.projectName='kubernetes-devops-security' \
              -Dsonar.host.url=http://34.28.94.32:9000 \
              """
            }
            timeout(time: 2, unit: 'MINUTES'){
              script{
                waitForQualityGate abortPipeline: true
              }
            }
          }
        }

        // stage('Vulnerability Scan - Docker') {
        //   steps {
        //     sh "mvn dependency-check:check"
        //   }
        //   post{
        //     always {
        //       dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        //     }
        //   }
        // }

        stage('Vulnerability Scan - Docker') {
          steps {
            parallel(
              "Dependency Scan": {
                  sh "mvn dependency-check:check"
              },
              "Trivy scan": {
                  sh "bash trivy-docker-image-scan.sh"
              },
              "Opa Conf Test": {
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy dockerfile-security.rego Dockerfile'
              }
            )
          }
          post{
            always {
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            }
          }
        }

        stage('Build Image') {
            steps {
                withDockerRegistry([credentialsId: "docker-hub", url: ""]){
                    sh 'sudo docker build -t ${IMAGE_REPO}/${NAME}:${VERSION} .'
                    sh 'docker push ${IMAGE_REPO}/${NAME}:${VERSION}'
                }
            }
        }

        stage('Vulnerability Scan k8s') {
            steps {
              parallel(
                "OPA Scan":{
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy k8s-security.rego k8s_deployment_service.yaml'
                },
                "kubesec scan":{
                  sh "bash kubesec-scan.sh"
                },
                "Trivy Scan":{
                  sh "bash trivy-k8s-scan.sh"
                }
              )
            }
        }

        // // stage('kubernetes deployment - dev'){
        // //   steps{  
        // //       withKubeConfig([credentialsId: 'kubeconfig']){     
        // //         sh """
        // //           sed -i 's#replace#${IMAGE_REPO}/${NAME}:${VERSION}#g' k8s_deployment_service.yaml
        // //           cat k8s_deployment_service.yaml
        // //           kubectl apply -f k8s_deployment_service.yaml
        // //         """
        // //       }
        // //   }
        // // }

        stage('kubernetes deployment - dev'){
          steps{
            parallel(
              "Deployment": {
                withKubeConfig([credentialsId: 'kubeconfig']){   
                  sh "bash k8s-deployment.sh"
                }
              },
              "Rollout Status": {
                withKubeConfig([credentialsId: 'kubeconfig']){   
                  sh "bash k8s-deployment-rollout-status.sh"
                }
              }
            )
          }
        }

        stage('Integration Tests - Dev'){
          steps{
            script{
              try{
                withKubeConfig([credentialsId: 'kubeconfig']){   
                  sh "bash integration-test.sh"
                }
              }catch(e){
                withKubeConfig([credentialsId: 'kubeconfig']){   
                  sh "kubectl -n mfa rollout undo deploy ${DEPLOYMENT_NAME}"
                }
                throw e
              }
            }
          }
        }
    }
}
