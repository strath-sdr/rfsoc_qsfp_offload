import time
import signal
import sys
import argparse
from rfsoc_qsfp_offload.overlay import Overlay

global exit_flag

def signal_handler(sig, frame):
    print('')
    print('Exiting RF capture')
    global exit_flag
    exit_flag = True
    
def main(args):
    f_c = args.freq
    
    f_c = args.freq
    print("Starting RF capture at %fMHz" % (f_c))

    board_ip = '192.168.4.99'
    client_ip = '192.168.4.1'

    print("Initializing RFSoC QSFP Offload Overlay")
    ol = Overlay(ignore_version=True)
    # Wait for overlay to initialize
    ol.cmac.mmio.write(0x107C, 0x3) # RSFEC_CONFIG_ENABLE
    ol.cmac.mmio.write(0x1000, 0x7) # RSFEC_CONFIG_INDICATION_CORRECTION
    time.sleep(5) # Magic sleep

    ol.cmac.start()
    res = ol.netlayer.set_ip_address(board_ip, debug=True)

    print("Network confguration complete IP: %s" % (res['inet addr']))

    ol.netlayer.sockets[0] = (client_ip, 60133, 60133, True)
    ol.netlayer.populate_socket_table()
    ol.source_select(1) # Select RF-ADC source for packets

    ADC_TILE = 2       # ADC Tile 226
    ADC_BLOCK = 0       # ADC Block 0
    ADC_SAMPLE_FREQUENCY = 1228.8  # MSps
    ADC_PLL_FREQUENCY    = 491.52   # MHz
    ADC_FC = -1*f_c # Tune to center frequency

    # Stop if running
    ol.packet_generator.disable()

    # Start ADC
    ol.initialise_adc(tile=ADC_TILE,
                    block=ADC_BLOCK,
                    pll_freq=ADC_PLL_FREQUENCY,
                    fs=ADC_SAMPLE_FREQUENCY,
                    fc=ADC_FC)

    # Decimate by (16x)
    ol.set_decimation(tile=ADC_TILE,block=ADC_BLOCK,sample_rate=64e6)

    # Set packet size
    ol.packet_generator.packetsize = 128 # 128 * 64 bytes = 8192 bytes to be sent
    ol.packet_generator.enable()

    print("Starting UDP stream")
    print("Ctrl-C to exit")
    while(not exit_flag):
        time.sleep(1)
        print(".", end='', flush=True)

    # Stop packet generator
    ol.packet_generator.disable()

if __name__ == "__main__":
    # CTRL-C handler
    global exit_flag 
    exit_flag = False
    signal.signal(signal.SIGINT, signal_handler)

    parser = argparse.ArgumentParser(
        description='Tune RFSoC and stream data over QSFP',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
        )
    parser.add_argument('-f', '--freq',type=float,help='Center frequency (MHz)',
                        default = '1000')
                        
    args = parser.parse_args()
    main(args)
