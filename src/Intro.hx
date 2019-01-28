import mt.deepnight.Tweenie;

class Intro extends mt.Process {
	public function new() {
		super(Main.ME);

		createRoot(Main.ME.root);

		var logo = Assets.lib.h_get("logo", 0.5,0.5, root);
		logo.setPosition(Const.LWID*0.5, Const.LHEI*0.5);
		tw.createMs(logo.alpha, 0>1, 500);

		var tf = new h2d.Text(Assets.font, root);
		tf.text = "A game by Sébastien Bénard";
		tf.x = Const.LWID*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = Const.LHEI*0.62;
		tw.createMs(tf.alpha, 500|0>1, 1500);
		var tf1 = tf;

		var tf = new h2d.Text(Assets.font, root);
		tf.textColor = 0x8291AC;
		tf.text = "Click to start";
		tf.x = Const.LWID*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = Const.LHEI*0.8;
		tw.createMs(tf.alpha, 1200|0>1, 1500);
		var tf2 = tf;

		var i = new h2d.Interactive(w(), h(), root);
		i.onClick = function(_) {
			if( !cd.hasSetF("click",9999) ) {
				cd.setF("exit", 30);
				Assets.SBANK.menu01(0.8);
				tw.createMs(tf1.alpha, 0, 500);
				tw.createMs(tf2.alpha, 0, 500);
				tw.createMs(logo.y, logo.y-100, 250, TEaseIn);

				var tf = new h2d.Text(Assets.font, root);
				tf.textColor = 0x95B3DF;
				tf.text = [
					"EARTH IS IN GREAT DANGER.",
					"A new terrifying menace is spreading everywhere, growing really rapidly.",
					"Some call it the CREEP.",
					"But we call it a fucking good reason to draw our biggest guns to kick some ass. And show YOU who the hell really rule this world.",
					"To protect freedom, we use lethal force.",
					"We are the FULL METAL DEMOCRACY special unit.",
				].join("\n\n");
				tf.maxWidth	= 200;
				tf.x = Const.LWID*0.5 - tf.maxWidth*tf.scaleX*0.5;
				tf.y = Const.LHEI*0.35;
				tf.textAlign = Center;
				tw.createMs(tf.alpha, 500|0>1, 1000);
			}
			else if( !cd.has("exit") && cd.has("click") && !cd.hasSetF("click2",9999) ) {
				Assets.SBANK.menu01(0.8);
				Main.ME.transition(this, function() new Game());
			}
		}
	}


	override function onDispose() {
		super.onDispose();
	}

	override function onResize() {
		super.onResize();
	}

	override function update() {
		super.update();
	}
}

