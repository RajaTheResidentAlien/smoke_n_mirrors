-- mirror (by raja) - a softcut-based looper(linked to grid viz)
local mirror = {}
mirror.countr = 0; mirror.countp = 0; mirror.vox_num = 1
mirror.loop_end = 1; mirror.length = 1; mirror.rec_len = 1
mirror.clink = 0; mirror.strt = 0; mirror.rec_noff = 0; mirror.mode = 1
mirror.grd = {}; mirror.grd.xpos = {0,1,2,3,4,5,6,7}; mirror.grd.ypos = {8,8,8,8,8,8,8,8}
mirror.grd.sx = {0,1,2,3,4,5,6,7}; mirror.grd.sy = {-1,-1,-1,-1,-1,-1,-1,-1}; mirror.grd.fokus = 0
mirror.grd.togmat={}; mirror.grd.levmat={};
for i=1,16 do mirror.grd.togmat[i] = {}; mirror.grd.levmat[i] = {}; 
  for j=1,16 do mirror.grd.togmat[i][j]=false; mirror.grd.levmat[i][j]=0; end end

function mirror.set(bpm, r_len, v_num, offst)
  mirror.vox_num = v_num; mirror.rec_len = r_len; mirror.length = (60/bpm)*r_len; mirror.strt = offst
  softcut.loop_start(mirror.vox_num,mirror.strt); softcut.loop_end(mirror.vox_num,mirror.length+mirror.strt)
end

function mirror.play(count, rst, loop_amt, noff)
    if rst>0 then mirror.clink=count; mirror.countp=0   --rst resets both play-position and starting-count
    elseif count==mirror.clink then                           --check for sync point..
      if mirror.mode>0 then mirror.countp=0 end                
    else
      if mirror.mode==1 then
        mirror.countp=util.wrap(mirror.countp+1,0,mirror.rec_len)     --..else keep counting internally
      elseif mirror.mode==2 then
        mirror.countp=util.wrap(mirror.countp-1,0,mirror.rec_len)     --..or reverse count
      elseif mirror.mode==3 then
        mirror.countp=util.wrap(math.random(1,mirror.rec_len),0,mirror.rec_len) end  --..or randomized count
    end
    if noff>0 then
      softcut.position(mirror.vox_num,
        util.wrap((mirror.countp*(mirror.length/mirror.rec_len))+mirror.strt,
        mirror.strt,(mirror.length*loop_amt)+mirror.strt))
    end
    softcut.level(mirror.vox_num,noff)
                                                                                              --play
    if noff==0 then mirror.grd.togmat[mirror.vox_num+10][1]=false; clock.run(mirror.waiit); 
      else mirror.grd.togmat[mirror.vox_num+10][1]=true; mirror.grd.rotate(mirror.countp) end
    softcut.play(mirror.vox_num,noff); mirror.grd.levmat[mirror.vox_num+10][1]=noff*15
end

function mirror.rec(count, rst)
    if rst>0 then                           --rst used to reset count and store starting-count
      mirror.countr=0; mirror.clink=count; softcut.position(mirror.vox_num,mirror.strt); mirror.rec_noff=1
    else mirror.countr=mirror.countr+1 end                  --during normal rec function, count up
    if mirror.countr>=mirror.rec_len then mirror.rec_noff=0 end        --end
    softcut.rec(mirror.vox_num,mirror.rec_noff);                --instruct softcut recording
    if mirror.rec_noff>0 then 
      mirror.grd.togmat[mirror.vox_num][1]=true; mirror.grd.rotate(mirror.countr)
      else mirror.grd.togmat[mirror.vox_num][1]=false end
    mirror.grd.levmat[mirror.vox_num][1]=mirror.rec_noff*15
    return mirror.rec_noff                              --return recording flag state
end

function mirror.waiit() clock.sync(1/64) end

