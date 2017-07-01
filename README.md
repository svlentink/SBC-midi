# SBC-midi
Connect your MIDI keyboard to your Single Board Computer for some sound.

## Description

This script will allow your unix machine (e.g. Single Board Computer)
to output a piano sound when you play your MIDI keyboard.
It is written for my 'M-Audio USB MIDI Keyboard' and a CHIP (getchip.com).
You should be able to use it with other USB MIDI instruments and computers.
Before we begin, make sure you have your midi keyboard and speakers/headphones plugged in.

## Installation

Open a tty/ssh session on your device,
for a serial console, you may try:
(which will connect to the last connected USB device, did you just plug it in 5sec ago?)
```shell
screen $(ls -tr /dev/tty*|grep -i usb|tail -1) 115200
```

If your device has WIFI, and you want to connect to it:
```shell
nmcli dev wifi list
nmcli dev wifi connect YOUR_WIFI password WIFI_PASSWORD
```

Now that we have internet connection,
a MIDI input device connected and headphones/speakers,
just run:
```shell
curl -sSL https://raw.githubusercontent.com/svlentink/SBC-midi/master/install.sh | sudo sh
```

### Links

The following can be used for debugging or further development:
+ Introduction: https://rafalcieslak.wordpress.com/2012/08/29/usb-midi-controllers-and-making-music-with-ubuntu/
+ Technical: http://tedfelix.com/linux/linux-midi.html
+ Quickstart: http://sandsoftwaresound.net/qsynth-fluidsynth-raspberry-pi/

Other links:
+ https://www.hackster.io/11802/c-h-i-p-midi-arpeggiating-synth-e311ab
+ https://docs.getchip.com/chip.html#headless-chip
+ https://docs.getchip.com/chip.html#control-chip-using-a-serial-terminal
+ https://supercollider.github.io/
+ http://sonic-pi.net/
+ karplus strong algorithm
+ overtone.github.io
+ JaMISS
+ http://www.florisdriessen.nl/electronics/raspberry-pi-electronics/keyboard-piano-on-the-raspberry-pi-with-fluidsynth/
+ https://www.raspberrypi.org/blog/pi-synthesisers/
+ https://stimresp.wordpress.com/2016/02/08/using-a-raspberry-pi-as-usb-midi-host/
+ https://rafalcieslak.wordpress.com/2012/08/29/usb-midi-controllers-and-making-music-with-ubuntu/

### Current progress

This script installs a cronjob that runs every minute,
to verify all conditions.

It should establish the following after about 2.5 minutes after booting
(after the installation):

```shell
root@chip:/home/chip# aconnect -l | tail -6
client 20: 'USB Keystation 49e' [type=kernel]
    0 'USB Keystation 49e MIDI 1'
        Connecting To: 128:0
client 128: 'FLUID Synth (667)' [type=user]
    0 'Synth input port (667:0)'
        Connected From: 20:0
```
