class Level extends dn.Process {
	public var wid			: Int;
	public var hei			: Int;
	var spots				: Map<String,Array<{cx:Int, cy:Int}>>;
	var creep				: h2d.TileGroup;
	var dirtGroups			: Array<h2d.TileGroup>;
	var fronts				: h2d.TileGroup;
	var creepMap			: Map<Int,Bool>;
	var curDirtGroup		: Int;
	public var lid			: Int;
	var colMap				: Array<Array<Bool>>;

	public function new(lid:Int) {
		super(Game.ME);

		this.lid = lid;

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		spots = new Map();
		creepMap = new Map();
		curDirtGroup = 0;
		dirtGroups = [];

		var roads = new h2d.TileGroup(Assets.lib.tile, root);
		var ground = new h2d.TileGroup(Assets.lib.tile, root);
		creep = new h2d.TileGroup(Assets.lib.tile, root);
		for(i in 0...10)
			dirtGroups.push( new h2d.TileGroup(Assets.lib.tile, root) );
		var shadows = new h2d.TileGroup(Assets.lib.tile, root);
		shadows.alpha = Const.SHADOW;
		fronts = new h2d.TileGroup(Assets.lib.tile);
		Game.ME.scroller.add(fronts, Const.DP_BG_FRONTS);


		// Source parsing
		var pixels = switch(lid) {
			case 0 : hxd.Res.level0.getPixels();
			case 1 : hxd.Res.level1.getPixels();
			case 2 : hxd.Res.level2.getPixels();
			case _ : hxd.Res.level3.getPixels();
		}
		// var source = Assets.lib.getBitmapData("level", lid);
		// source.lock();
		wid = pixels.width;
		hei = pixels.height;
		colMap = [];
		for(cx in 0...wid) {
			colMap[cx] = [];
			for(cy in 0...hei) {
				// var p = source.getPixel(cx,cy);
				var p = pixels.getPixel(cx,cy);
				var k = switch( p ) {
					case 0xffe5bf9f : "road";
					case 0xffcb4e31 : "house";
					case 0xff719826 : "tree";
					case 0xffe42dff : "csource";
					case 0xffff0000 : "zerg";
					case 0xff00ffff : "zergWander";
					case 0xff007aec	: "quad0";
					case 0xffff00ff	: "quad1";
					default : null;
				}
				if( k!=null )
					addSpot(k,cx,cy);
			}
		}
		pixels.dispose();
		// source.dispose();


		for(pt in getSpots("road"))
			if( Std.random(100)<20 )
				addSpot("human", pt.cx, pt.cy);

		for(pt in getSpots("house")) {
			if( !hasSpot("house", pt.cx-1, pt.cy) )
				addSpot("human", pt.cx-1, pt.cy);
			if( !hasSpot("house", pt.cx, pt.cy+1) )
				addSpot("human", pt.cx, pt.cy+1);
		}


		for(cx in 0...wid)
			for(cy in 0...wid) {
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;
				if( hasSpot("road",cx,cy) ) {
					if( !hasSpot("road", cx-1,cy) && !hasSpot("road",cx+1,cy) )
						roads.add(x, y, Assets.lib.getTileRandom("roadV"));
					else if( !hasSpot("road", cx,cy-1) && !hasSpot("road",cx,cy+1) )
						roads.add(x, y, Assets.lib.getTileRandom("roadH"));
					else
						roads.add(x, y, Assets.lib.getTileRandom("roadC"));
				}
				else {
					ground.add(x-1,y-1, Assets.lib.getTileRandom("grass"));
					if( Std.random(100)<25 )
						ground.add(x-1,y-1, Assets.lib.getTileRandom("grassDetail"));
				}

			}
		// ground.filter = new h2d.filter.DropShadow(0.5,M.PI*0.5, 0x474A1C,1);
		// ground.filters.push( new h2d.filter.DropShadow(0.5,M.PI*0.5, 0x474A1C,1) );
		// ground.filters.push( new h2d.filter.DropShadow(0.5,M.PI*0.5, 0x996D51,1) );

		for(pt in spots.get("house")) {
			if( !hasSpot("house", pt.cx, pt.cy-1) && !hasSpot("house", pt.cx-1, pt.cy) ) {
				shadows.add(pt.cx*Const.GRID, pt.cy*Const.GRID, Assets.lib.getTileRandom("shadow2x2"));
				new Scenery("house2x2", false, (pt.cx+1)*Const.GRID, (pt.cy+1)*Const.GRID);
				addColl(pt.cx, pt.cy, 2,2);
			}
		}

		//#if !debug
		var treeSpots = new Map();
		for(pt in spots.get("tree"))
			if( !treeSpots.exists(coordId(pt.cx,pt.cy-1)) && !treeSpots.exists(coordId(pt.cx-1,pt.cy)) ) {
				var e = new Scenery("tree", true, (pt.cx+0.5)*Const.GRID+rnd(0,5,true), (pt.cy+0.5)*Const.GRID+rnd(0,5,true));
				e.partId = "leaves";
				e.solid = Std.random(100)<60;
				e.burnable = false;
				treeSpots.set(coordId(pt.cx,pt.cy),true);
			}
		//#end

		// creep.filter = new h2d.filter.Glow(0xC27A89,0.7, 1,1,1);


		#if debug
		// Collisions
		//for(cx in 0...wid)
			//for(cy in 0...wid)
				//if( hasColl(cx,cy) )
					//fronts.add(cx*Const.GRID, cy*Const.GRID, Assets.lib.getTile("collision"));
		#end
	}

