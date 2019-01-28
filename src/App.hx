class App extends hxd.App {
	public static var ME : App;

	// Boot
	static function main() {
		//#if debug
		//hxd.res.Resource.LIVE_UPDATE = true;
		//hxd.Res.initLocal();
		//Std.instance(hxd.Res.loader.fs, hxd.fs.LocalFileSystem).createMP3 = true;
		//#else
		//hxd.Res.initEmbed({compressSounds:true});
		//#end
		hxd.Res.initEmbed({compressSounds:true});

		new App();
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
		mt.Process.updateAll(dt);
	}
}

