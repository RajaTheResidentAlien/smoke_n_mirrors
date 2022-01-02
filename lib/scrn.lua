function redraw()
  screen.clear()
  screen.aa(1)
  screen.level(8)
  screen.font_size(6)
  screen.font_face(fnt)
  screen.move(0, 5)
  screen.text(" BPM:")
  screen.move(0,12)
  screen.font_size(8)
  screen.text(params:get("clock_tempo")) 
  if U1shft==2 then screen.level(15) else screen.level(8) end
  screen.move(44,16)
  screen.font_size(7)
  screen.text("Loops: "..params:get("loops"))
  if U1shft==3 then screen.level(15) else screen.level(8) end
  screen.font_size(7)
  screen.move(0,22)
  screen.text('File:')
  screen.font_size(8)
  screen.move(0,29)
  screen.text(x[whichfile])
  screen.move(38,8)
  screen.font_size(7)
  if U1shft==1 then screen.level(15) else screen.level(8) end
  screen.text("FileDiv: "..params:get("file_div"))
  screen.move(88, 8)
  screen.font_size(6)
  screen.level(8)
  screen.text("Loop:Beat")
  screen.move(95, 17)
  screen.font_size(10)
  screen.text(bar..":"..(count+1))
  screen.font_size(6)
  screen.move(0, 40)
  if U1shft==4 then screen.level(15) else screen.level(8) end
    local fln = 0
    if params:get("fnl")>0 then fln="on" else fln="off" end
  screen.text("FNL: "..fln) --"file name lock"
  screen.move(0, 47)
  if U1shft==5 then screen.level(15) else screen.level(8) end
    local fvx = 0
    if params:get("fxv")>0 then fvx="on" else fvx="off" end
  screen.text("FXV: "..fvx) --"fx vortex"
  screen.move(32, 40)
  if U1shft==6 then screen.level(15) else screen.level(8) end
  screen.text("TRG: "..params:get("trg")) --"trigger" resolution(recording)
  screen.move(32, 47)
  if U1shft==7 then screen.level(15) else screen.level(8) end
  screen.text("VOX: "..params:get("vox")) --"voice" number(softcut...to record into)
  screen.move(64, 40)
  if U1shft==8 then screen.level(15) else screen.level(8) end
  screen.text("RLN: "..params:get("rln")) --"recording length"(in 'counts'(quarter-notes))
  screen.move(64, 47)
  if U1shft==9 then screen.level(15) else screen.level(8) end
    local lcr = 0
    if params:get("lrc")>0 then lcr="on" else lcr="off" end
  screen.text("LRC: "..lcr) --"loop recording"
  screen.move(11,54)
  screen.arc(11,58,4,math.pi*1.5,((math.pi*2)*(count/params:get("rln")))-(math.pi*0.5))
  screen.stroke()
  screen.update()
end