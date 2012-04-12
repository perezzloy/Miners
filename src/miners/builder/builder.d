// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module miners.builder.builder;

import charge.charge;

import miners.defines;
import miners.gfx.vbo;

import miners.builder.types;
import miners.builder.packers;
import miners.builder.functions;
import miners.builder.workspace;


/**
 * Builds a mesh packed with p from data in data.
 */
void doBuildMesh(WorkspaceData *data, Packer *p)
{
	for (int x; x < BuildWidth; x++) {
		for (int y; y < BuildHeight; y++) {
			for (int z; z < BuildDepth; z++) {
				ubyte type = data.get(x, y, z);
				buildArray[type](p, x, y, z, type, data);
			}
		}
	}
}

/**
 * Update a RigidMesh from a WorkspaceData.
 */
ChunkVBORigidMesh updateRigidMesh(ChunkVBORigidMesh vbo,
				  WorkspaceData *data,
				  int xPos, int yPos, int zPos,
				  int xOffArg, int yOffArg, int zOffArg)
{
/*
	XXX Disabled for now.
	auto mb = new RigidMeshBuilder(128*1024, 0, RigidMesh.Types.QUADS);
	auto prm = PackerRigidMesh.cAlloc(128*1024);
	scope(exit) {
		prm.cFree();
		delete mb;
	}

	prm.ctor(mb, xOffArg, yOffArg, zOffArg);

	doBuildMesh(data, &prm.base);

	// C memory freed above with scope(exit)
	if (vbo is null)
		return ChunkVBORigidMesh(mb, xPos, yPos, zPos);

	vbo.update(mb);
	return vbo;
*/
	return null;
}

PackerCompact *cached;

static this() {
	cached = PackerCompact.cAlloc(128 * 1024);
}

static void unleakMemory()
{
	cached.cFree();
	cached = null;
}

static ~this() {
	if (cached !is null)
		cached.cFree();
}

/**
 * Build and update a CompactMesh from a WorkspaceData.
 */
ChunkVBOCompactMesh updateCompactMesh(ChunkVBOCompactMesh vbo, bool indexed,
				      WorkspaceData *data,
				      int xPos, int yPos, int zPos,
				      int xOffArg, int yOffArg, int zOffArg)
{
	auto pc = cached;

	pc.ctor(xOffArg, yOffArg, zOffArg, indexed);

	doBuildMesh(data, &pc.base);

	auto verts = pc.getVerts();
	if (verts.length == 0)
		return null;

	if (vbo is null)
		return ChunkVBOCompactMesh(verts, xPos, yPos, zPos);

	vbo.update(verts);
	return vbo;
}


/*
 *
 * Offset helper functions
 *
 */


ChunkVBORigidMesh updateRigidMesh(ChunkVBORigidMesh vbo,
				  WorkspaceData *data,
				  int xPos, int yPos, int zPos)
{
	int xOff = xPos * BuildWidth;
	int yOff = yPos * BuildHeight;
	int zOff = zPos * BuildDepth;

	return updateRigidMesh(vbo, data, xPos, yPos, zPos, xOff, yOff, zOff);
}

ChunkVBOCompactMesh updateCompactMesh(ChunkVBOCompactMesh vbo, bool indexed,
				      WorkspaceData *data,
				      int xPos, int yPos, int zPos)
{
	int xOff = xPos * BuildWidth;
	int yOff = yPos * BuildHeight;
	int zOff = zPos * BuildDepth;

	return updateCompactMesh(vbo, indexed, data, xPos, yPos, zPos, xOff, yOff, zOff);
}
