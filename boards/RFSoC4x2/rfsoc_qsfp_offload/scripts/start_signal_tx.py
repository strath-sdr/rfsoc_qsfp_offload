import time
import signal
import numpy as np
import sys
import argparse
from rfsoc_qsfp_offload.overlay import Overlay

global exit_flag

def signal_handler(sig, frame):
    print('')
    print('Exiting RFSoC Signal Transmit')
    global exit_flag
    exit_flag = True
    
def main(args):
    f_c = args.freq
    
    f_c = args.freq
    print("Starting RFSoC Signal Transmit at %fMHz" % (f_c))

    board_ip = '192.168.4.99'
    client_ip = '192.168.4.1'

    print("Initializing RFSoC QSFP Offload Overlay")
    ol = Overlay(ignore_version=True)
    # Wait for overlay to initialize
    time.sleep(5) # Magic sleep

    DAC_TILE = 0       # DAC Tile 228
    DAC_BLOCK = 0       # DAC Block 0
    DAC_SAMPLE_FREQUENCY = 1024  # MSps
    DAC_PLL_FREQUENCY = 491.52   # MHz
    DAC_INTERP = 16 

    ol.initialise_dac(tile=DAC_TILE,
                    block=DAC_BLOCK,
                    pll_freq=DAC_PLL_FREQUENCY,
                    fs=DAC_SAMPLE_FREQUENCY
                    )

    ol.rfdc.dac_tiles[DAC_TILE].blocks[DAC_BLOCK].InterpolationFactor = DAC_INTERP

    
    # Load signal
    tx_file = open(args.signal_file, mode='rb')
    tx_buffer = np.fromfile(tx_file)

    # Transmit
    print("Starting signal transmission")
    print("Ctrl-C to exit")
    ol.axi_dma_dac.sendchannel.transfer(tx_buffer, cyclic=True)

    while(not exit_flag):
        time.sleep(1)
        print(".", end='', flush=True)

    # Stop DMA transfer and reinitialize DAC to stop transmit
    ol.axi_dma_dac.sendchannel.stop()
    ol.initialise_dac(tile=DAC_TILE,
                    block=DAC_BLOCK,
                    pll_freq=DAC_PLL_FREQUENCY,
                    fs=DAC_SAMPLE_FREQUENCY
                    )

if __name__ == "__main__":
    # CTRL-C handler
    global exit_flag 
    exit_flag = False
    signal.signal(signal.SIGINT, signal_handler)

    parser = argparse.ArgumentParser(
        description='Transmit reference signal from RFSoC',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
        )
    parser.add_argument('-f', '--freq',type=float,help='Center frequency (MHz)',
                        default = '1000')
    parser.add_argument('-s', '--signal_file',type=str,help='Path to signal file',
                        default = './tx_signal.bin')
                        
    args = parser.parse_args()
    main(args)
