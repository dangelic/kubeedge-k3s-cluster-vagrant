# -*- mode: ruby -*-
# vi: set ft=ruby :

require "json"
ENV["VAGRANT_NO_PARALLEL"] = "yes"

# --- Define the machines: 
    # 1 MQTT Server (Middleware)
    # 1 Rancher Server
    # 1 Master-Node -> Cloudside running Cloudcore
    # n Worker-Node(s) -> Edgeside running Edgecore
mqtt_server_vm_config = JSON.parse(File.read("./vm_cluster_outline/mqtt_server_vm_config.json"))
rancher_vm_config= JSON.parse(File.read("./vm_cluster_outline/rancher_vm_config.json"))
cloudside_vm_config = JSON.parse(File.read("./vm_cluster_outline/cloudside_vm_config.json"))
edgeside_vm_config = JSON.parse(File.read("./vm_cluster_outline/edgeside_vm_config.json"))


Vagrant.configure(VAGRANTFILE_API_VERSION = "2") do |config|

    # --- Basic Vagrant options
	config.vm.box_check_update = false
	config.env.enable # Enable vagrant-env(./.env)

    # --- ENVs to be set in .env (required). Rename .env-sample to .env to get the default config
    VM_BOX_OS_MQTT_SERVER	= ENV["VM_BOX_OS_MQTT_SERVER"]
    VM_BOX_OS_RANCHERSERVER = ENV["VM_BOX_OS_RANCHERSERVER"]
    VM_BOX_OS_CLOUDNODE		= ENV["VM_BOX_OS_CLOUDNODE"]
    VM_BOX_OS_EDGENODE		= ENV["VM_BOX_OS_EDGENODE"]
    VM_ALIAS_SUFFIX			= ENV["NAMING_SUFFIX"]
    RANCHER_ENABLED			= ENV["RANCHER_VERSION"]
    RANCHER_VERSION			= ENV["RANCHER_VERSION"]
    DOMAIN					= ENV["DOMAIN"]

    # --- Check if each plugin is installed and reinstall automatically if necessary
    required_plugins = ["provision", "vagrant-hosts","vagrant-env"]
      required_plugins.each do |plugin|
        unless Vagrant.has_plugin?(plugin)
          # Plugin is not installed, reinstall it...
          puts "Installing #{plugin} plugin..."
          system "vagrant plugin install #{plugin}"
        else
          puts "#{plugin} plugin is already installed."
        end
    end

    # --- Provisions 1 MQTT Server.
    if mqtt_server_vm_config[0]["vname"]
        config.vm.define "#{mqtt_server_vm_config[0]["vname"]}" do |node|
            node.vm.box = VM_BOX_OS_MQTT_SERVER
            node.vm.hostname = "#{mqtt_server_vm_config[0]["hostname"]}.#{DOMAIN}"
            node.vm.network :private_network, ip: mqtt_server_vm_config[0]["ip"]
            node.vm.network :forwarded_port, guest: 80, host: 11000
            node.vm.network :forwarded_port, guest: 8080, host: 11001

            # Setup dir sync for MQTT Server.
            node.vm.provision "file", source: "bootstrap_mqtt_server", destination: "$HOME/bootstrap_mqtt_server" # Setup
            node.vm.provision "file", source: "tmp", destination: "$HOME/tmp" # Secrets
            node.vm.provision "file", source: "sh/sh_mqtt_server", destination: "$HOME/sh/sh_mqtt_server" # Scripts to apply additional resources
            node.vm.provision "file", source: "mqtt", destination: "mqtt" # Scripts to apply additional resources

            node.vm.provider "virtualbox" do |v|
                v.name = "#{mqtt_server_vm_config[0]["hostname"]}#{VM_ALIAS_SUFFIX}"
                v.memory = mqtt_server_vm_config[0]["mem"]
                v.cpus = mqtt_server_vm_config[0]["cpu"]
            end

            node.vm.provision "hosts" do |hosts|
                hosts.autoconfigure = true
                hosts.sync_hosts = true
                hosts.add_localhost_hostnames = false
            end
        end
    end

	# --- Provisions 1 Rancher Server.
    if rancher_vm_config[0]["vname"]
        config.vm.define "#{rancher_vm_config[0]["vname"]}" do |node|
            node.vm.box = VM_BOX_OS_RANCHERSERVER
            node.vm.hostname = "#{rancher_vm_config[0]["hostname"]}.#{DOMAIN}"
            node.vm.network :private_network, ip: rancher_vm_config[0]["ip"]
            node.vm.network :forwarded_port, guest: 80, host: 11010
            node.vm.network :forwarded_port, guest: 8080, host: 11011
            node.vm.network :forwarded_port, guest: 1886, host: 11012 # InfluxDB

            # Setup dir sync for Rancher Server.
            node.vm.provision "file", source: "bootstrap_rancher", destination: "$HOME/bootstrap_rancher" # Setup
            node.vm.provision "file", source: "tmp", destination: "$HOME/tmp" # Secrets
            node.vm.provision "file", source: "sh/sh_rancher", destination: "$HOME/sh/sh_rancher" # Scripts to apply additional resources
            node.vm.provision "file", source: "mqtt", destination: "mqtt" # Scripts to apply additional resources

            node.vm.provider "virtualbox" do |v|
                v.name = "#{rancher_vm_config[0]["hostname"]}#{VM_ALIAS_SUFFIX}"
                v.memory = rancher_vm_config[0]["mem"]
                v.cpus = rancher_vm_config[0]["cpu"]
                v.gui = true
            end

            node.vm.provision "hosts" do |hosts|
                hosts.autoconfigure = true
                hosts.sync_hosts = true
                hosts.add_localhost_hostnames = false
            end
        end
    end

	# --- Provisions 1 Master-Node -> Cloudside running Cloudcore.
    config.vm.define "#{cloudside_vm_config[0]["vname"]}" do |node|
        node.vm.box = VM_BOX_OS_CLOUDNODE
        node.vm.hostname = "#{cloudside_vm_config[0]["hostname"]}.#{DOMAIN}"
        node.vm.network :private_network, ip: cloudside_vm_config[0]["ip"]
        node.vm.network :forwarded_port, guest: 80, host: 11020
        node.vm.network :forwarded_port, guest: 8080, host: 11021
        node.vm.network :forwarded_port, guest: 1880, host: 11022 # Node-RED
        node.vm.network :forwarded_port, guest: 3000, host: 11023 # Grafana
        node.vm.network :forwarded_port, guest: 1886, host: 11024 # InfluxDB

        # Setup dir sync for Cloudside.
        node.vm.provision "file", source: "bootstrap_cloudside", destination: "$HOME/bootstrap_cloudside" # Setup
        node.vm.provision "file", source: "tmp", destination: "$HOME/tmp" # Secrets
        node.vm.provision "file", source: "manifests", destination: "$HOME/manifests" # Setup
        node.vm.provision "file", source: "sh/sh_cloudside", destination: "$HOME/sh/sh_cloudside" # Scripts to apply additional resources 
        node.vm.provision "file", source: "gitops", destination: "$HOME/gitops" # GitOps with ArgoCD
        node.vm.provision "file", source: "edgemesh", destination: "$HOME/edgemesh" # EdgeMesh

        node.vm.provider "virtualbox" do |v|
            v.linked_clone = true # Reduce provision overhead
            v.name = "#{cloudside_vm_config[0]["hostname"]}#{VM_ALIAS_SUFFIX}"
            v.memory = cloudside_vm_config[0]["mem"]
            v.cpus = cloudside_vm_config[0]["cpu"]
        end

        node.vm.provision "hosts" do |hosts|
            hosts.autoconfigure = true
            hosts.sync_hosts = true
            hosts.add_localhost_hostnames = false
        end
        config.vm.provision "shell", path: "ssh.sh"
    end
	
	# --- Provisions n Worker-Nodes -> Edgeside running Edgecore
	(1..edgeside_vm_config.size).each do |edgenode|
		config.vm.define "#{edgeside_vm_config[edgenode-1]["vname"]}" do |node|
			node.vm.box = VM_BOX_OS_EDGENODE
			node.vm.hostname = "#{edgeside_vm_config[edgenode-1]["hostname"]}.#{DOMAIN}"
			node.vm.network :private_network, ip: edgeside_vm_config[edgenode-1]["ip"]
            node.vm.network :forwarded_port, guest: 80, host: 11030+edgenode-1
			node.vm.network :forwarded_port, guest: 8080, host: 11040+edgenode-1
            node.vm.network :forwarded_port, guest: 1880 , host: 11050+edgenode-1 # Node-RED
            node.vm.network :forwarded_port, guest: 3000 , host: 11060+edgenode-1 # Grafana
            node.vm.network :forwarded_port, guest: 1886 , host: 11070+edgenode-1 # InfluxDB

            # Setup dir sync for Edgeside.
            node.vm.provision "file", source: "bootstrap_edgeside", destination: "$HOME/bootstrap_edgeside" # Cluster bootstrap
            node.vm.provision "file", source: "tmp", destination: "$HOME/tmp" # Secrets
            node.vm.provision "file", source: "sh/sh_edgeside", destination: "$HOME/sh/sh_edgeside" # Scripts to apply additional resources
            node.vm.provision "file", source: "edgemesh", destination: "$HOME/edgemesh" # EdgeMesh

			node.vm.provider "virtualbox" do |v|
				v.linked_clone = true # Reduce provision overhead
				v.name = "#{edgeside_vm_config[edgenode-1]["hostname"]}#{VM_ALIAS_SUFFIX}"
				v.memory = edgeside_vm_config[edgenode-1]["mem"]
				v.cpus = edgeside_vm_config[edgenode-1]["cpu"]
			end

			node.vm.provision "hosts" do |hosts|
				hosts.autoconfigure = true
				hosts.sync_hosts = true
				hosts.add_localhost_hostnames = false
			end
            config.vm.provision "shell", path: "ssh.sh"
		end
	end
end