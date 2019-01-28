package en.m;

class Creeper extends en.Mob {
	public static var ALL : Array<en.Mob> = [];

	var eye				: mt.heaps.slib.HSprite;
	var babies			: Array<en.m.Zergling>;

	//var ex				: Float;
	//var ey				: Float;
	public function new(x,y) {
		super(x,y);

		ALL.push(this);
		babies = [];

		initLife(280);
		spr.set("creeper");
		spr.setCenterRatio(0.5,0.8);

		eye = Assets.lib.h_get("eye", 0.5,0.5);
		Game.ME.scroller.add(eye, Const.DP_ENTITY);

		var d = 5*Const.GRID;
		for(e in Scenery.ALL) {
			if( e.isTree() && mt.deepnight.Lib.distanceSqr(x,y,e.x,e.y)<=d*d ) {
				e.solid = false;
				e.explode();
			}
		}
		Game.ME.level.addCreepArea(cx,cy, 5);
		enableBar();

		cd.setF("spawn", secToFrames(4));
	}

	override function onDie() {
		super.onDie();

		Game.ME.level.addDirt(x,y, "hole", rnd(0.8, 0.9));

		for(i in 0...5) {
			var a = rnd(0,6.28);
			var d = rnd(0, 20);
			Game.ME.level.addDirt(x+Math.cos(a)*d, y+Math.sin(a)*d, "creepSplatter", 1);
		}
		Game.ME.level.addDirt(x,y, "explosionDirt", 0.5);
		Game.ME.fx.explosion(x,y, 30);

		playSpatial( Assets.SBANK.explode04(), x,y, 500, 1 );
		playSpatial( Assets.SBANK.hive01(), x,y, 500, 0.7 );

		for(e in babies)
			e.stun();
	}

	override function onDispose() {
		super.onDispose();
		eye.remove();
		ALL.remove(this);
		babies = null;
	}

	override function updateRender() {
		super.updateRender();
		spr.y += 8;
		//Game.ME.fx.marker(x,y);
		if( eye!=null ) {
			if( !cd.hasSetF("eye",rnd(2, 20)) ) {
				eye.setPosition(x-8+irnd(0,2,true), y-7 + irnd(0,1,true));
			}
		}
	}

	override function update() {
		super.update();

		spr.scaleX = 1 + Math.cos(ftime*0.9+uniqId)*0.01;
		spr.scaleY = 1 + Math.cos(ftime*0.1+uniqId)*0.04;

		if( !cd.hasSetF("spawn", secToFrames(rnd(1.5,3))) && babies.length<5 ) {
			var e = new en.m.Zergling(x+rnd(3,20,true),y+rnd(3,20,true), this);
			babies.push(e);
			Game.ME.fx.spawn(e.x, e.y);
		}

		// GC
		var i = 0;
		while( i<babies.length ) {
			if( babies[i].destroyed )
				babies.splice(i,1);
			else
				i++;
		}

	}
}
