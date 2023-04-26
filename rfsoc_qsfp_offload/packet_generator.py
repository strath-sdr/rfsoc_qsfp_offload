from pynq import DefaultIP

_fsm_lut = ['IDLE', 'COUNT', 'LAST']

class PacketGenerator(DefaultIP):
    
    def __init__(self, description):
        super().__init__(description=description)
        self._count = 16
        
    bindto = ['strathsdr.com:strathsdr:axis_packet_generator:1.0']
        
    @property
    def _enable(self):
        return self.read(0x00)
    
    @_enable.setter
    def _enable(self, value):
        self.write(0x00, value)
        
    @property
    def _count(self):
        return self.read(0x04)
    
    @_count.setter
    def _count(self, value):
        self.write(0x04, value)
        
    @property
    def _status(self):
        return self.read(0x08)
    
    @property
    def packetsize(self):
        return self._count
    
    @packetsize.setter
    def packetsize(self, value):
        if not isinstance(value, int):
            raise TypeError('Packetsize must be of type integer.')
        if (value < 2) or (value > 2**32-1):
            raise ValueError('Packetsize must be between 2 and 2^32-1')
        self._count = value
    
    def enable(self):
        self._enable = 1
        
    def disable(self):
        self._enable = 0
        
    def status(self):
        return _fsm_lut[self._status]
    