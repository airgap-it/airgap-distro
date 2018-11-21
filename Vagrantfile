Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu1804"
  config.vm.provision "shell", path: "https://github.com/airgap-it/airgap-distro/blob/master/distro_build_script.sh"
end

