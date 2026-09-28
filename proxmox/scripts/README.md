# Kubernetes Join Command

`install-k8s.sh` creates and uses `/tmp/join-command.sh` as follows.

1. The script initializes the control plane by sending `MASTER_INIT` to the primary node over SSH:

   ```bash
   ssh "${SSH_USER}@${MASTER_IP}" "$MASTER_INIT"
   ```

2. Inside `MASTER_INIT`, `kubeadm` creates a bootstrap token and prints a complete worker join command:

   ```bash
   kubeadm token create --print-join-command > /tmp/join-command.sh
   chmod 644 /tmp/join-command.sh
   ```

3. The generated file contains the primary API endpoint, bootstrap token, and cluster CA hash:

   ```bash
   kubeadm join 10.100.1.101:6443 \
     --token <bootstrap-token> \
     --discovery-token-ca-cert-hash sha256:<ca-hash>
   ```

4. The local installation script reads the file from the primary node over SSH:

   ```bash
   JOIN_COMMAND=$(ssh "${SSH_USER}@${MASTER_IP}" 'cat /tmp/join-command.sh')
   ```

5. It sends and executes that command on each worker:

   ```bash
   ssh "${SSH_USER}@${WORKER1_IP}" "sudo $JOIN_COMMAND"
   ssh "${SSH_USER}@${WORKER2_IP}" "sudo $JOIN_COMMAND"
   ```

6. To generate a fresh join command later, run this on the control-plane node:

   ```bash
   sudo kubeadm token create --print-join-command
   ```

The bootstrap token is authentication material. Do not commit an actual generated join command or token to the repository.