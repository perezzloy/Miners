// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.classic.world;

import charge.charge;

import minecraft.world;
import minecraft.options;
import minecraft.terrain.finite;
import minecraft.importer.classic;
import minecraft.importer.converter;


/**
 * A world containing a classic level.
 */
class ClassicWorld : public World
{
private:
	mixin SysLogging;

	FiniteTerrain ft;

public:
	this(Options opts)
	{
		this.spawn = Point3d(64, 67, 64);

		super(opts);

		// Create initial terrain
		newLevel(128, 128, 128);

		// Set the level with some sort of valid data
		generateLevel(ft);
	}

	this(Options opts, char[] filename)
	{
		this.spawn = Point3d(64, 67, 64);

		super(opts);

		uint x, y, z;
		auto b = loadClassicTerrain(filename, x, y, z);
		if (b is null)
			throw new Exception("Failed to load level");
		scope (exit)
			std.c.stdlib.free(b.ptr);

		// Setup the terrain from the data.
		newLevelFromClassic(x, y, z, b[0 .. x * y * z]);
	}

	~this()
	{
		// Incase super class decieded to deleted t
		if (t is null)
			ft = null;

		delete ft;
		t = ft = null;
	}

	/**
	 * Change the current level
	 */
	void newLevel(uint x, uint y, uint z)
	{
		delete ft;
		t = ft = null;

		t = ft = new FiniteTerrain(this, opts, x, y, z);
	}

	/**
	 * Replace the current level with one from classic data.
	 *
	 * Flips and convert the data.
	 */
	void newLevelFromClassic(uint xSize, uint ySize, uint zSize, ubyte[] data)
	{
		ubyte from, block, meta;

		newLevel(xSize, ySize, zSize);

		// Get the pointer directly to the data
		auto p = ft.getBlockPointer(0, 0, 0);
		auto pm = ft.getMetaPointer(0, 0, 0);

		// Flip & convert the world
		for (int z; z < zSize; z++) {
			for (int x; x < xSize; x++) {
				for (int y; y < ySize; y++) {
					from = data[(zSize*y + z) * xSize + x];
					convertClassicToBeta(from, block, meta);
					*p = block;
					*pm |= meta << (4 * (y % 2));
					//ft.setMeta(x, y, z, meta);
					p++;
					pm += y % 2;
				}
				// If height is uneaven we need to increment this.
				pm += ySize % 2;
			}
		}
	}

	/**
	 * "Generate" a level.
	 */
	void generateLevel(FiniteTerrain ct)
	{
		for (int x; x < ct.xSize; x++) {
			for (int z; z < ct.zSize; z++) {
				ct[x, 0, z] =  7;
				for (int y = 1; y < ct.ySize; y++) {
					if (y < 64)
						ct[x, y, z] = 1;
					else if (y == 64)
						ct[x, y, z] = 3;
					else if (y == 65)
						ct[x, y, z] = 3;
					else if (y == 66)
						ct[x, y, z] = 2;
					else
						ct[x, y, z] = 0;
				}
			}
		}
	}
}