-- --------------________________________________".grd..." section_______________________________---------------
function mirror.grd.rotate(count)
  local x1, y1, angler, fok
  angler = util.degs_to_rads(((count * 22.5) % 360)-180)
  if mirror.grd.fokus>0 then 
    fok = true; 
    if mirror.mode==0 then g:led(7,1,1); for i=2,4 do g:led(i+6,1,0) end 
    elseif mirror.mode==1 then for i=1,4 do g:led(i+6,1,0) end
    elseif mirror.mode==2 then g:led(7,1,0); g:led(8,1,1); for i=3,4 do g:led(i+6,1,0) end
    elseif mirror.mode==3 then g:led(9,1,1); for i=1,2 do g:led(i+6,1,0) end
    end
  end
  for i = 1,8 do 
    x1 = (mirror.grd.sx[i] * math.cos(angler)) - (mirror.grd.sy[i] * math.sin(angler))
    y1 = (mirror.grd.sx[i] * math.sin(angler)) + (mirror.grd.sy[i] * math.cos(angler))
    mirror.grd.xpos[i] = (x1 + 9)//1; mirror.grd.ypos[i] = (y1 + 9)//1
    g:led(mirror.grd.xpos[i],mirror.grd.ypos[i],fok and 15 or 11)
    if mirror.grd.fokus then
      if (mirror.grd.levmat[mirror.grd.xpos[i]][mirror.grd.ypos[i]]==8) then mirror.grd.stepwize(i,count) 
        elseif (mirror.grd.levmat[mirror.grd.xpos[i]][mirror.grd.ypos[i]]==6) then mirror.grd.ratewize(i,count) end end
  end
end

function mirror.grd.stepwize(which,count)
  if which==2 then --reverse
    softcut.rate(mirror.vox_num,-1)
    softcut.position(mirror.vox_num,
        util.wrap(((mirror.countp+1)*(mirror.length/mirror.rec_len))+mirror.strt,mirror.strt,mirror.length+mirror.strt));
  elseif which==3 then --random
    softcut.rate(mirror.vox_num,math.random(-1,1));
    softcut.position(mirror.vox_num,
        util.wrap(((mirror.countp+1+math.random(1,6))*(mirror.length/mirror.rec_len))+mirror.strt,
        mirror.strt,mirror.length+mirror.strt));
  elseif which==4 then --palindrom
    softcut.rate(mirror.vox_num,1); clock.run(mirror.grd.cutit,-1,0.25)
  elseif which==5 then --granulatedmixes..
    softcut.rate(mirror.vox_num,1); clock.run(mirror.grd.cutem,-1,0.125,4); clock.run(mirror.grd.cutem,1,0.125,4)
  elseif which==6 then
    softcut.rate(mirror.vox_num,1); clock.run(mirror.grd.cutem,-1,0.125,4); clock.run(mirror.grd.cutem,1,0.5,2)
  elseif which==7 then
    softcut.rate(mirror.vox_num,1); clock.run(mirror.grd.cutem,1,0.0625,8); clock.run(mirror.grd.cutem,-1,0.5,2)
  else
    softcut.rate(mirror.vox_num,1) end --regular/forward
end

function mirror.grd.ratewize(which,count)
  local wtf = math.random(1,4)
  if which<5 and which>1 then --reverse
    softcut.rate(mirror.vox_num,which*0.5)
  elseif which==5 then --granulatedmixes..
    clock.run(mirror.grd.cutem,wtf*-1,0.125,4); clock.run(mirror.grd.cutem,wtf*1,0.125,4)
  elseif which==6 then clock.run(mirror.grd.cutem,wtf*-1,0.125,4); clock.run(mirror.grd.cutem,wtf*1,0.25,4)
  elseif which==7 then clock.run(mirror.grd.cutem,wtf*1,0.0625,8); clock.run(mirror.grd.cutem,wtf*-1,0.25,3)
  else softcut.rate(mirror.vox_num,1) end --regular/forward
end

function mirror.grd.cutit(speed,synk)
  clock.sync(synk); softcut.rate(mirror.vox_num,speed)
  softcut.position(mirror.vox_num,
        util.wrap(((mirror.countp+1)*(mirror.length/mirror.rec_len))+mirror.strt,
        mirror.strt,mirror.length+mirror.strt)); return 0
end

function mirror.grd.cutem(speed,synk,reps)
  for i = 1,reps do
  clock.sync(synk); softcut.rate(mirror.vox_num,speed)
  softcut.position(mirror.vox_num,
        util.wrap(((mirror.countp+1)*(mirror.length/mirror.rec_len))+mirror.strt,
        mirror.strt,mirror.length+mirror.strt)); end
  return 0
end

return mirror