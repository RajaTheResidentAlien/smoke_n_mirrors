-- mirror (by raja) - a softcut-based looper
local mirror = {}; mirror.sq = include('lib/stolensequins')
mirror.countr = 0; mirror.countrend = 0; mirror.countp = 0; mirror.vox_num = 1
mirror.loop_end = 1; mirror.length = 1; mirror.rec_len = 1; mirror.rec_track = 0
mirror.clink = 0; mirror.strt = 0; mirror.rec_noff = 0; mirror.mode = 1

function mirror.set(bpm, r_len, v_num, offst)
  mirror.vox_num = v_num; mirror.rec_len = r_len; mirror.length = (60/bpm)*r_len; mirror.strt = offst
  softcut.loop_start(mirror.vox_num,mirror.strt); softcut.loop_end(mirror.vox_num,mirror.length+mirror.strt)
end

function mirror.play(count, rst, loop_amt, noff)
    if rst>0 then mirror.countp=rst   --rst resets both play-position and starting-count
    else
      if mirror.mode==1 then
        mirror.countp=util.wrap(mirror.countp+1,0,mirror.rec_len-1)     --..else keep counting internally
      elseif mirror.mode==2 then
        mirror.countp=util.wrap(mirror.countp-1,0,mirror.rec_len-1)     --..or reverse count
      elseif mirror.mode==3 then
        mirror.countp=util.wrap(math.random(1,mirror.rec_len),0,mirror.rec_len-1) end  --..or randomized count
    end
    if noff>0 then
      softcut.position(mirror.vox_num,
        util.wrap((mirror.countp*(mirror.length/mirror.rec_len))+mirror.strt,
        mirror.strt,(mirror.length*loop_amt)+mirror.strt))
    end
    softcut.level(mirror.vox_num,noff)
    softcut.play(mirror.vox_num,noff);                                                  --play
    return noff,count
end

function mirror.rec(count, rst)
    if rst>0 then                           --rst used to reset count and store starting-count
      mirror.countr=rst; mirror.rec_track = 1 
      softcut.position(mirror.vox_num,
        util.wrap((mirror.countr*(mirror.length/mirror.rec_len))+mirror.strt,
        mirror.strt,mirror.length+mirror.strt)); mirror.rec_noff=1
    else mirror.countr=util.wrap(mirror.countr+1,0,mirror.rec_len-1); mirror.rec_track=mirror.rec_track+1; end --normal rec(wraparound)
    softcut.rec(mirror.vox_num,mirror.rec_noff);                --instruct softcut recording
    if mirror.rec_track>=mirror.rec_len then mirror.rec_noff=0 end        --end
    return mirror.rec_noff,count                              --return recording flag state
end

return mirror
