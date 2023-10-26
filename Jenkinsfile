// def podTemplate = libraryResource('podTemplate.yaml')
def podTemplate = "podTemplate.yaml"
// def createPrAndAddLabelsScript = libraryResource "CreatePrAndAddLabelsWithOop.py"
// def requirementsTxt = libraryResource "RequirementsWithOop.txt"
// def dockerfile = libraryResource "DockerfileJavaMaven"
def jobNameParts = env.JOB_NAME.split('/')

pipeline {
    agent {
        kubernetes {
            label "jenkins-${UUID.randomUUID().toString()}"
            yamlFile "$podTemplate"
        }
    }
    environment {
        NAME = "${jobNameParts[0]}"
        VERSION = "${env.GIT_COMMIT}-${env.BUILD_ID}"
        IMAGE_REPO = "sarthaksatish"
        GITHUB_TOKEN = credentials('githubpat')
    }
    stages {
  
        stage('Maven build') {
            steps {
                script {
                    container(name: 'maven') {
                        sh "printenv"
                        sh "mvn clean package -DskipTests"
                    }
                }
            }
        }

        stage('Maven Test') {
            steps {
                script {
                    container(name: 'maven') {
                        sh "mvn test"
                    }
                }
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
                script {
                    container(name: 'maven') {
                        sh "mvn org.pitest:pitest-maven:mutationCoverage"
                    }
                }
            }
            post{
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // writeFile file: "Dockerfile", text: dockerfile
                    container('kaniko') {
                        sh '''
                        /kaniko/executor --build-arg NAME=${NAME} --context `pwd` --destination ${IMAGE_REPO}/${NAME}:${VERSION}
                        '''
                    }
                }
            }
        }

        stage('kubernetes deployment'){
          steps{
            script{
              container('kubectl'){    
                withKubeConfig([credentialsId: 'kubeconfig']){     
                  sh """
                    sed -i 's#replace#sarthaksatish/kubernetes-devops-security:${VERSION}#g' k8s_deployment_service.yaml
                    cat k8s_deployment_service.yaml
                    kubectl apply -f k8s_deployment_service.yaml
                  """
                }
              }
            }
          }
        }

        // stage('Raise PR') {
        //     steps {
        //         script {
        //             writeFile file: "CreatePrAndAddLabel.py", text: createPrAndAddLabelsScript
        //             writeFile file: "requirements.txt", text: requirementsTxt
        //             container(name: 'python') {
        //                 // In case if you have internal repository which needs certificates it needs to be set like this
        //                 // add the below set command in sh block
        //                 // set -e
        //                 // export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
        //                 sh '''
        //                     pip3 install -r requirements.txt
        //                     python3 CreatePrAndAddLabel.py
        //                 '''
        //             }
        //         }
        //     }
        // }
    }
}
