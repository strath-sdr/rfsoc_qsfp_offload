from pynq import DefaultIP

fsm_lut = ['IDLE', 'READ', 'ERROR', 'RESET']

class FifoController(DefaultIP):
    def __init__(self, description):
        super().__init__(description=description)
        self._reset = 0 # Deassert reset
        
    bindto = ["strathsdr.com:strathsdr:axis_fifo_uflow_ctrl:1.0"]
        
    @property
    def _reset(self):
        return self.read(0x00)
    
    @_reset.setter
    def _reset(self, value):
        self.write(0x00, value)
        
    @property
    def _irq_enable(self):
        return self.read(0x04)
    
    @_irq_enable.setter
    def _irq_enable(self, value):
        self.write(0x04, value)
        
    @property
    def _status(self):
        return self.read(0x08)
        
    def reset_error(self):
        if self.status() == 'ERROR':
            self._reset = 1
        else:
            self._reset = 0
        
    def enable_irq(self):
        self._irq_enable = 1
        
    def disable_irq(self):
        self._irq_disable = 0
        
    def status(self):
        reg = self._status
        return fsm_lut[reg]
