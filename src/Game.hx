import en.*;

import mt.MLib;
import hxd.Key;
import mt.deepnight.Tweenie;

class Game extends mt.Process {
	public static var ME : Game;

	public var fx			: Fx;
	public var scroller		: h2d.Layers;

	public var current		: en.Quad;
	public var level		: Level;
	public var ended					: Bool;
	var lid(get,never)		: Int; inline function get_lid() return level.lid;
	var lastMsg				: mt.Process;

	public function new(?lid=0) {
		super(Main.ME);

		ME = this;
		ended = false;

		initGraphicContext(Main.ME.cached);
		scroller = new h2d.Layers(root);

		level = new Level(lid);
		fx = new Fx();

		for(id in [0,1]) {
			var pt = level.getSpots("quad"+id)[0];
			new en.Quad(id, (pt.cx+0.5)*Const.GRID, (pt.cy+0.5)*Const.GRID, id);
		}
		current = en.Quad.ALL[0];

		for(pt in level.getSpots("zerg"))
			new en.m.Zergling((pt.cx+0.5)*Const.GRID, (pt.cy+0.5)*Const.GRID, null);

		for(pt in level.getSpots("zergWander")) {
			var e = new en.m.Zergling((pt.cx+0.5)*Const.GRID, (pt.cy+0.5)*Const.GRID, null);
			e.cd.set("fixed", 99999);
		}

		var spots = level.getSpots("human");
		for(i in 0...200) {
			var pt = spots[Std.random(spots.length)];
			new en.Human((pt.cx+0.5)*Const.GRID, (pt.cy+0.5)*Const.GRID);
		}

		var s = Assets.lib.h_get("border");
		root.add(s, Const.DP_UI);
		s.alpha = 0.4;
		s.scaleX = Const.LWID/s.tile.width;
		s.scaleY = Const.LHEI/s.tile.height;

		new MiniMap();

		delayer.add( function() {
			if( lid>0 )
				notify("ENTERING SECTOR #"+level.lid, "CAUTION: contamined area.");

			if( lid==0 )
				delayer.add(function() {
					message("Use ARROW keys to move. Attacks are automatics.", true);
				},500);
		},350);



		switch( lid ) {
			case 0 :
				cd.set("lockSwitch", 99999);

			default :
		}
	}

	public function switchCurrent() {
		if( cd.has("lockSwitch") )
			return;

		if( en.Quad.ALL.length==0 || cd.has("switch") )
			return;

		cd.set("switch",3);
		var idx = 0;
		for(e in en.Quad.ALL) {
			if( e==current )
				break;
			idx++;
		}
		if( idx<en.Quad.ALL.length-1 )
			current = en.Quad.ALL[idx+1];
		else
			current = en.Quad.ALL[0];

		Assets.SBANK.switch01(0.7);
	}

	override function onDispose() {
		super.onDispose();

		for(e in Scenery.ALL.copy())
			e.dispose();

		if( ME==this )
			ME = null;
	}

	override function onResize() {
		super.onResize();
	}

	public function isPlayArea(x:Float,y:Float) {
		var m = 40;
		return x>=m && y>=m && x<level.wid*Const.GRID-m && y<level.hei*Const.GRID-m;
	}

	public inline function isOnScreen(x,y) {
		return
			x>=-scroller.x-30 && x<=-scroller.x+Const.LWID+30 &&
			y>=-scroller.y-30 && y<=-scroller.y+Const.LHEI+30;
	}


	public function clearMsg() {
		if( lastMsg!=null ) {
			lastMsg.destroy();
			lastMsg = null;
		}
	}


	public function tutorial(id:String, str:String) {
		if( !cd.hasSet("t_"+id, 99999) ) {
			message(str, true);
			return true;
		}
		return false;
	}


