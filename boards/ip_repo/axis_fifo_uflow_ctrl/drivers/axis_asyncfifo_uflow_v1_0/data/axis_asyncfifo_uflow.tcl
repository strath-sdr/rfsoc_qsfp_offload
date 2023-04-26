

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "axis_asyncfifo_uflow" "NUM_INSTANCES" "DEVICE_ID"  "C_S_AXI_Lite_BASEADDR" "C_S_AXI_Lite_HIGHADDR"
}
