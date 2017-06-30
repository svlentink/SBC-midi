#!/bin/bash
set -e

[[ ! -f /etc/debian_version ]] \
  && echo Sorry this script is aiming at debian based OSes \
  && exit 1
[[ $USER != "root" ]] \
  && echo Please run as root \
  && exit 1

function wrappedInFunction {

echo installing all prereq.
apt update
apt install -y \
  alsa-utils \
  fluidsynth \
  fluid-soundfont-gm
apt install -y linux-lowlatency || true #some arm compiled debian based distros may not have this
apt remove -y pulseaudio || true

echo We are going to play a sound, to test your speakers or headphone
speaker-test -t wav -c 2 -l 2

SCRIPTNAME=enableMidiMusic
VOLUMELOC=/keyboard-volume
SCRIPTPATH=/usr/bin/$SCRIPTNAME
echo Creating script $SCRIPTNAME

cat <<EOF> $SCRIPTPATH
#!/bin/bash
echo Starting the sound processing engine
nohup fluidsynth \
  --audio-driver=alsa \
  --audio-driver=alsa -o audio.alsa.device hw:0 \
  --gain=\$(cat $VOLUMELOC) \
  --server \
  --no-shell \
  /usr/share/sounds/sf2/FluidR3_GM.sf2 \
  > /dev/null 2>&1 &
sleep 10
echo The midi processing engine should be up by now

#echo Listing all audio devices:
#cat /proc/asound/cards
#aplay -l
#echo Listing midi:
#amidi -l
echo Listing the midi output devices:
aplaymidi -l
echo Listing input connections:
aconnect -i
echo Listing output connections:
aconnect -o

INPUTkeyword="usb"
OUTPUTkeyword="FLUID" #"Midi Through"
MidiIN=\$(aconnect -i | grep -i "\$INPUTkeyword" | head -1 | awk '{print \$2;}')"0" # something like '20:'"0" = 20:0
MidiOUT=\$(aplaymidi -l | grep -i "\$OUTPUTkeyword" | head -1 | awk '{print \$1;}') # something like '14:0'
echo We will use $MidiIN as input and $MidiOUT as output
aconnect $MidiIN $MidiOUT
exit 0
EOF
chmod +x $SCRIPTPATH
[[ -z "$(grep -i enableMidi /etc/rc.local)" ]] \
 && sed -i 's/exit/\/usr\/bin\/enableMidiMusic\nexit/g' /etc/rc.local #running it at startup

echo You can change the volume at $VOLUMELOC which requires a reboot
echo -n "3.7" > $VOLUMELOC

}
wrappedInFunction # enables curl | sh
exit 0