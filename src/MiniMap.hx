class MiniMap extends dn.Process {
	public static var ME : MiniMap;

	var tg : h2d.TileGroup;
	var bd					: hxd.BitmapData;
	var bdBase				: hxd.BitmapData;
	var tex					: h3d.mat.Texture;
	var level(get,never)	: Level; inline function get_level() return Game.ME.level;
	var scale = 0.06;
	public var creepRatio	: Float;

	public function new() {
		super(Game.ME);

		ME = this;
		creepRatio = 0;

		createRootInLayers(Game.ME.root, Const.DP_UI);
		root.setPosition(2,2);

		var w = Std.int(level.wid*Const.GRID*scale);
		var h = Std.int(level.hei*Const.GRID*scale);

		var bg = new h2d.Bitmap( h2d.Tile.fromColor(addAlpha(0x0), w+2,h+2), root );
		bg.setPosition(-1,-1);

		tg = new h2d.TileGroup(Assets.lib.tile, root);
		bd = new hxd.BitmapData( w,h );
		tex = h3d.mat.Texture.fromBitmap(bd);

		bdBase = bd.clone();
		bdBase.fill(0,0,bd.width,bd.height, addAlpha(0x47591C));

		// for(pt in level.getSpots("road"))
		// 	dotCase(pt.cx, pt.cy, 0x7E705A);

		// for(pt in level.getSpots("tree"))
		// 	dotCase(pt.cx, pt.cy, 0x5B7324);


		var tf = new h2d.Text(Assets.fontOutline,root);
		tf.x = 1;
		tf.y = bd.height;
		createChildProcess(function(_) {
			if( itime%5==0 )
				tf.text = "Infection: "+ Std.int(creepRatio*100)+"%";
			#if debug
			tf.text = Std.string(pretty(hxd.Timer.fps()));
			#end
		});

		root.addChild( new h2d.Bitmap(h2d.Tile.fromTexture(tex)) );
	}

	override public function onDispose() {
		super.onDispose();
		tex.dispose();
		bd.dispose();

		if( ME==this )
			ME = null;
	}

	inline function dot(x:Float, y:Float, c:UInt) {
		tg.addColor(
			Std.int(x*scale), Std.int(y*scale),
			Color.getR(c), Color.getG(c), Color.getB(c), 1.0,
			Assets.lib.getTile("pixel")
		);
	}

	inline function dotCase(cx:Int, cy:Int, col:UInt) {
		tg.addColor(
			Std.int(cx*Const.GRID*scale), Std.int(cy*Const.GRID*scale),
			Color.getR(col), Color.getG(col), Color.getB(col), 1.0,
			Assets.lib.getTile("pixel")
		);
	}

	inline function icon(x:Float, y:Float, col:UInt, t:h2d.Tile) {
		tg.addColor(
			Std.int(x*scale), Std.int(y*scale),
			Color.getR(col), Color.getG(col), Color.getB(col), 1.0,
			t
		);
	}

	var blink = false;
	override public function update() {
		super.update();

		if( !cd.hasSetF("refresh",10) ) {
			blink = !blink;
			var ccount = 0;
			tg.clear();

			for(pt in level.getSpots("road"))
				dotCase(pt.cx, pt.cy, 0x7E705A);

			for(pt in level.getSpots("tree"))
				dotCase(pt.cx, pt.cy, 0x5B7324);

			for(cx in 0...level.wid)
				for(cy in 0...level.hei)
					if( level.hasCreep(cx,cy) ) {
						ccount++;
						dotCase(cx,cy, 0x740E29);
					}

			for(e in en.Mob.ALL)
				if( Std.isOfType(e,en.m.Zergling) )
					dot(e.x, e.y, 0x8E7BEA );

			for(e in en.Mob.ALL)
				if( Std.isOfType(e,en.m.Creeper) )
					icon(e.x, e.y, 0xff0000, Assets.lib.getTile("triangle"));

			for(e in en.Quad.ALL)
				icon(e.x, e.y, blink && Game.ME.current==e ? 0xffffff : e.id==0?0xe1bf15:0xd327d2, Assets.lib.getTile("heart"));

			creepRatio = ccount/(level.wid*level.hei);
		}
	}
}
