package;
/**
 * Snake
 **/
#if openfl import abvex.AM; #else import abv.AM; #end
import abv.cpu.Timer;
import abv.bus.*;
import abv.io.*;
import abv.lib.anim.Juggler;
import abv.ui.Gui;

import abv.lib.style.Style;

using abv.lib.CC;

class App extends AM {

	var game:Game;
	
	public function new()
	{ 
		AM.verbose = DEBUG;
		AM.colors = true; 

		super("App");
	}// new()
	
	override function update()
	{   
		last += Timer.stamp() - last;
		
		game.update();
		Juggler.update();
		Screen.render(game);
	}// update()

	override function init() 
	{
		MS.setSlot(this,MD.KEY_DOWN);

		var w:Float = CC.WIDTH; 
		var h:Float = CC.HEIGHT; 

		gui = new Gui(w,h); 
		gui.build("res/ui/default/","gui"); 
		Screen.addRoot(gui); 
	
		game = new Game(w,h);
		game.context = CC.CONTEXT; 
		Screen.addRoot(game);

		onResize();		

	}// init()
	
	override function resize(w:Int,h:Int)
	{
		game.resize();
	}// resize()

	override function dispatch(md:MD)
	{ 	//	trace(id+": "+md);
		switch(md.msg) {
			case MD.KEY_DOWN: onKeyDown(md.f[0]);
			case MD.EXIT: exit();
			case MD.MSG: 
				var cm = md.f[0];
				if(cm ==  MS.cmCode("cmSound")){
					AM.sound = md.f[1] == 1?true:false; 
				}
		}
	}// dispatch()

	function onKeyDown(key:Float)
	{ 

		if(key == KB.SPACE){game.dir.reset();}
		else if(key == KB.N1){trace(MS.info());};
//		else if(key == KB.T)playMusic("res/audio/beat.wav",0);
//		else if(key == KB.G)playMusic("res/audio/scratch.wav");
		else if(key == KB.N2)trace("n2");
		
		var a = [KB.UP,KB.RIGHT,KB.DOWN,KB.LEFT];
		for(i in 0...a.length){
			if(key == a[i]){ 
				switch(i){
					case 0: game.dir.set(0,-1);
					case 1: game.dir.set(1,0);
					case 2: game.dir.set(0,1);
					case 3: game.dir.set(-1,0);
				}		
//				MS.exec(new MD(sign,"snake",MD.MOVE,[xxx,yyy])); //
				break;
			}	
		}	
	}// onKeyDown()
	
	public static function main() 
	{
 		var n = new App();
	}// main()

	
}// App

// HXCPP_ANDROID_PLATFORM=14

