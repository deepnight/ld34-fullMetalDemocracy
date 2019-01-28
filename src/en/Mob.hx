package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public var prio		: Int;

	var barBg			: h2d.Bitmap;
	var bar				: h2d.Bitmap;
	var bwid = 25;
	var bhei = 1;

	public function new(x,y) {
		super(x,y);

		prio = 0;
		life = 30;
		ALL.push(this);
		spr.set("enemy");
		//Game.ME.scroller.add(spr, Const.DP_ENTITY);
	}

	function enableBar() {
		barBg = new h2d.Bitmap( h2d.Tile.fromColor(0x0,bwid+2, bhei+2) );
		Game.ME.scroller.add(barBg, Const.DP_UI);

		bar = new h2d.Bitmap( h2d.Tile.fromColor(0xFFFFFF, bwid,bhei) );
		Game.ME.scroller.add(bar, Const.DP_UI);
	}

	override function onDie() {
		super.onDie();
		Game.ME.fx.hit(x,y);
	}

	override function onDispose() {
		super.onDispose();
		ALL.remove(this);
		if( bar!=null ) {
			bar.remove();
			barBg.remove();
		}
	}

	override function updateRender() {
		super.updateRender();
		if( bar!=null ) {
			var r = life/maxLife;
			bar.scaleX = r;
			bar.setPosition(x-bwid*0.5, y-bhei-19);
			barBg.setPosition(bar.x-1, bar.y-1);
			bar.color.setColor(addAlpha(
				r>=0.8 ? 0xDEF000 :
				r>=0.5 ? 0xFFF200 :
				r>=0.25 ? 0xFF8600 :
				0xff0000
			));
		}
	}

	override function update() {
		super.update();
	}
}
