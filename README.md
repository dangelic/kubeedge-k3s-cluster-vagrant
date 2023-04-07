### Features: K3s and KubeEdge Dev environment

- Automatically spins up a configurable network-connected set of VMs via Vagrant and VirtualBox 
- Provides shell scripts to set up a virtual multi-node Dev Edge Cluster with few commands
- Leverages K3s v2.3.5 and KubeEdge v1.3.0 for a lightweight Edge Dev Environment 
- Sets containerd as CRI (instead of standard configuration via Docker) on all Cluster Nodes
- Optionally configures Rancher v2.7.0 for convenient Cluster Management
- **Upcoming:** GitOps integration and EdgeMesh network features

# Get started
**Table of Contents**

## Virtual Cluster environment
### Prerequsites
1. Install Oracle VM VirtualBox as Hypervisor: https://www.virtualbox.org
2. Install Vagrant as provisioning tool: https://www.vagrantup.com

### Configure and spin up VMs via Vagrant and VirtualBox
Clone this repository and navigate into root directory:

```
$ cd kubeedge-k3s-cluster-vagrant
```

Rename the cluster outline sample directory and configure further to adust the default VM config:

```
$ mv vm_cluster_outline.sample vm_cluster_outline 
```

Rename the .env sample and configure further to adust the default setup: 

```
$ mv .env.sample .env
```

**Spin-up**: Run the following command in the root of the directory:
```
$ vagrant up
```
***NOTE:*** This can take up to several miutes, so be patient!

## K3s and KubeEdge bootstrap
### Cloudside
Run the following command from the host machine to ssh into the VM serving as the Cloud part:
````
vagrant ssh <Hostname of Cloudside VM>
````
Navigate into the synced folder and run the bootstrap script (with sudo) using the appropriate flag value:
````
$ sudo su
$ cd bootstrap/boostrap_cloudside
$ sh bootstrap_cloudside.sh \ 
--cloudside-ip=<IP of Cloudside VM>
````

Run the following command to see the Kubeadm token to join the Edge Nodes:

```
$ cat ketoken.txt
```

NOTE: If the .txt file is empty, run the following command to get the token:

```
$ keadm gettoken
```
### Edgeside
***Repeat the following procedure for every Edge Node that should be joined to the K3s/KubeEdge-Cluster:***

Run the following command from the host machine to ssh into the VM serving as an Edge Node:
````
vagrant ssh <Hostname of Edgeside VM>
````
Navigate into the synced folder and run the bootstrap script (with sudo) using the appropriate flag value:
````
$ sudo su
$ cd bootstrap/boostrap_edgeside
$ sh bootstrap_edgeside.sh \
--cloudside-ip=<IP of Cloudside VM> \
--ke-token=<The token optained on Cloudside VM in ketoken.txt>
````

NOTE: Make sure to use the IP of the Cloudside VM and NOT the IP of the respective Edge Node!
