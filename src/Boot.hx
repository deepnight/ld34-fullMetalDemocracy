class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
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
		dn.Process.resizeAll();
	}

	override function update(dt:Float) {
		super.update(dt);

		#if debug
		var mul = hxd.Key.isDown(hxd.Key.NUMPAD_SUB) ? 0.2 : 1.0;
		#else
		var mul = 1.0;
		#end
		dn.Process.updateAll(hxd.Timer.tmod * mul);
	}
}