	public function message(str:String, ?col=0xC0CEE7, ?perma=false) {
		var wrapper = new h2d.Sprite();
		root.add(wrapper, Const.DP_UI);

		Assets.SBANK.msg01().play(0.8, 1);

		var maxWid = 100;

		var bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x121223)), wrapper );
		bg.alpha = 0.85;

		var tf = new h2d.Text(Assets.font, wrapper);
		tf.text = str;
		tf.maxWidth = maxWid;
		tf.setScale(1);
		tf.textColor = col;

		cd.set("alive", secToFrames(4));

		if( lastMsg!=null )
			lastMsg.destroy();

		lastMsg = createChildProcess(
			function(p) {
				if( !cd.has("alive") && !perma ) {
					p.destroy();
					tw.create(wrapper.x, Const.LWID, 1000).end(wrapper.remove);
				}
			},
			function(p) {
				wrapper.remove();
				if( lastMsg==p )
					clearMsg();
			}
		);

		var p = 5;
		var h = (tf.textHeight*tf.scaleY + p*2 );
		bg.scaleX = (maxWid+p*2) / bg.tile.width;
		bg.scaleY = h / bg.tile.height;
		tf.setPos(p,p);

		wrapper.x = Const.LWID-maxWid*wrapper.scaleX-p*2;
		tw.create(wrapper.y, Const.LHEI>Const.LHEI*0.2, 700, TEaseOut);
		//tw.create(wrapper.x, -maxWid*wrapper.scaleX>Const.LWID-maxWid*wrapper.scaleX-p*2, 700, TEaseOut);
	}



	public function notify(title:String, sub:String, ?col=0xA5ACCB, ?bg=0x121223, ?perma=false) {
		var wrapper = new h2d.Sprite();
		root.add(wrapper, Const.DP_UI);
		tw.create(wrapper.alpha, 0>1, 350);
		tw.create(wrapper.y, 0>Const.LHEI*0.2, 500, TEaseOut);

		var blurWrapper = new h2d.Sprite(wrapper);

		var bar = Assets.lib.h_get("notifBg", wrapper);
		bar.colorize(bg, 0.8);
		//bar.blendMode = Add;
		bar.scaleX = Const.LWID/bar.tile.width;

		var tf = new h2d.Text(Assets.font, wrapper);
		tf.text = title;
		tf.setScale(2);
		tf.textColor = col;
		tf.setPos(Const.LWID*0.5- tf.textWidth*tf.scaleX*0.5, 0);
		var title = tf;

		var tf = new h2d.Text(Assets.font, wrapper);
		tf.text = sub;
		tf.textColor = 0xffffff;
		tf.setPos(Const.LWID*0.5- tf.textWidth*tf.scaleX*0.5, 25);
		var sub = tf;

		cd.set("alive", secToFrames(4));

		createChildProcess(function(p) {
			if( !cd.hasSet("blur",1) ) {
				var s = Assets.lib.h_get("blur", blurWrapper);
				s.colorize(bg, rnd(0.2, 0.3));
				s.constraintSize(Const.LWID);
				s.x = Const.LWID*rnd(0.5,1);
				s.scaleY *= 0.35;
				s.y = rnd(0,bar.tile.height*bar.scaleY-s.tile.height*s.scaleY);
				tw.create(s.alpha, 0, 500);
				tw.create(s.x, s.x-Const.LWID*1.5, TLinear, 500).end( s.remove );
			}
			if( !cd.has("alive") && !perma ) {
				p.destroy();
				tw.create(wrapper.alpha, 1>0, 1500).end(wrapper.remove);
			}
		});
	}


	function getScore() {
		return MLib.round( (1-2*MiniMap.ME.creepRatio)*1000 );
	}


	function win() {
		ended = true;
		cd.set("won",9999);

		clearMsg();

		var wrapper = new h2d.Sprite();
		root.add(wrapper, Const.DP_UI);

		notify("SECTOR CLEARED!", "Enemy expansion stopped!", 0xFFDF00, true);

		var tf = new h2d.Text(Assets.fontOutline, wrapper);
		tf.setScale(2);
		//tf.textColor = 0xFFD33E;
		tf.text = [
			"INFECTION: "+Std.int(MiniMap.ME.creepRatio*100)+"%",
			"SCORE: "+getScore(),
			"",
			"Press C to continue",
		].join("\n");
		tf.x = Const.LWID*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = Const.LHEI*0.4;
		tw.create(tf.x, 250|Const.LWID>tf.x, 350);

		teint(0xBB4004, 0.5);
	}

	function teint(c, tr) {
		var f = new h2d.filter.ColorMatrix();
		scroller.filters.push(f);
		var r = 0.;
		tw.create( r, tr, 2000).update( function() {
			f.matrix = mt.deepnight.Color.getColorizeMatrixH2d(c, r, 1-r);
		});
	}


	function gameOver() {
		ended = true;

		clearMsg();

		var wrapper = new h2d.Sprite();
		root.add(wrapper, Const.DP_UI);

		notify("You failed!", "The contamination reached 50% of the area!", 0xFF0000, true);


		var tf = new h2d.Text(Assets.fontOutline, wrapper);
		tf.setScale(2);
		tf.text = [
			"Press C to continue",
		].join("\n");
		tf.x = Const.LWID*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = Const.LHEI*0.4;
		tw.create(tf.x, 250|Const.LWID>tf.x, 350);

		teint(0x970000,0.7);
	}


	override public function postUpdate() {
		super.postUpdate();
		Assets.lib.updateChildren(dt);
	}

	function nextLevel() {
		if( !Assets.lib.exists("level", lid+1) )
			Main.ME.transition(this, function() new Outro());
		else
			Main.ME.transition(this, function() new Game(lid+1));
	}

	override function update() {
		super.update();

		if( lid==0 ) {
			if( lid==0 && current.cx>=55 && cd.has("lockSwitch") ) {
				cd.unset("lockSwitch");
				message("You cannot destroy GENERATORS using your current weapon. Press SPACE to switch to your secondary robot.", true);
			}
			if( current.id==1 )
				tutorial("missiles", "Missiles from this robot can destroy GENERATORS, but have NO effect on enemy TROOPS.");
		}

		var s = 0.3;
		scroller.x += ( -(current.x - Const.LWID*0.5) - scroller.x ) * s;
		scroller.y += ( -(current.y - Const.LHEI*0.5) - scroller.y ) * s;
		scroller.x = MLib.fclamp(scroller.x, -level.wid*Const.GRID+Const.LWID, 0);
		scroller.y = MLib.fclamp(scroller.y, -level.hei*Const.GRID+Const.LHEI, 0);

		if( ended && Key.isPressed(Key.C) && !cd.hasSet("clock",9999) ) {
			Assets.SBANK.menu01(0.8);
			if( cd.has("won") )
				nextLevel();
			else
				Main.ME.transition(this, function() new Game(lid));
		}

		#if debug
		if( Key.isPressed(Key.N) )
			nextLevel();
		#end

		//if( lastMsg!=null && Key.isPressed(Key.K) )
			//lastMsg.destroy();

		if( !ended && MiniMap.ME.creepRatio>=0.5 )
			gameOver();

		if( !ended && en.Mob.ALL.length==0 )
			win();

		for(w in [30,40])
			if( MiniMap.ME.creepRatio>=w/100 && !cd.hasSet("warn"+w, 99999) )
				notify("WARNING", "Sector contamination at "+w+"%!", 0xFFCF28, 0xFF0000);

		for(e in Scenery.ALL)
			e.update();

		var i = 0;
		while(i<Scenery.ALL.length)
			if( Scenery.ALL[i].destroyed )
				Scenery.ALL[i].dispose();
			else
				i++;
	}
}