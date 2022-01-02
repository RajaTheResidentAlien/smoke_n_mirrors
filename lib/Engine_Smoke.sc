// CroneEngine_Smoke
// loopers ++
//     - raja
Engine_Smoke : CroneEngine {
	classvar maxVoices=16;
	    var pg;
	    var dg;
	    var fxg;
	    var mg;
	    var smokefx;
	    var fxroute;
	    var sidechain;
	    var mastering;
	    var first;
	    var smoke;
	    var mir7;
	    var bfr;
	    var bfrb;
	    var rzr;
	    var cmbr;
	    var tpd;
	    var dst;
	    var rvrb;
	    var mstr;
	    var fxnum=4;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		pg = ParGroup.tail(context.xg);
		dg = ParGroup.after(pg);
		fxg = ParGroup.after(dg);
		mg = ParGroup.after(fxg);
		fxroute = fxnum.do.collect({ Bus.control(context.server, 1).set(0) });
		smokefx = fxnum.do.collect({ Bus.audio(context.server, 2) });
		sidechain = Bus.audio(context.server,2);
	  mastering = Bus.audio(context.server,2);
		bfr = 2.do.collect({ Buffer.new(context.server) });
		bfrb = Buffer.alloc(context.server, 2048); 

		SynthDef("aw",
			{arg out, fxo, div=16, bnum, start=0.0, noff=0.0, sid;
			
			var trigz=T2A.ar(\tryg.tr);
			var stepsize=BufFrames.kr(bnum)/div;
			var pos=start*stepsize;
			var tdel=DelayN.ar(trigz,0.01,0.0025);
			var duckenv=Env.new([1, 0, 0, 1], [0.002, 0.001, 0.002], curve: 'cub');
			var duck=EnvGen.ar(duckenv,trigz);
			var awesomeness=PlayBuf.ar(2,bnum,BufRateScale.kr(bnum),tdel,pos,0)*duck*noff.lag3(0.01);
			Out.ar([fxo,out,sid],awesomeness);
		}).add;
		
		SynthDef("TheChebynator",
			{arg out, in, div=16, bnum, start=0.0, noff=1.0, tmp=2, sid;
			var input, output, clocktime, shapesteppa, rander, envgen, receive, fmin1, send, sand, routput, side, prein;
			side = In.ar(sid,2);
			prein = In.ar(in);
			input = ((prein*0.6).tanh*2.2).tanh;
			output = Shaper.ar(bnum,input);
			output = Shaper.ar(bnum,1-(input+1)) + output;
			clocktime = tmp;
		  shapesteppa = TRand.kr(tmp*0.5, tmp*4, Impulse.kr(clocktime*0.5))*2;
		  rander = TRand.kr(55, 88, \trygr.tr).lag3(0.1);
      receive = (output.ring4(SinOsc.ar(in*8888)+1)*0.4);
		  fmin1 = SinOsc.ar( (shapesteppa*rander)+receive) * Lag.kr(noff, 0.01);
		  send = LeakDC.ar(fmin1*output);
		  routput = MoogFF.ar(send+output,rander*5,2.2);
		  sand = Mix.ar(Array.fill(4,{ CombC.ar(routput, 0.1, LFNoise1.kr(0.1.rand, 0.01, 0.04), 0.8, 0.2) }));
		  sand = AllpassC.ar(sand, 0.040, [0.020.rand, 0.040.rand], 0.8);
		  sand = AllpassC.ar(sand, 0.040, [0.040.rand, 0.020.rand], 0.6);
			Out.ar(out,Limiter.ar(Compander.ar(((routput*0.5)+(sand*0.2)+(prein*0.4))!2,side,0.88,1,0.2,0.02,0.8),0.8,0.005));
		}).add;
		
		SynthDef("Rezor", { arg out, freq=220, amp=0.12, rngz=0.6, fxindx=smokefx[0].index, noff;
		
		      var freqs = Array.fill(5, { arg i; freq*((i*0.5)+1); });
		      var amps = Array.fill(5, { arg i; (1/((i+1)*3))*amp; });
		      var rings = Array.fill(5, { arg i; (1/(i+1)).pow(0.5)*rngz });
		      var receive = In.ar(fxindx, 2);
		      var send = DynKlank.ar(`[freqs, amps, rings], receive) * Lag.kr(noff, 0.01);
		      send = CompanderD.ar(send,0.6,1,0.25,0.002,0.4);
		      Out.ar(out, LeakDC.ar(send + receive));
		}).add;
		
		SynthDef("DelStereo", {arg out, time, fxindx=smokefx[1].index, noff;

		      var receiveL = In.ar(fxindx, 1);
		      var receiveR = In.ar(fxindx+1, 1);
		      var randdec = TRand.kr(1, 20, \trigr.tr);
		      var timeL = (TIRand.kr(1,8,\trigr.tr)/2);
		      var timeR = (TIRand.kr(1,8,\trigr.tr)/2);
		      var sendL = AllpassN.ar(receiveL * Lag3.kr(noff,0.01), 4, Lag3.kr(time * timeL,0.04), randdec);
		      var sendR = AllpassN.ar(receiveR * Lag3.kr(noff,0.01), 4, Lag3.kr(time * timeR,0.04), randdec);
		      Out.ar(out, [sendL+receiveL, sendR+receiveR]);
		}).add;
		
		SynthDef("Comber", { arg out, time, amp, noff, fxindx=smokefx[2].index;
		
		      var clocktime = time;
		      var freqsteppa = 
		              1/((TIRand.kr(1, 16, Impulse.kr(clocktime))) * clocktime * 16);
          var receive = In.ar(fxindx, 2);
		      var input = CombN.ar(receive*1.2, 1/clocktime, 
			            Lag3.kr(freqsteppa, 0.004), Lag3.kr(freqsteppa*32, 0.005));
		      var send = receive + (input * Lag3.kr(noff, 0.01)) * amp;
		      Out.ar(out, LeakDC.ar(send));
		}).add;
		
		SynthDef("Reverb", { arg out, noff, fxindx=smokefx[3].index;
		
		      var send;
		      var receive = In.ar(fxindx, 2);
		      var input = Mix.ar(Array.fill(5,{ CombC.ar(receive, 0.1, LFNoise1.kr(0.1.rand, 0.01, 0.05), 4, 0.1) }));
		      input = AllpassN.ar(input, 0.050, [0.050.rand, 0.050.rand], 1);
		      input = AllpassN.ar(input, 0.050, [0.050.rand, 0.050.rand], 1);
		      send = receive + (input  * Lag3.kr(noff, 0.01));
		      Out.ar(out, LeakDC.ar(send));
		}).add;
		
		SynthDef("Master", {arg in, out,thresh=0.988,below=1.0,above=0.4,att=0.008,rls=0.4;
		      var receive = In.ar(in, 2);
		      var send = Limiter.ar(CompanderD.ar(receive,thresh,below,above,att,rls),0.99,0.008);
		      Out.ar(out, send);
		}).add;

		this.addCommand("flow", "s", { arg msg;         //start, file-division, file
			var val=msg[1];
			bfr[0].allocRead(val);
			smoke = Synth.newPaused("aw", [\out,mastering,\fxo,smokefx[0],\bnum,bfr[0],\sid,sidechain.index],
			                        target: dg, addAction: \addToTail);
			mir7 = Synth.new("TheChebynator", [\out,mastering,\in,context.in_b,\bnum,bfrb,\sid,sidechain.index],
			                        target: dg, addAction: \addToTail);
      mstr = Synth.new("Master", [\in,mastering,\out,context.out_b], target: mg);
	  });
		
		this.addCommand("flex","is", { arg msg; bfr[msg[1]].allocRead(msg[2]); });
		
		this.addCommand("floss","ii", { arg msg; var bn=msg[1], on=msg[2]; smoke.set(\bnum,bn,\noff,on); });
		
		this.addCommand("awyea", "iff", { arg msg; //buffer number(0,1), start, file-division
			var val=msg[1], strt=msg[2], dv=msg[3];
			smoke.set(\bnum,val,\start,strt,\div,dv,\tryg,1); smoke.run;
		});
		
		this.addCommand("fleek","ffffffff", 
		                { arg msg; 
		                  bfrb.cheby([msg[1],msg[2],msg[3],msg[4],msg[5],msg[6]],1,1,msg[7]);
		                  mir7.set(\trygr,1,\tmp,msg[8]);});
		
    this.addCommand("rzr", "iffii", { arg msg,xtra,ot;
			var val = msg[1].midicps, gn = msg[2], md1 = msg[3], md2 = msg[4]; 
			xtra = msg[5]; if(xtra>0, {ot=smokefx[xtra-1];},{ot=mastering;});
      rzr = Synth("Rezor", 
      [\out,ot,\freq,val,\amp,gn,\rngz,md1,\fxindx,smokefx[md2],\noff,fxroute[0].asMap], 
      target:fxg);
		});
		
		this.addCommand("rzset", "iff", { arg msg;
			var val = msg[1].midicps, gn = msg[2], md1 = msg[3];
      rzr.set(\freq,val,\amp,gn,\rngz,md1);
		});
		
		this.addCommand("dst", "ffii", { arg msg,xtra,ot;
			var val = msg[1], md1 = msg[2], md2 = msg[3];
			xtra = msg[4]; if(xtra>0, {ot=smokefx[xtra-1];},{ot=mastering;});
      dst = Synth("DelStereo", 
      [\out,ot,\time,val,\trigr,md1,\fxindx,smokefx[md2],\noff,fxroute[1].asMap], 
      target:fxg, addAction: \addToTail);
		});
		
		this.addCommand("dstset", "ff", { arg msg;
			var val = msg[1], md1 = msg[2];
      dst.set(\time,val,\trigr,md1);
		});
		
		this.addCommand("cmbr", "ffii", { arg msg,xtra,ot;
			var val = msg[1].midicps, gn = msg[2], md1 = msg[3];
			xtra = msg[4]; if(xtra>0, {ot=smokefx[xtra-1];},{ot=mastering;});
      cmbr = Synth("Comber", 
      [\out,ot,\time,val,\amp,gn,\fxindx,smokefx[md1],\noff,fxroute[2].asMap], 
      target:fxg, addAction: \addToTail);
		});
		
		this.addCommand("cmbset", "ff", { arg msg;
			var val = msg[1].midicps, gn = msg[2];
      cmbr.set(\time,val,\amp,gn);
		});
		
		this.addCommand("rvrb", "ii", { arg msg,xtra,ot;
			var val = msg[1];
			xtra = msg[2]; if(xtra>0, {ot=smokefx[xtra-1];},{ot=mastering;});
      rvrb = Synth("Reverb", 
      [\out,ot,\fxindx,smokefx[val],\noff,fxroute[3].asMap], 
      target:fxg, addAction: \addToTail);
		});
		
		this.addCommand("first", "i", { arg msg; first = msg[1];});
		
		this.addCommand("fxrtrz", "i", { arg msg; fxroute[0].set(msg[1]);});
		
		this.addCommand("fxrtds", "i", { arg msg; fxroute[1].set(msg[1]);});
		
		this.addCommand("fxrtcm", "i", { arg msg; fxroute[2].set(msg[1]);});
		
		this.addCommand("fxrtrv", "i", { arg msg; fxroute[3].set(msg[1]);});
		
		// free all synths
		this.addCommand("darknez", "", {pg.set(\gate, 0);	dg.set(\gate, 0); mg.set(\gate, 0); this.free; });
	}
	free { pg.free; dg.free; mg.free; fxg.free; smokefx.free; fxroute.free; sidechain.free; mastering.free; Buffer.freeAll; }
}