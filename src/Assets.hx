import mt.heaps.slib.*;

class Assets {
	public static var SBANK	= mt.flash.Sfx.importDirectory("sfx");
	public static var font			: h2d.Font;
	public static var fontOutline	: h2d.Font;
	public static var lib			: SpriteLib;

	public static function init() {
		if( font!=null )
			throw "init twice";

		lib = mt.heaps.slib.assets.TexturePacker.importXml("lib.xml");

		font = hxd.Res.fonts.alterebro.toFont();
		fontOutline = hxd.Res.fonts.alterebroOutline.toFont();

		lib.defineAnim("humanWalk", "0-1(3)");
		lib.defineAnim("humanRun", "0(3), 1(1), 2(3), 1(1)");
	}

	public static inline function one(arr:Array<?Float->mt.flash.Sfx>) : mt.flash.Sfx {
		return arr[Std.random(arr.length)]();
	}
}