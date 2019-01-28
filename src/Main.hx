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
		root.filter = new h2d.filter.ColorMatrix();


		onResize();
		new mt.deepnight.GameFocusHelper(Boot.ME.s2d, Assets.font);

		delayer.addF( function() {
			var music = new mt.deepnight.Sfx(hxd.Res.music);
			music.playOnGroup(1, true, 0.7);
			#if !debug
			new Intro();
			#else
			// new Intro();
			new Game(1);
			//new Outro();
			#end
		}, 1);
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
		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = mt.MLib.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = mt.MLib.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );
		Const.LWID = mt.MLib.ceil( w()/Const.SCALE );
		Const.LHEI = mt.MLib.ceil( h()/Const.SCALE );
		root.setScale(Const.SCALE);
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

