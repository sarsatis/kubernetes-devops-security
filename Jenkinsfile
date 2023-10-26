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
        stage('Unit Tests') {
            steps {
                sh "printenv"
                echo 'Implement unit tests if applicable.'
                echo 'This stage is a sample placeholder'
            }
        }
        
        stage('Maven build') {
            steps {
                script {
                    container(name: 'maven') {
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
        }

        // stage('Build Image') {
        //     steps {
        //         script {
        //             writeFile file: "Dockerfile", text: dockerfile
        //             container('kaniko') {
        //                 sh '''
        //                 /kaniko/executor --build-arg NAME=${NAME} --context `pwd` --destination ${IMAGE_REPO}/${NAME}:${VERSION}
        //                 '''
        //             }
        //         }
        //     }
        // }

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
