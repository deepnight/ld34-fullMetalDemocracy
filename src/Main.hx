class Main extends mt.Process {
	public static var ME : Main;
	//public var cached			: h2d.Sprite;

	public function new() {
		super();
		ME = this;

		hxd.Res.initEmbed({compressSounds:true});
		Assets.init();
		hxd.Timer.wantedFPS = Const.FPS;

		createRoot(Boot.ME.s2d);
		root.setScale(Const.UPSCALE);
		// cached = new h2d.CachedBitmap(Boot.ME.s2d, Std.int(w()/Const.UPSCALE), Std.int(h()/Const.UPSCALE));
		// cached.scale(Const.UPSCALE);
		// cached.blendMode = None;

		Const.LWID = mt.MLib.ceil( w()/Const.UPSCALE );
		Const.LHEI = mt.MLib.ceil( h()/Const.UPSCALE );

		var music = new mt.deepnight.Sfx(hxd.Res.music);
		music.playOnGroup(1, true, 0.7);
		// Assets.SBANK.music().playOnGroup(1, true, 0.7);
		// Assets.SBANK.music().playLoopOnChannel(1, 0.7);
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

		var mask = new h2d.Bitmap( h2d.Tile.fromColor(addAlpha(0xFFEEBB)), Boot.ME.s2d);
		mask.scaleX = w()/mask.tile.width;
		mask.scaleY = h()/mask.tile.height;

		tw.createMs(mask.alpha, 0>1, 500).end( function() {
			if( p!=null )
				p.destroy();

			delayer.addMs( function() {
				cb();
				tw.createMs(mask.alpha, 0, 1500).end( mask.remove );
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
			mt.deepnight.Sfx.toggleMuteGroup(1);
			// mt.flash.Sfx.toggleMuteChannel(1);

		if( hxd.Key.isPressed(hxd.Key.S) )
			mt.deepnight.Sfx.toggleMuteGroup(0);
			// mt.flash.Sfx.toggleMuteChannel(0);
	}
}

