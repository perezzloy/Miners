// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module minecraft.terrain.common;

import std.math;

import charge.charge;

import minecraft.types;
import minecraft.options;
import minecraft.gfx.vbo;

class Terrain : public GameActor
{
private:
	mixin SysLogging;

protected:
	Options opts;
	int view_radii;
	TerrainBuildTypes currentBuildType;

public:
	ChunkVBOGroupRigidMesh cvgrm;
	ChunkVBOGroupCompactMesh cvgcm;
	bool buildIndexed; // The renderer supports array textures.

public:
	this(GameWorld w, Options opts)
	{
		super(w);
		this.opts = opts;

		view_radii = 250 / 16 + 1;

		// Setup the groups
		buildIndexed = opts.rendererBuildIndexed;
		doBuildTypeChange(opts.rendererBuildType);
	}

	~this() {
		delete cvgrm;
		delete cvgcm;
	}

	abstract void setCenter(int xNew, int zNew);
	abstract void setViewRadii(int radii);
	abstract void setBuildType(TerrainBuildTypes type);
	abstract bool buildOne();

protected:
	void doBuildTypeChange(TerrainBuildTypes type)
	{
		this.currentBuildType = type;
		delete cvgrm;
		delete cvgcm;

		cvgrm = null; cvgcm = null;

		switch(type) {
		case TerrainBuildTypes.RigidMesh:
			cvgrm = new ChunkVBOGroupRigidMesh(w.gfx);
			cvgrm.getMaterial()["tex"] = opts.terrainTexture;
			cvgrm.getMaterial()["fake"] = true;
			break;
		case TerrainBuildTypes.CompactMesh:
			cvgcm = new ChunkVBOGroupCompactMesh(w.gfx);
			cvgcm.getMaterial()["tex"] =
				buildIndexed ? opts.terrainTextureArray : opts.terrainTexture;
			cvgcm.getMaterial()["fake"] = true;
			// No need to setup material handled by the renderer
			break;
		default:
			assert(false);
		}
	}
}
