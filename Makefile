VIVADO_VERSION := 2021.1

all: vivado_prj

vivado_check:
	vivado -version | fgrep ${VIVADO_VERSION}

patch:
	cp ./patches/NetLayers.patch ./boards/ip_repo/xup_vitis_network_example
	cp ./patches/100G-fpga-network-stack-core.patch ./boards/ip_repo/xup_vitis_network_example/NetLayers/100G-fpga-network-stack-core
	cd ./boards/ip_repo/xup_vitis_network_example && git apply NetLayers.patch
	cd ./boards/ip_repo/xup_vitis_network_example/NetLayers/100G-fpga-network-stack-core && git apply 100G-fpga-network-stack-core.patch

build_ip: vivado_check
	$(MAKE) all -C ./boards/ip_repo/xup_vitis_network_example/NetLayers

vivado_prj: vivado_check build_ip
	$(MAKE) all -C ./boards/RFSoC4x2/rfsoc_offload/

clean:
	$(MAKE) clean -C ./boards/ip_repo/xup_vitis_network_example/NetLayers
	$(MAKE) clean -C ./boards/RFSoC4x2/rfsoc_qsfp_offload/
