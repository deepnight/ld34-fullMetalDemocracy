class Assets {
	public static var SBANK	= dn.heaps.assets.SfxDirectory.load("sfx",true);
	public static var font			: h2d.Font;
	public static var fontOutline	: h2d.Font;
	public static var lib			: SpriteLib;
	public static var music			: dn.heaps.Sfx;

	public static function init() {
		if( font!=null )
			throw "init twice";

		lib = dn.heaps.assets.Atlas.load("lib.atlas");
		// lib = dn.heaps.slib.assets.TexturePacker.load("lib.xml");

		font = hxd.Res.fonts.alterebro.toFont();
		fontOutline = hxd.Res.fonts.alterebroOutline.toFont();

		lib.defineAnim("humanWalk", "0-1(3)");
		lib.defineAnim("humanRun", "0(3), 1(1), 2(3), 1(1)");

		#if hl
		music = new dn.heaps.Sfx(hxd.Res.music);
		#else
		music = new dn.heaps.Sfx(hxd.Res.music_js);
		#end
		music.groupId = 1;
		dn.heaps.Sfx.setGroupVolume(1,0.7);
	}

	public static inline function one(arr:Array<?Float->dn.heaps.Sfx>, ?vol=1.0) : dn.heaps.Sfx {
		return arr[Std.random(arr.length)](vol);
	}
}