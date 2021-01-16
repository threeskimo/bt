# bt.sh

A bash script to simplify connecting/disconnecting bluetooth devices, scanning for bluetooth devices, seeing what bluetooth devices are paired, and seeing available non-paired devices to connect to.

## Why?

Because I was tired of using bluetoothctl, hcitool, etc. and needed a simple script to take care of connecting my bluetooth headphones/speaker to my laptop when they start getting finicky.

## Usage

```
bt [-c <device name>] [-d <device name>] [-l] [-i] [-s <seconds>]
	-c  Connect to the specific bt device
	-d  Disconnect from the specific bt device
	-l  List all available bt devices
	-i  Display all paired bt devices
	-s  Scan for new bt devices
```

