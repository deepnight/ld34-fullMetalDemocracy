import mt.MLib;

class MiniMap extends mt.Process {
	public static var ME : MiniMap;

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

		initGraphicContextInLayers(Game.ME.root, Const.DP_UI);
		root.setPos(2,2);

		var w = Std.int(level.wid*Const.GRID*scale);
		var h = Std.int(level.hei*Const.GRID*scale);

		var bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x0), w+2,h+2), root );
		bg.setPos(-1,-1);

		bd = new hxd.BitmapData( w,h );
		tex = h3d.mat.Texture.fromBitmap(bd);

		bdBase = bd.clone();
		bdBase.fill(0,0,bd.width,bd.height, alpha(0x47591C));

		for(pt in level.getSpots("road"))
			dotCase(bdBase, pt.cx, pt.cy, 0x7E705A);

		for(pt in level.getSpots("tree"))
			dotCase(bdBase, pt.cx, pt.cy, 0x5B7324);


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

	inline function dot(?b:hxd.BitmapData, x:Float, y:Float, c:UInt) {
		(b==null?bd:b).setPixel( Std.int(x*scale), Std.int(y*scale), alpha(c) );
	}

	inline function dotCase(?b:hxd.BitmapData, cx:Int, cy:Int, c:UInt) {
		(b==null?bd:b).setPixel( Std.int(cx*Const.GRID*scale), Std.int(cy*Const.GRID*scale), alpha(c) );
	}

	override public function update() {
		super.update();

		if( !cd.hasSet("refresh",10) ) {
			var ccount = 0;
			bd.draw(0,0, bdBase, 0,0, bd.width, bd.height);

			for(cx in 0...level.wid)
				for(cy in 0...level.hei)
					if( level.hasCreep(cx,cy) ) {
						ccount++;
						dotCase(cx,cy, 0x740E29);
					}

			for(e in en.Mob.ALL)
				if( Std.is(e,en.m.Zergling) )
					dot(e.x, e.y, 0x8E7BEA );

			for(e in en.Mob.ALL)
				if( Std.is(e,en.m.Creeper) )
					dot(e.x, e.y, 0xFF0000 );

			for(e in en.Quad.ALL)
				dot(e.x, e.y, 0xFFFFFF);

			tex.uploadBitmap(bd);

			creepRatio = ccount/(level.wid*level.hei);
		}
	}
}
