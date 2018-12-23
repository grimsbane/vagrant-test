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

# Configure sysctl
net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1
    - require:
      - service: docker

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1
    - require:
      - service: docker

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1
    - require:
      - service: docker

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
    - require:
      - pkg: package-install

docker:
  service.running:
    - enable: True
    - reload: True
    - require:
      - pkg: package-install

# File or HTTPS-based discovery - https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/
test-file:
  file.managed:
    - name: /tmp/discovery-file.conf
    - contents: |
        apiVersion: v1
        kind: Config
        clusters:
        - cluster:
            certificate-authority-data: |
                certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNE1USXlNekV6TXpJeU5Gb1hEVEk0TVRJeU1ERXpNekl5TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT2lQCmpleEdjWVprK3JabVFjM3BDQ3NYWVJQRGRRSmlieWJBZXd5TWtWTmVkZnY4eU90dzJhZzNwOW8zQXNxMlhUc3UKOE1xYlhKSUpFRkxYM0c1M2RFNnRoK1Y4QkpZREpnbUVQRklzQ01KdGo4WDZ3eHQ3RG4yU1pzVldseGdwMFJuYgpOZm1nNXlxVEhzVXFQWlJHUW5XL2t2NzVRTklGdTJPLzhSWnVWaDkzdkxxb3dGM0dmdUZKZ0htMW1MNjVIS3NMCnJGbzJIbWdPeXgzUkVqNE41VDdiS0xXODZnNElyK0lqelZWV3RqTnlRQUtiendYMXdUY1NhMFRuOHZPSzhEbVUKUDdZVEVJWHVwNmxud2lnazNxTXZuSFQ5c0MxR3RHdS9EbHM5K0pVQjN1WmZCa1ZONWpTSFZQZmlBWjNwY1dRUgpDc1MvN1F2dlUxaWpMTG56RHY4Q0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFOazBtV1Y0K2xhNzN1LzQ0clpPN3RXRDJ2bUUKOXU2VkJLa0c2VHRxdEUwaXFPeW1GVFIrelFTN0ZVdkkwRFJyczFlSlJxdW9FblNKVUNaU05RSzZIOS9oeFp1RApVRTEvYjhqcEMrRnZaK1cxQzhlVFRyQ2t2UU1MV3poa0hwSVFTaHlIa2FUSGIvWWFJUE5kOHE3MStaTGpHYzFaCm4vd2JCLzZSaCsyS0lOSmZQSmxpR01FdmZvQmVkbG56Njd6cUo5UnVQZWpRT2d2cFRxKytNOFdSWDliZElWenYKb3g0cG9TMVRmN3JTRDN6SVV4ZVE3N1FuRGhwMmVBQ2N5Z0FyWHNGbzJQeGxhckZnY1ZwN3ovVDNJVE5nNFR6SwpVazMwSkJzNytBWjVGQTVtMjZLVjVkNWowMmlUREx1SmpZNDEveTMzM3huSWdyRktOZ2ExZDE3cldWQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
            server: https://{{ pillar['kubernetes']['apiserver_advertise_address'] }}:6443
          name: ""
          contexts: []
          current-context: ""
          preferences: {}
          users: []







