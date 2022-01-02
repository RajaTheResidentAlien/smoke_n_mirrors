-- SMOKE & MIRRORS
-- 
-- 
--  by raja(TheResidentAlien) 

engine.name = 'Smoke'; --engine
mirrorz = {}; for i=1,6 do mirrorz[i]=include 'lib/mirror' end --'mirror'= softcut-based looper module 
scr = include 'lib/scrn'; prm = include 'lib/prmz'              --screen and params stuff
selected_file='none'; homedir=_path.audio.."ll/"; x={}; numofils=0; whichfile=1 --file stuff
rrst=0; prst={0,0,0,0,0,0}; lnk=0; tix=0; prvbar=0; bar=1; rnd=0; rc=0; pl={0,0,0,0,0,0} --flags,etc.
U1shft=1; U2shft=1; fdr=0; phr=2; tr=4; rndr=0; c1=0; c2=0; c3=0; c4=0; c5=0; c6=0; c7=0; filbt=0
prrc=0; bf=0; nbf=1; duk=0; keytog=0; vx=1; fnl=0; fxv=0; fnt=14; id=0; alt=0; go=0; count=-0.5; k1=0
togmat={}; levmat={}; tmrmat={}; 
for i=1,16 do tmrmat[i] = {} levmat[i] = {}; for j=1,16 do tmrmat[i][j] = nil; levmat[i][j] = 0 end end
g=grid.connect(1)
function init()
  local tempo=params:get("clock_tempo")
  audio.level_adc(1,1); audio.level_cut(1)
  audio.level_monitor(0,1); audio.level_monitor(1,1)
  --audio.monitor_mono()
  norns.enc.sens(1,2); norns.enc.sens(2,11); norns.enc.sens(3,4) -- encoder-sensitvt
  for i=1,6 do                                                  --initialization of 6 softcut voices
    softcut.enable(i,1); softcut.buffer(i,((i+1)%2)+1); softcut.level(i,1); softcut.level_input_cut(1, i, 1)
    softcut.level_input_cut(0, i, 1); softcut.rec_level(i,1); softcut.pre_level(i,0)
    softcut.level_slew_time(i,0.04); softcut.fade_time(i,0.04); softcut.loop(i,0); softcut.play(i,0)
    softcut.pan(i,((((i+1)%2)*2)-1)*(math.random(5,10)*0.1)); mirrorz[i].set(tempo,16,i,(i-1)*55)
  end
  audio.level_eng_cut(0); audio.level_adc_cut(1)
  engine.rzr(55,0.12,0.2,0,2); engine.dst(tempo,1,1,3)
  engine.cmbr(tempo,0.8,2,4); engine.rvrb(3,0); engine.first(0)
  x=util.scandir(homedir); numofils=#x; engine.flow(homedir..x[whichfile]);
  engine.fleek(math.random(1,10),math.random(1,10),math.random(1,10),math.random(1,10)*0.1,math.random(1,10)*0.1,math.random(1,10),math.random(0,1),(60/tempo))
  alt=clock.run(drw)
end

function clock.transport.start() 
  x=util.scandir(homedir); numofils=#x; go=1; engine.floss(bf,go); id=clock.run(popz)
end

function clock.transport.stop() clock.cancel(id); go=0; engine.floss(bf,go); id=nil end

function g.key(x,y,z)
  if z==1 then 
    if y==1 then
      local v=params:get("vox")
      if x<7 then mirrorz[x].set(params:get("clock_tempo"),params:get("rln"),x,(x-1)*55); prrc=1; params:set("vox",x)
      elseif x==7 then if mirrorz[v].mode==0 then mirrorz[v].mode=1 else mirrorz[v].mode=0 end
      elseif x>7 and x<10 then if mirrorz[v].mode==x-6 then mirrorz[v].mode=1 else mirrorz[v].mode=x-6 end
      elseif x==10 then mirrorz[v].play(count, 1, 1, 1)
      elseif x>10 then pl[x-10]=1-pl[x-10]; if pl[x-10]>0 then prst[x-10]=1 end params:set("vox",x-10) end
    else
      tmrmat[x][y]=clock.run(longgr,x,y,params:get("vox"))
    end
  elseif z==0 then
    if tmrmat[x][y] then clock.cancel(tmrmat[x][y]); shrtgr(x,y,params:get("vox")) end
  end
