import numpy as np
from scipy import signal

def sawtooth(f=50e6, fs=2457.6e6, width=0.5, A=1, min_samples=24576):
    """Generate a sawtooth wave using a desired frequency, sample
    frequency, width, amplitude, and minimum samples.
    
    Returns a floating-point np.array object.
    """
    t = 1/f
    n = np.linspace(0, t, int(fs*t), 
                    endpoint=False, dtype=np.single)
    mult_factor = int(np.ceil(min_samples/n.size))
    n = np.tile(n, mult_factor)
    return A*signal.sawtooth(2 * np.pi * f * n, width=width)

def sine(f=10e6, fs=2457.6e6, phi=0.0, A=1, min_samples=24576):
    """Generate a sine wave using a desired frequency, sample
    frequency, phase offset, amplitude, and minimum samples.
    
    Returns a floating-point np.array object.
    """
    t = 1/f
    n = np.linspace(0, t, int(fs*t), 
                    endpoint=False, dtype=np.single)
    mult_factor = int(np.ceil(min_samples/n.size))
    n = np.tile(n, mult_factor)
    return A*np.sin(2 * np.pi * f * n + phi)

def convert_to_int16(array, bits=14):
    """Convert a normalised amplitude array to fixed point
    representation. Cast to np.int16 and align bits to the
    Most Significant Bit (MSB).
    
    Returns the fixed point representation as an np.int16.
    """
    maxrep = 2**(bits-1)
    bit_array = array*(maxrep)
    clip_array = bit_array.clip(-maxrep, maxrep-1)
    return clip_array.astype(np.int16)*(2**(16-bits))
