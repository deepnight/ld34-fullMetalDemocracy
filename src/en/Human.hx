package en;

class Human extends Entity {
	public static var ALL : Array<Human> = [];
	var originX			: Float;
	var originY			: Float;

	var tx				: Float;
	var ty				: Float;
	var runSpd			: Float;
	var fearDist		: Float;

	public function new(x,y) {
		super(x,y);

		life = 1;
		collides = true;
		ALL.push(this);
		originX = x;
		originY = y;
		spd = rnd(0.06, 0.08);
		runSpd = spd*rnd(3,4);
		fearDist = rnd(90,140);
		tx = originX + rnd(20,70,true);
		ty = originY + rnd(20,70,true);

		spr.set("humanIdle");

		spr.anim.registerStateAnim("humanRun",2, function() return M.fabs(dx)>=runSpd*0.9 || M.fabs(dy)>=runSpd*0.9);
		//spr.anim.registerStateAnim("humanWalk",1, function() return M.fabs(dx)>=spd*0.7 || M.fabs(dy)>=spd*0.7);
		spr.anim.registerStateAnim("humanIdle",0);

		Game.ME.scroller.add(spr, Const.DP_HUMANS);
	}

	override function onDie() {
		super.onDie();
		Game.ME.level.addDirt(x,y, "bloodSplash", rnd(0.8, 1));
		Game.ME.fx.blood(x,y);
	}

	override function onDispose() {
		super.onDispose();
		ALL.remove(this);
	}

	override function updateRender() {
		super.updateRender();
	}

	override function update() {
		super.update();

		if( !Game.ME.isOnScreen(x,y) ) {
			spr.visible = false;
			return;
		}
		spr.visible = true;

		var flee = null;
		for(e in Quad.ALL)
			if( distSqr(e)<fearDist*fearDist ) {
				flee = e;
				break;
			}
		if( flee!=null && !cd.has("panic") ) {
			tx = x;
			ty = y;
		}
		if( !cd.has("idle") ) {
			if( M.distSqr(x,y,tx,ty)<=5*5 ) {
				if( flee!=null ) {
					var a = Math.atan2(y-flee.y, x-flee.x) + rnd(0,1.9,true);
					var d = rnd(15,25);
					tx = x + Math.cos(a)*d;
					ty = y + Math.sin(a)*d;
					cd.setF("panic", 30);
				}
				else {
					var tries = 100;
					do {
						tx = originX + rnd(0,70,true);
						ty = originY + rnd(0,70,true);
					} while( !Game.ME.isPlayArea(tx,ty) && tries-->0 );
					if( tries<=0 ) {
						tx = originX;
						ty = originY;
					}
				}

				if( flee==null )
					cd.setF("idle", rnd(15,30));
			}

			var s = cd.has("panic") ? runSpd : spd;
			var ta = Math.atan2(ty-y, tx-x);
			dx+=Math.cos(ta)*s;
			dy+=Math.sin(ta)*s;
		}

	}
}
