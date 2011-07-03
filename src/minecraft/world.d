// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.world;

import std.math;

import charge.charge;

import minecraft.options;
import minecraft.terrain.data;
import minecraft.terrain.beta;
import minecraft.terrain.common;
import minecraft.importer.info;

abstract class World : public GameWorld
{
public:
	Options opts; /** Shared with other worlds */
	Terrain t;
	Point3d spawn;

private:
	mixin SysLogging;

public:
	this(Options opts)
	{
		super();
		this.opts = opts;
	}

	~this()
	{
		delete t;
	}

	void switchRenderer()
	{
		opts.changeRenderer();
		t.setBuildType(opts.rendererBuildType);
	}

protected:

}

class BetaWorld : public World
{
public:
	BetaTerrain bt;
	char[] dir;

public:
	this(MinecraftLevelInfo *info, Options opts)
	{
		this.spawn = info ? info.spawn : Point3d(0, 64, 0);
		this.dir = info ? info.dir : null;
		super(opts);

		bt = new BetaTerrain(this, dir, opts);
		t = bt;
		t.buildIndexed = opts.rendererBuildIndexed;
		t.setBuildType(opts.rendererBuildType);

		// Find the actuall spawn height
		auto x = cast(int)spawn.x;
		auto y = cast(int)spawn.y;
		auto z = cast(int)spawn.z;
		auto xPos = x < 0 ? (x - 15) / 16 : x / 16;
		auto zPos = z < 0 ? (z - 15) / 16 : z / 16;

		bt.setCenter(xPos, zPos);
		bt.loadChunk(xPos, zPos);

		auto p = bt.getPointerY(x, z);
		for (int i = y; i < 128; i++) {
			if (tile[p[i]].filled)
				continue;
			if (tile[p[i+1]].filled)
				continue;

			spawn.y = i;
			break;
		}
	}
}
