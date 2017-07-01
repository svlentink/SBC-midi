#!/bin/bash
set -e

[[ ! -f /etc/debian_version ]] \
  && echo Sorry this script is aiming at debian based OSes \
  && exit 1
[[ $USER != "root" ]] \
  && echo Please run as root \
  && exit 1

function wrappedInFunction {

if [[ -z "$(which fluidsynth)" ]]; then
echo installing all prereq.
apt update
apt install -y \
  alsa-utils \
  espeak \
  fluidsynth \
  fluid-soundfont-gm
apt install -y linux-lowlatency || true #some arm compiled debian based distros may not have this
apt remove -y pulseaudio || true
else
echo allready installed prereq.
fi

echo We are going to play a sound, to test your speakers or headphone
speaker-test -t wav -c 2 -l 2

SCRIPTNAME=enableMidiMusic
VOLUMELOC=/keyboard-volume
SCRIPTPATH=/usr/bin/$SCRIPTNAME
echo Creating script $SCRIPTNAME

cat <<EOF> $SCRIPTPATH
#!/bin/bash
function communicateErr {
  echo \$@
  espeak --stdout \$@ | aplay || true
}

INPUTkeyword="usb"
MidiIN=\$(aconnect -i | grep -i "\$INPUTkeyword" | head -1 | awk '{print \$2;}')"0" # something like '20:'"0" = 20:0
[[ -z "\$MidiIN" ]] \
  && communicateErr "Input missing, trying again in a minute. Please connect keyboard." \
  && exit 1

if [[ -z "\$(ps aux|grep -i fluid|grep -v grep)" ]]; then
  communicateErr "the audio processor was down, starting it"
  nohup fluidsynth \
    --audio-driver=alsa \
    -o audio.alsa.device=hw:0 \
    --gain=\$(cat $VOLUMELOC) \
    --server \
    --no-shell \
    /usr/share/sounds/sf2/FluidR3_GM.sf2 \
    > /dev/null 2>&1 || true &
  exit 1
fi

OUTPUTkeyword="FLUID" #"Midi Through"
MidiOUT=\$(aplaymidi -l | grep -i "\$OUTPUTkeyword" | head -1 | awk '{print \$1;}') # something like '14:0'
if [[ -z "\$MidiOUT" ]]; then
  communicateErr "Output missing, trying again in a minute"

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
  
  exit 1
else
  echo We will use \$MidiIN as input and \$MidiOUT as output
  aconnect \$MidiIN \$MidiOUT
fi

exit 0
EOF
chmod +x $SCRIPTPATH
echo "* * * * * root $SCRIPTPATH" > /etc/cron.d/keyboardcron

echo You can change the volume at $VOLUMELOC which requires a reboot
echo -n "1.5" > $VOLUMELOC

}
wrappedInFunction # enables curl | sh
exit 0
