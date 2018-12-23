include:
  - k8s

init_k8s_cluster:
  cmd.run:
    - name: kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.1.0.2
    - unless: test -f /etc/kubernetes/manifests/kube-apiserver.yaml
    - require:
      - service: kubelet

# Configure kubectl
configure-kubectl:
  cmd.run:
    - name: |
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config
    - unless: test -f $HOME/.kube/config
    - require:
      - cmd: init_k8s_cluster

# Install CNI Flannel
install-flannel:
  cmd.run:
    - name: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
    - require:
      - cmd: configure-kubectl
