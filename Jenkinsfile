pipeline {
    agent any
	
	environment {
	      DOCKERHUB_REPO = "svbagade24/login-app"
		  IMAGE_TAG = "${BUILD_NUMBER}"
		  MANIFEST_REPO = "https://github.com/s-v-bagade/k8s-manifests-login.git"
	}
	
	stages {
	   
	   stage ('Docker Build') {
	       steps {
		       sh """
			       docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
				   docker tag ${DOCKERHUB_REPO}:${IMAGE_TAG} ${DOCKERHUB_REPO}:latest
			   """
		   }
	   }
	   
	   stage ('Push to Docker Hub') {
	        steps {
			   withCredentials ([usernamePassword(
			       credentialsId: 'dockerhub-creds',
				   usernameVariable: 'Docker_USER',
				   passwordVariable: 'DOCKER_PASS'
				)]) {
				    sh """
					    echo \$DOCKER_PASS | docker login -u \$Docker_USER --password-stdin
						docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
						docker push ${DOCKERHUB_REPO}:latest
					"""
				}
			}
	   }
	   
	   stage ('Checkout Manifest Repo') {
	        steps {
			    dir('manifests') {
				    git branch: 'master',
					url: "${MANIFEST_REPO}",
                                        credentialsId: 'github-cred'
				}
			}
	   }
	   
	   stage ('Deploy to Kubernetes') {
	       steps {
		       withCredentials([file(
			       credentialsId: 'kubeconfig-cred-id',
				   variable: 'KUBECONFIG'
			   )]) {
			       sh """
                                       kubectl apply -f manifests/deployment.yaml -n default
                                       kubectl apply -f manifests/service.yaml -n default 
				       kubectl set image deployment/login-app \
					     login-app=${DOCKERHUB_REPO}:${IMAGE_TAG} \
						 -n default
					   
					   kubectl rollout status deployment/login-app \
					    -n default --timeout=180s
					"""
			   }
		   }
	   }
           
           }
	   
	   post {
	      success {
		      echo "Deployment Successful - image tag ${IMAGE_TAG} is live"
		  }
		  failure {
		      echo "Pipeline failed - rolling back to previous version"
			  withCredentials([file(
			       credentialsId: 'kubeconfig-cred-id',
				   variable: 'KUBECONFIG'
			  )]) {
			      sh 'kubectl rollout undo deployment/login-app -n default'
			  }
		  }
	   }
	


}
