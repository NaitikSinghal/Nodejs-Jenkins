pipeline {
    agent any
    tools {
      nodejs '20.7.0'
    }
    stages {
        stage('print versions') {
          steps {
            sh 'npm version'
          }
        }
        stage('Install') { 
            steps {
              sh 'npm install'
            }
        }
        stage('Build') { 
            steps {
                sh 'npm run build' 
            }
        }
        stage('codedeploy'){
          steps {
            step([$class: 'AWSCodeDeployPublisher', 
                  applicationName: 'nodejs-application',
                  deploymentGroupAppspec: false,
                  deploymentGroupName: 'nodejs-application-DG', 
                  excludes: '', 
                  iamRoleArn: '',
                  includes: 'dist/',
                  proxyHost: '', 
                  proxyPort: 0, 
                  region: 'eu-north-1',
                  s3bucket: 'deploymasters-node-js',
                  s3prefix: '',
                  subdirectory: '', 
                  versionFileName: '', 
                  waitForCompletion: false,
                 ])
              
           }
        }
    }
}
