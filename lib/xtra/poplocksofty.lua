fileselect = require('fileselect')
selected_file = 'none'
x = {}
numofils = 0
whichfile = 1
fdiv = 16
bdiv = 2
qn = 0.
prevcount = 0
count = 0
prevbar = 0
bar = 0
isPlaying = 0

function set_tempo(tmp) params:set("clock_tempo",tmp) end
--
params:add{type="number", id="Tempo", min = 1, max = 300, default = 88, action = function(x) set_tempo(x) end}

function init()
  for i=1,6 do
    softcut.enable(i,1)
    softcut.buffer(i,((i+1)%2)+1)
    softcut.level_slew_time(i,0.008)
    softcut.level(i,1)
    softcut.loop(i,0)
    softcut.play(i,1)
    softcut.pan(i,(((i+1)%2)*2)-1)
  end
  x = util.scandir("/home/we/dust/audio/ll/")
  numofils = #x
  set_tempo(88)
  clock.run(screen_clock)
  clock.run(popz,fdiv);
end

function key(n,z)
  if n == 3 and z == 1 then fileselect.enter(_path.audio.."ll/",callback) end
end
function enc(n,d)
  if n==1 then 
    params:delta("Tempo",d*0.25) 
    draw_dirt=1 
  end
end
      
function popz()
  while true do
    prevcount = count
    count = (count + 1) % fdiv
    softcut.loop_start(1,count * qn - 1)
    softcut.loop_start(2,count * qn - 1)
    softcut.loop_end(1,(count * qn) + qn + 1)
    softcut.loop_end(2,(count * qn) + qn + 1)
    softcut.position(1,count * qn)
    softcut.position(2,count * qn)
    if count==0 then 
      softcut.level_slew_time(1,0.008)
      softcut.level_slew_time(2,0.008)
      if prevcount>0 then 
        prevbar = bar
        bar = (bar + 1) % bdiv 
      end 
    elseif count==(fdiv-1) then
      softcut.level_slew_time(1,0.0)
      softcut.level_slew_time(2,0.0)
    end
    if bar==0 then 
      if prevbar>0 then 
        prevbar = bar
        whichfile = (whichfile % #x) + 1
        qn = (60/string.sub(x[whichfile], 1, 3))
        softcut.buffer_read_stereo("/home/we/dust/audio/ll/"..x[whichfile], 0, 0, -1, 0, 1)
      end
    end
    draw_dirt = 1
    clock.sync(1)
  end
end

function screen_clock()
  while true do
    clock.sleep(0.25)
    if draw_dirt then
      redraw()
      draw_dirt = false
    end
  end
end

function redraw()
  screen.clear()
  screen.aa(1)
  screen.level(15)
  screen.font_size(8)
  screen.font_face(5)
  screen.move(0, 8)
  screen.text(params:get("clock_tempo")) 
  screen.move(19,8)
  screen.text(" BPM")
  screen.move(0,20)
  screen.text('file:')
  screen.move(0,28)
  screen.text(x[whichfile])
  screen.move(0,35)
  screen.font_size(5)
  screen.text('(K3 to choose file)')
  screen.move(40,8)
  screen.font_size(7)
  screen.text(" FileDiv")
  screen.move(65, 8)
  screen.font_size(8)
  screen.text(fdiv)
  screen.move(85, 8)
  screen.font_size(5)
  screen.text("Counts")
  screen.move(105, 15)
  screen.font_size(10)
  screen.text(bar+1)
  screen.move(114, 15)
  screen.font_size(10)
  screen.text(count)
  screen.update()
end

function callback(file_path)
  if file_path ~= 'cancel' then
    local split_at = string.match(file_path, "^.*()/")
    selected_file = string.sub(file_path, split_at + 1)
    for k = 1,#x do
      if selected_file == x[k] then whichfile = k print(whichfile) end
    end
    if isPlaying==0 then
      softcut.buffer_read_stereo("/home/we/dust/audio/ll/"..x[whichfile], 0, 0, -1, 0, 1)
      softcut.position(1,0)
      softcut.position(2,0)
      softcut.loop_start(1,0)
      softcut.loop_start(2,0)
      qn = (60/string.sub(selected_file, 1, 3))
      softcut.loop_end(1,qn*fdiv)
      softcut.loop_end(2,qn*fdiv)
    end
    
  end
  redraw()
end