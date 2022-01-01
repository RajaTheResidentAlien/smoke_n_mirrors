# smoke_n_mirrors

## Description: 
based on an audio-file/clip-launcher, this norns app will gather information from file titles, sequence through a folder of those files, thus enabling the user to establish a fancy/ever-changing click-track in order to synchronize other things on norns to(such as softcut, supercollider synths, etc.)

## Install: 
from within maiden, under the 'matron' tab, enter the following line:
> ;install https://github.com/RajaTheResidentAlien/smoke_n_mirrors

   additionally, you need to have audio files(clips/loops) within a subfolder of the 'audio' folder on your norns: 
      the subfolder should be called, "ll" (just 2 'l's - no quotes)
if you'd prefer, for starters, you can use these loops(just download, unzip, and drop straight into the 'dust/audio' folder of your norns) from my debut album: ["Earthlings Are Creepy(Pt.2)"](http://rajarez.net/eac/ll.zip)
(they're prepared in the exact way necessary for file titles to feed the app information about sequencing through those files, so they make a good starting example)


## Quick-start:
1) after install, select and run 'smoke_n_mirrors' from the norns menu(or in maiden, with 'smoke_n_mirrors.lua' selected, click the play icon to the upper-right)
2) first, 'enc2' allows you to select/hilite various parameter-elements of the UI, for which you use 'enc3' to alter..
    ..turn 'enc2' slightly clockwise so that the 'Loops:' parameter is highlighted on the screen of your norns, then hold down k2 for longer than 0.2 seconds.

The app will start to play files starting from the first in the folder(you can start from a different file by first using enc2 to highlight 'File:...', then use enc3 to scroll to the file-title of choice, and finally hold down k2 as described above to start from there).

###### holding down k2 for longer than 0.2 seconds toggles playback on/off
###### (tapping k2 on/off within 0.2 seconds toggles a 'beat-scramble' effect(rhythmically jumpcuts playback position at random times until start of next loop))

The 'FileDiv' parameter(short for 'file divisions') assigns how many quarter notes fall within the duration of that particular file. 

The 'Loops:' parameter assigns how many times to play that particular file before moving on to the next file in the folder.

The 'BPM' parameter, controls the master BPM of norns, but is separately controlled by enc1.

By mismatching 'BPM' and 'FileDiv' to your files, you can create many different rhythms from one single file(the app ducks amplitude in and out smoothly at the 'file division' points when bpms are mismatched, in order to keep pace... instead of pitch-shifting or time-stretch(altho this is the basics behind granular time-stretch, the window of time here is far too large to be considered granular, and we hear it more like a rhythmic compensation)). This is the essence behind the app, to be able to sequence through many of these looped files(like 'clips'), and create multiple rhythmic iterations from those basic files by tweaking 'BPM' and 'FileDiv', at the same time, synchronizing other processes to the master clock.

## Other-Features:
(still in progress, and many kinks to be worked out(feel free to suggest on the Lines thread, anything to start with about changes in parameter naming schemes, UI setup(nothing too complex, tho), and most of all: control-interface(especially how grids might control this))... but here's some furtherz until i clean this up completely 👇
#### 'FNL' parameter: 
this stands for 'File-Name Lock' which will tell the app to read 'BPM', 'FileDiv', and 'Loops' parameters from the title of each new file in the sequence(a simple way to script the sequence, using the titles of your files/clips)... 
    ...when this is turned 'on', the app will read the 'BPM' from the 5th, 6th, and 7th characters of the file-title...
    ...and it will find the 'FileDiv' and the 'Loops' parameters somewhere within the 9th thru 15th characters of your file-title, with the two separated by underscore(either of these can be up to 3 digits long, while BPM has to be exactly 3 digits, using '0's for smaller BPM number like '085' for 85BPM)...
    ...easier to understand more clearly when looking at an example:
    "038_101_16_4_Beat5j.wav" where the beginning '038' helps set the order the file will appear within the folder/sequence, '101' is the BPM, '16' is the 'FileDiv', and finally '4' is the number of loops, the remaining part of the file is like an extra comment/name to help you remember what it is, all fields separated by underscores.
    
#### 'FXV' parameter:
this stands for 'FX Vortex'; with this parameter 'on', the app will automatically scramble routings of the effect matrix built within the engine, sending the audio of the files into varying effects(resonator, stereo-echo, comb-filter, and reverb... in that order, with some in the chain cut out of the chain here and there on randomly chosen beats). this happens whenever the app jumpcuts the beat near the end of the cycle of 'Loops'(the app selects a random beat near the end of the cycle to begin scrambling playback positions at different times, until resetting to normal playback at the start of the next loop; to simulate a drum-fill leading into the beginning of the next cycle, but with a very glitchy style of cutup). while the fill happens the app will keep switching routing of effects as well, timed to the cuts of the beat, finally resting on a new fixed effect routing at the start of the new cycle. Turning 'FXV' 'off' will return the audio to fully dry(no effects; but the jumpcut/fills near end of each cycle of loops cannot be turned off - this drummer likes to showboat as much as possible 😆).

#### 'TRG' parameter:
this assigns a 'trigger resolution' for recording into a specified softcut voice. this is like a quantization level(instead of a countoff), allowing the user to quantize the start of recording to the next time playback reaches this quantization level of quarter-notes(so if the value is '4', it will only allow recording to start at the next multiple of 4 beats within that loop after recording is triggered).

#### 'RLN'(recording length) & 'LRC'(loop recording; not implemented yet) parameters: 
recording length sets the amount of quarter-notes recording will be in length for the chosen softcut voice(LRC not implemented yet).

**To trigger recording, hold k3(for longer than 0.2s), and recording will start at the next quantized point(specified by the 'TRG' parameter) into the softcut voice specified by the 'VOX' parameter.
Playback will start for that voice, directly after recording ends(but quantized to quarter note). A short tap on k3 will toggle playback on/off, thereafter, for the specified voice(if you switch 'VOX' parameter to a different number, the controls will all refer to that newly specified voice, and for playback control, it's always necessary to have recorded at least once into that specific voice; a good thing to keep in mind before switching voices while controlling playback).
**

Many other features to be added, also kinks to be worked out and a better grid interface to be created... but this much allows the user to use it like a sequenced audio-clip remixer, with synchronized softcut capabilities and some extra supercollider effects. 
But first priority: create better grid-interface, right now, hitting six buttons at top-right of the grid will start recording for that specific softcut voice, and the grid will show a clock-like interface rotating according to playback position. After recording ends, a matching button of the six buttons on the opposite side of the top-row of the grid will show playback, and toggling that same button on/off will toggle playback of that particular softcut voice. Furthermore, 4 buttons in the middle will perform various options like reverse-direction, scramble, etc. And finally, within the clock interface, pressing buttons will toggle on certain playback-scrambling options. I will need to create a video or .pdf to explain the rest. Hopefully this can get folks started :)
