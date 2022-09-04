class Entity extends dn.Process {
	public var game(get,never): Game; inline function get_game() return Game.ME;
	public var kidMode(get,never): Bool; inline function get_kidMode() return Game.kidMode;

	public var x		: Float;
	public var y		: Float;
	public var dx		: Float;
	public var dy		: Float;
	public var frict	: Float;
	public var spr		: HSprite;
	public var collides	: Bool;

	var spd				: Float;
	public var radius	: Float;
	var life			: Int;
	var maxLife			: Int;
	public var cx(get,never)	: Int; inline function get_cx() return Std.int(x/Const.GRID);
	public var cy(get,never)	: Int; inline function get_cy() return Std.int(y/Const.GRID);
	public var xr(get,never)	: Float; inline function get_xr() return x/Const.GRID - cx;
	public var yr(get,never)	: Float; inline function get_yr() return y/Const.GRID - cy;

	public function new(x:Float,y:Float) {
		super(Game.ME);

		collides = false;
		dx = dy = 0;
		frict = 0.85;
		radius = 5;
		initLife(1);
		spd = 1;

		spr = new HSprite(Assets.lib, "enemy");
		spr.setCenterRatio(0.5,0.5);
		Game.ME.scroller.add(spr, Const.DP_ENTITY);

		setPosition(x,y);
	}

	inline function playSpatial(s:dn.heaps.Sfx, x:Float, y:Float, maxDist:Float, ?vol=1.0) {
		s.play(vol); // TODO placeholder, not supported for now
	}

	public function is(t:Dynamic) return Std.isOfType(this, t);

	function initLife(v) {
		life = maxLife = v;
	}

	public function hit(dmg:Int) {
		if( dmg<=0 ) {
			if( !cd.has("damaged") && !cd.hasSetF("resist",8) ) {
				playSpatial( Assets.SBANK.resist01(), x,y, 200, 0.3);
				Game.ME.fx.resist(this);
			}
		}
		else {
			cd.setF("damaged", 4);
			life-=dmg;
		}

		if( life<=0 )
			onDie();
	}

	function onDie() {
		destroy();
	}


	public function setPosition(x,y) {
		this.x = x;
		this.y = y;
		//updateRender();
	}

	override function onDispose() {
		super.onDispose();
		spr.remove();
	}

	public function isColliding(e:Entity) {
		var d = radius + e.radius;
		return dn.M.distSqr(x,y,e.x,e.y)<=d*d;
	}

	public inline function dist(e:Entity) return dn.M.dist(x,y,e.x,e.y);
	public inline function distSqr(e:Entity) return dn.M.distSqr(x,y,e.x,e.y);

	override public function postUpdate() {
		super.postUpdate();
		updateRender();
	}

	function updateRender() {
		spr.x = Std.int(x);
		spr.y = Std.int(y);
	}

	override function update() {
		super.update();

		if( collides ) {
			if( xr<=0.3 && dx<0 && Game.ME.level.hasColl(cx-1,cy) )
				dx = 0;

			if( xr>=0.7 && dx>0 && Game.ME.level.hasColl(cx+1,cy) )
				dx = 0;

			if( yr<=0.3 && dy<0 && Game.ME.level.hasColl(cx,cy-1) )
				dy = 0;

			if( yr>=0.7 && dy>0 && Game.ME.level.hasColl(cx,cy+1) )
				dy = 0;
		}

		x+=dx*tmod;
		dx*=Math.pow(frict,tmod);

		y+=dy*tmod;
		dy*=Math.pow(frict,tmod);


		if( M.fabs(dx)<=0.05*tmod ) dx = 0;
		if( M.fabs(dy)<=0.05*tmod ) dy = 0;
	}
}