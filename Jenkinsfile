pipeline {
    agent any

    parameters {
        string(
            name: 'VM_NAME',
            defaultValue: 'rundeck',
            description: 'VM name tag (e.g. rundeck, jenkins, orlando)'
        )
        string(
            name: 'HOST_IPS',
            defaultValue: '',
            description: 'Comma-separated public IPs of target VMs (e.g. 1.2.3.4,5.6.7.8)'
        )
        choice(
            name: 'SCRIPT',
            choices: ['initial_setup.sh', 'install_rundeck.sh'],
            description: 'Script to run on the target VMs'
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

        stage('Run Script') {
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

                        echo "Script  : ${params.SCRIPT}"
                        echo "VM      : ${params.VM_NAME}"
                        echo "Targets : ${ips.join(', ')}"

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
                                        'sudo bash -s' < ${params.SCRIPT}
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
            echo "${params.SCRIPT} completed successfully on all ${params.VM_NAME} instances"
        }
        failure {
            echo "${params.SCRIPT} failed on one or more instances — check logs above"
        }
    }
}
