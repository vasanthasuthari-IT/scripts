pipeline {
    agent any

    parameters {
        string(
            name: 'VM_NAME',
            defaultValue: 'rundeck',
            description: 'VM name tag (e.g. rundeck, sandbox, development, etc.)'
        )
        string(
            name: 'HOST_IPS',
            defaultValue: '',
            description: 'Comma-separated public IPs of the target VMs (e.g. 1.2.3.4,5.6.7.8)'
        )
    }

    environment {
        SSH_USER = 'ec2-user'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Initial Setup') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    script {
                        def ips = params.HOST_IPS
                            .split(',')
                            .collect { it.trim() }
                            .findAll { it }

                        if (!ips) {
                            error "HOST_IPS is empty — provide comma-separated IPs of target VMs"
                        }

                        def parallelSteps = [:]

                        ips.each { ip ->
                            def host = ip
                            parallelSteps["${params.VM_NAME} @ ${host}"] = {
                                sh """
                                    chmod 400 \$SSH_KEY
                                    ssh -i \$SSH_KEY \\
                                        -o StrictHostKeyChecking=no \\
                                        -o ConnectTimeout=15 \\
                                        ${SSH_USER}@${host} \\
                                        'sudo bash -s' < initial_setup.sh
                                """
                            }
                        }

                        parallel parallelSteps
                    }
                }
            }
        }

    }

    post {
        success {
            echo "Initial setup completed on all ${params.VM_NAME} instances"
        }
        failure {
            echo "Setup failed on one or more instances — check logs above"
        }
    }
}
