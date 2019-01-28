class Main extends mt.Process {
	public static var ME : Main;
	//public var cached			: h2d.Sprite;
	public var cached			: h2d.CachedBitmap;

	public function new() {
		super();
		ME = this;

		Assets.init();

		//delayer.add( function() {
			//engine.resize( Std.int(w()/Const.UPSCALE), Std.int(h()/Const.UPSCALE));
			//App.ME.s2d.setFixedSize( engine.width, engine.height );
		//}, 1500);

		//cached = new h2d.Sprite(App.ME.s2d);
		cached = new h2d.CachedBitmap(App.ME.s2d, Std.int(w()/Const.UPSCALE), Std.int(h()/Const.UPSCALE));
		cached.scale(Const.UPSCALE);
		cached.blendMode = None;

		Const.LWID = mt.MLib.ceil( w()/Const.UPSCALE );
		Const.LHEI = mt.MLib.ceil( h()/Const.UPSCALE );

		Assets.SBANK.music().playLoopOnChannel(1, 0.7);
		//hxd.Res.music.ld34.play(true, 0.7);

		#if !debug
		new Intro();
		#else
		//new Intro();
		new Game(1);
		//new Outro();
		#end
	}


	public function transition( p:mt.Process, cb:Void->Void ) {
		if( p!=null )
			p.pause();

		var mask = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0xFFEEBB)), App.ME.s2d);
		mask.scaleX = w()/mask.tile.width;
		mask.scaleY = h()/mask.tile.height;

		tw.create(mask.alpha, 0>1, 500).end( function() {
			if( p!=null )
				p.destroy();

			delayer.add( function() {
				cb();
				tw.create(mask.alpha, 0, 1500).end( mask.remove );
			},100);
		});
	}


	override function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	override function onResize() {
		super.onResize();
	}

	override function update() {
		super.update();

		if( hxd.Key.isPressed(hxd.Key.M) )
			mt.flash.Sfx.toggleMuteChannel(1);

		if( hxd.Key.isPressed(hxd.Key.S) )
			mt.flash.Sfx.toggleMuteChannel(0);
	}
}