end

function shrtgr(x,y,v)
  if not mirrorz[v].grd.togmat[x][y] then
    mirrorz[v].grd.togmat[x][y] = true; mirrorz[v].grd.levmat[x][y] = 8
  else mirrorz[v].grd.togmat[x][y] = false; mirrorz[v].grd.levmat[x][y] = 0 end
end

function longgr(x,y,v)
  clock.sleep(0.2)
  if not mirrorz[v].grd.togmat[x][y] then
    mirrorz[v].grd.togmat[x][y] = true; mirrorz[v].grd.levmat[x][y] = 6
  else mirrorz[v].grd.togmat[x][y] = false; mirrorz[v].grd.levmat[x][y] = 0 end
  tmrmat[x][y] = nil
end

function key(n,z)
  if U1shft==7 then
    if n == 3 and z==1 then audio.level_eng_cut(1); audio.level_adc_cut(0)
    elseif n == 2 and z==1 then audio.level_eng_cut(0); audio.level_adc_cut(1) end
  elseif U1shft==3 then
    if n == 3 and z==1 then whichfile = util.wrap((whichfile + 1),1,#x)
    elseif n==2 and z==1 then whichfile = util.wrap((whichfile - 1),1,#x) end
  elseif U1shft==1 then
    if n==3 and z==1 then end
  else
      if z==1 then k1=clock.run(longpr,n,z)
      else
        if k1 then clock.cancel(k1); shrtpr(n,z) end
      end
  end
end
  
function shrtpr(n,z)
  local v=params:get("vox")
  if n==3 then pl[v]=1-pl[v]; if pl[v]>0 then prst[v]=1 end --key3 shortpress plays softcut voice
  elseif n==2 then rnd = 1-rnd end       --key2 shortpress turns on/off beat-scramble
end

function longpr(n,z)
  clock.sleep(0.2)
  if n==3 then                    --key3 longpress turns on record into softcut voice
    if U2shft==1 then
    local voxy=params:get("vox")
    mirrorz[voxy].set(params:get("clock_tempo"),params:get("rln"),voxy,(voxy-1)*55); prrc=1
    elseif U2shft==2 then
    elseif U2shft==3 then
    else
    end
  elseif n==2 then            --key2 longpress scrolls thru voice numbers
    if U2shft==1 then
      if params:string("clock_source")=="internal" or params:string("clock_source")=="crow" then
        if go>0 then clock.transport.stop() else clock.transport.start() end end
    elseif U2shft==2 then count=0
    elseif U2shft==3 then params:delta("vox",util.wrap(params:get("vox")+1,1,6))
    else end
  else
    U2shft=util.wrap(U2shft+1,1,4); fnt=util.clamp((U2shft*3)+11,0,22)
  end
  k1=nil
end

function enc(n,d)
  if n==1 then 
    params:delta("clock_tempo",d) 
  elseif n==2 then U1shft = util.clamp(U1shft + d,1,9)
  elseif n==3 then 
    if U1shft == 1 then params:delta("file_div",d)
    elseif U1shft == 2 then params:delta("loops",d)
    elseif U1shft == 3 then whichfile=util.wrap((whichfile+d),1,#x)
    elseif U1shft == 4 then params:delta("fnl",d)
    elseif U1shft == 5 then params:delta("fxv",d)
    elseif U1shft == 6 then params:delta("trg",d)
    elseif U1shft == 7 then params:delta("vox",d)
    elseif U1shft == 8 then params:delta("rln",d)
    elseif U1shft == 9 then params:delta("lrc",d)
    end
  end
  draw_dirt=1 
end

function drw() while true do clock.sync(1/24); redraw() end end

function popz()
  while true do
    clock.sync(1/8)
    if (tix%4)==0 then                                                      --quarter note/count
      fdr = params:get("file_div"); phr = params:get("loops"); vx = params:get("vox")
      fxv = params:get("fxv"); fnl = params:get("fnl"); tr = params:get("trg"); tmp = params:get("clock_tempo")
      rndy=fdr*(1-(1/math.random(3,5))); rndr=math.random(0,fdr-1)
      if (bar>(phr*0.5) and count>rndy) and phr>1 then rnd=1 end
      count = util.wrap(count+0.5,0,fdr-1)  --'the main tether of my existence'(main/quarter-note counter)
      
      engine.fleek(math.random(1,10),math.random(10,20),math.random(11,40),math.random(5,500)*0.1,
        math.random(1,100)*0.1,math.random(1,100),math.random(0,1),(60/tmp))
      
      g:refresh()
      if fnl>0 or (tonumber(string.sub(x[whichfile],5,7))==tmp) then
        if count==0 then engine.awyea(bf,count,fdr) end
      else engine.awyea(bf,count,fdr) end
      if count==0 then 
          rnd=0; prvbar = bar; bar = util.wrap((bar + 1),1,phr); filbt=fdr-math.random(2,3)
        elseif count==filbt then
          if phr==1 or (bar==phr and prvbar<phr) then
            if duk==0 then
            whichfile = util.wrap((whichfile + 1),1,#x); engine.flex(nbf,homedir..x[whichfile]); duk=1 end end
      end
      if bar==1 then
            if fnl>0 then
              params:set("clock_tempo",tonumber(string.sub(x[whichfile],5,7)))   -- get bpm..
              params:set("file_div",tonumber(string.sub(x[whichfile],9,string.find(x[whichfile],"_",9,12)-1))) --..filediv..
              params:set("loops",                      -- ..and number of loops all from file name(if 'fnl')
                tonumber(string.sub(x[whichfile],
                string.find(x[whichfile],"_",9,12)+1,string.find(x[whichfile],"_",12,15)-1)))
            end
      end
      if rnd>0 then 
        if fxv>0 then
          local chs=math.random(0,3); keytog=1-keytog
          if chs==0 then
            if math.random(0,2)>0 then engine.cmbset(math.random(11,44),0.8) end; engine.fxrtcm(keytog)
          elseif chs==1 then
            if math.random(0,2)>0 then engine.dstset(math.random(1,6)*((tmp/60.)*0.03125),1) 
            else engine.dstset(0.01,0) end
            engine.fxrtds(keytog)
          elseif chs==2 then engine.rzset(math.random(20,72),0.8,0.2); engine.fxrtrz(keytog)
          elseif chs==3 then engine.fxrtrv(keytog) end
        end
        engine.awyea(bf,rndr,fdr) 
      end
      if(count%tr)==0 then if prrc>0 then rc=1; rrst=1; prrc=0 end end g:all(0)            --prerec
      if rc>0 then                                                               --'trap within mirror'(record)
        rc=mirrorz[vx].rec(count,rrst); if rc==0 then pl[vx]=1 end; if rrst>0 then rrst=0 end end
      for k=1,6 do
        mirrorz[k].play(count,prst[k],1,pl[k]); if prst[k]>0 then prst[k]=0 end       --'look thru mirror'(play)
        for x=1,16 do for y=1,16 do 
          if mirrorz[k].grd.togmat[x][y] then g:led(x,y,mirrorz[k].grd.levmat[x][y]) end 
        end end
        if k==vx then mirrorz[k].grd.fokus=k else mirrorz[k].grd.fokus=0 end
      end
    else
        if rnd==1 then 
          if (tix%2)==0 then
            if math.random(0,1)>0 then if duk<2 then engine.awyea(bf,0,fdr) end end
            for i=1,6 do softcut.pan(i,((((i+1)%2)*2)-1)*(math.random(50,100)*0.01)) end
          else 
            if math.random(0,1)>0 then rndr=count; if duk<2 then engine.awyea(bf,rndr,fdr) end end 
          end
        end
    end
    if duk==1 then engine.floss(bf,0); duk=duk+1
    elseif duk==2 then nbf=bf; bf=1-bf; duk=duk+1
    elseif duk==3 then engine.floss(bf,1); duk=0 end
    tix = tix + 1
  end
end

function cleanup() engine.darknez() end