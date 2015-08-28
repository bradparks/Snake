package;

#if openfl import abvex.AM; #else import abv.AM; #end
import abv.*;
import abv.ds.FS;
import abv.lib.style.*;
import abv.lib.style.Style;
import abv.lib.*;
import abv.lib.anim.*;
import abv.lib.comp.*;
import abv.lib.math.*;
import abv.ui.*;
import abv.bus.*;

using abv.lib.CC;
using abv.lib.TP;
//
class Game extends Root{

	var snake:Array<Component> = [];
	var food:Array<Component> = [];
	var corners:Array<Point> = [];
	public var dir = new Point();
	var old = new Point();
	var np:Point;
	var sp:Point;
	var world:Rectangle;
	var speed:Int;
	var sWidth:Int;
	var sLength:Int;
	var fLength:Int;
	
	public function new(w:Float,h:Float)
	{
		super("Game",w,h);

		MS.cmCode("cmSpeed");
		MS.cmCode("cmFood");

		init() ;
	}// new()

	public function init() 
	{
		speed = 2;
		snake.clear();
		corners.clear();
		food.clear();
		
		build("res/","Snake"); 
		
		for(c in children){
			if(c.id.starts("snake"))snake.push(c);
			else if(c.id.starts("food"))food.push(c);
		//	trace(c.id); 
		}
		sWidth = styles[".snake"].width.int();
		world = new Rectangle(0,0,width-sWidth,height-sWidth); 
		
//		for(i in 0...sLength)addSnake();
		corners[0] = snake[0].pos;

//		for(i in 0...fLength)addFood();
	}// init()

	function addSnake()
	{
		var pt:Point;
		var i = snake.length;
		if(i == 0)return;
		else if(i == 1)pt = new Point(snake[0].pos.x-sWidth,snake[0].pos.y);
		else{
			pt = snake[i-1].pos.sub(snake[i-2].pos); //trace(snake[i-1].pos+":"+snake[i-2].pos+":"+pt);
			pt.scale(sWidth/pt.length);  //trace(pt);
			pt = pt.add(snake[i-1].pos); //trace(pt);
		}
//		pt = new Point(snake[i-1].pos.x-sWidth,snake[i-1].pos.y);
		snake[i] = new Component("snake_"+i); 
		snake[i].pos.copy(pt); 
		Style.apply(snake[i],styles[".snake"]); 
		addChild(snake[i]); 
	}//
	
	function randPoint()
	{
		var x = sWidth + Math.random() * (width - 2*sWidth); 
		var y = sWidth + Math.random() * (height - 2*sWidth); 
		return new Point(x,y);
	}//
	
	function addFood()
	{
		var i = food.length;
		food[i] = new Component("food_"+i); 
		food[i].pos.copy(randPoint()); 
		Style.apply(food[i],styles[".food"]); 
		addChild(food[i]); 
	}//
	
	function delFood(ix:Int)
	{
		var f = food[ix];
		if(f != null){
			food.remove(f); 
			delChild(f);
		}
	}//
	
	public override function update()
	{
		var ix = CC.ERR;
		var rect:Rectangle;
		
		if(dir.length == 0)return;
		if(dir.eq(old.opposite())){
			dir.copy(old);
			return;
		}
		
		if(!old.eq(dir)){ 
			sp = snake[0].pos.clone(); 
			corners.insert(1,sp); 
//for(k in 0...corners.length)trace(k+":"+corners[k]);
			old.copy(dir);
		}
		
		np = dir.clone().scale(speed);	
		snake[0].pos = snake[0].pos.add(np);
	
		for(i in 1...snake.length){
			for(j in 0...corners.length-1){ 
					if(snake[i].pos.between(corners[j],corners[j+1])){ 
						np.copy(corners[j]);
						if((i == (snake.length-1))&&(corners.length > 2)){
							corners.pop();
						}
						break;					
					}
					np.copy(corners[j+1]);
			}
		
			np = np.sub(snake[i].pos); 
			if(np.length > 0){ 
				np.scale(speed/np.length); //trace(i+":"+np);
				snake[i].pos = snake[i].pos.add(np);
			}
		}
		
		for(j in 1...corners.length-1){ 
			if(snake[0].pos.between(corners[j],corners[j+1])){
				dir.reset();
				msgBox(LG.get("GameOver"));
				break;	
			}					
		}
		
		if(!world.containsPoint(snake[0].pos)){
			dir.reset();
			msgBox(LG.get("GameOver")); trace(state);
			AM.playMusic("res/audio/beat.wav");
		} 
							
		for(i in 0...food.length){
			rect = new Rectangle(food[i].pos.x-sWidth,food[i].pos.y-sWidth,2*sWidth,2*sWidth); 
			if(rect.containsPoint(snake[0].pos)){ 
				food[i].pos.copy(randPoint()); 
				addSnake(); 
				if((snake.length%5) == 0)addFood();
				AM.playSound("res/audio/scratch.wav");
				break;
			} 
		}
		
	}// update()
	
	override function dispatch(md:MD)
	{ 	//	trace(id+": "+md);
		switch(md.msg) {
			case MD.MSG: 
				var cm = md.f[0];
				if(cm ==  MS.cmCode("cmSpeed")){
					speed = md.f[1].int() + 1;
				}
		}
	}// dispatch()

	function msgBox(s="")
	{
		MS.exec(new MD(sign,"mboxTxt",MD.NEW,null,s)); 
		MS.exec(new MD(sign,"mbox",MD.OPEN)); 
	}//
	
}// Game