	public inline function coordId(cx, cy) return cx+cy*hei;

	public inline function hasColl(cx,cy) {
		return cx<0 || cy<0 || cx>=wid || cy>=hei ? true : colMap[cx][cy];
	}

	function addColl(cx,cy,?w=1,?h=1) {
		for(x in cx...cx+w)
		for(y in cy...cy+h)
			colMap[x][y] = true;
	}

	public function addCreep(cx,cy, ?center=false) {
		if( !hasCreep(cx,cy) ) {
			creepMap.set(cx+cy*wid, true);
			var t = Assets.lib.getTileRandom(center ? "creepPop" : "creep");
			creep.add( Std.int((cx+0.5)*Const.GRID-t.width*0.5), Std.int((cy+0.5)*Const.GRID-t.height*0.5), t);
			creep.invalidate();
		}
	}

	public inline function hasCreep(cx,cy) {
		return creepMap.get(cx+cy*wid)==true;
	}

	public function addCreepArea(cx,cy,r) {
		for(x in cx-r...cx+r+1)
			for(y in cy-r...cy+r+1)
				if( dn.M.distSqr(cx,cy,x,y)<=r*r )
					addCreep(x,y, x==cx && y==cy);
	}


	inline function getDirtGroup() {
		var limit = 500;
		if( dirtGroups[curDirtGroup].count()>=limit ) {
			curDirtGroup++;

			if( curDirtGroup>=dirtGroups.length )
				curDirtGroup = 0;

			if( dirtGroups[curDirtGroup].count()>=limit )
				dirtGroups[curDirtGroup].clear();
		}
		return dirtGroups[curDirtGroup];
	}


	public inline function addDirt(x:Float, y:Float, k:String, ?a=1.0) {
		var t = Assets.lib.getTileRandom(k);
		var tg = getDirtGroup();
		tg.addColor( Std.int(x-t.width*0.5), Std.int(y-t.height*0.5), 1,1,1,a, t);
		tg.invalidate();
	}

	public inline function addBulletHole(x:Float, y:Float) {
		addDirt(x,y, "bulletHole", rnd(0.2,0.6));
	}


	public inline function getSpots(k) {
		return spots.exists(k) ? spots.get(k) : [];
	}
	public inline function addSpot(k,x,y) {
		if( !spots.exists(k) )
			spots.set(k, []);
		spots.get(k).push({cx:x, cy:y});
	}

	public function hasSpot(k,cx,cy) {
		for(pt in spots.get(k))
			if( pt.cx==cx && pt.cy==cy )
				return true;
		return false;
	}


	override public function update() {
		super.update();
	}
}