#!jinja|yaml

# disable swap
swapoff:
  cmd.run:
    - name: | 
        swapoff -a
        sed -i '/swap/d' /etc/fstab

# set Selinux to permissive
permissive:
    selinux.mode

selinux_permissive_persist:
  cmd.run:
    - name: |
        sed -i 's/enforcing/permissive/g' /etc/selinux/config 

# Create Repo file for kubernetes
kubernetes-repo:
  pkgrepo.managed:
    - humanname: Kubernetes
    - baseurl: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    - gpgcheck: 1
    - gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

# Install all required packages
package-install:
  pkg.installed:
    - pkgs: ['docker', 'kubelet', 'kubeadm', 'kubectl']
    - require:
      - pkgrepo: kubernetes-repo

# Enable and start services
kubelet:
  service.running:
    - enable: True
    - reload: True

docker:
  service.running:
    - enable: True
    - reload: True

# Configure sysctl
net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

