function set_fdiv(fdv) params:set("file_div",fdv) end
function set_pdiv(pdv) params:set("loops",pdv) end
function set_fnl(fn) params:set("fnl",fn) end
function set_fxv(fv) 
  if fv<1 then 
    engine.fxrtrz(0); engine.fxrtcm(0); engine.fxrtds(0); engine.fxrtrv(0)
  end
  params:set("fxv",fv) 
end
function set_rln(rl) params:set("rln",rl) end
function set_lrc(lr) params:set("lrc",lr) end
function set_trg(tr) params:set("trg",tr) end
function set_vox(vx) params:set("vox",vx) end
--
params:add{type="number", id="file_div", min=1, max=128, default=16, action=function(x) set_fdiv(x) end}
params:add{type="number", id="loops", min=1, max=32, default=2, action=function(x) set_pdiv(x) end}
params:add{type="number", id="fnl", min=0, max=1, default=0, action=function(x) set_fnl(x) end}
params:add{type="number", id="fxv", min=0, max=1, default=0, action=function(x) set_fxv(x) end}
params:add{type="number", id="trg", min=2, max=128, default=4, action=function(x) set_trg(x) end}
params:add{type="number", id="vox", min=1, max=6, default=1, action=function(x) set_vox(x) end}
params:add{type="number", id="rln", min=2, max=128, default=16, action=function(x) set_rln(x) end}
params:add{type="number", id="lrc", min=0, max=1, default=0, action=function(x) set_lrc(x) end}