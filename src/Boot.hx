class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});

		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		engine.backgroundColor = 0x0;

		#if debug
		//new hxd.net.SceneInspector(s3d);
		#end

		new Main();
		onResize();
	}

	override function onResize() {
		super.onResize();
		mt.Process.resizeAll();
	}

	override function update(dt:Float) {
		super.update(dt);
		mt.Process.updateAll(hxd.Timer.tmod);
	}
}

