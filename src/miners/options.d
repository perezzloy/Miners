// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module miners.options;

import lib.sdl.keysym;

import charge.util.signal;
import charge.charge;

import miners.types;


/**
 * Holds settings and common resources that are shared between
 * multiple runners, worlds & actors.
 */
class Options
{
public:
	/*
	 *
	 * Options
	 *
	 */


	Option!(bool) aa; /**< should anti-aliasing be used */
	Option!(bool) fog; /**< should fog be drawn */
	Option!(bool) hideUi; /**< hide the user interface */
	Option!(bool) shadow; /**< should advanced shadowing be used */
	Option!(bool) showDebug; /**< should debug info be shown */
	Option!(bool) useCmdPrefix; /**< should we use the command prefix */
	Option!(double) viewDistance; /**< the view distance */

	const string aaName = "mc.aa";
	const string fogName = "mc.fog";
	const string shadowName = "mc.shadow";
	const string useCmdPrefixName = "mc.useCmdPrefix";
	const string viewDistanceName = "mc.viewDistance";

	const bool aaDefault = true;
	const bool fogDefault = true;
	const bool shadowDefault = true;
	const bool useCmdPrefixDefault = true;
	const double viewDistanceDefault = 256;


	/*
	 *
	 * Key bindings.
	 *
	 */


	const string[21] keyNames = [
		"mc.keyForward",
		"mc.keyBackward",
		"mc.keyLeft",
		"mc.keyRight",
		"mc.keyCameraUp",
		"mc.keyCameraDown",
		"mc.keyJump",
		"mc.keyCrouch",
		"mc.keyRun",
		"mc.keyFlightMode",
		"mc.keyChat",
		"mc.keySelector",
		"mc.keySlot0",
		"mc.keySlot1",
		"mc.keySlot2",
		"mc.keySlot3",
		"mc.keySlot4",
		"mc.keySlot5",
		"mc.keySlot6",
		"mc.keySlot7",
		"mc.keySlot8",
	];

	const int[21] keyDefaults = [
		SDLK_w,
		SDLK_s,
		SDLK_a,
		SDLK_d,
		SDLK_q,
		SDLK_e,
		SDLK_SPACE,
		SDLK_LCTRL,
		SDLK_LSHIFT,
		SDLK_z,
		SDLK_t,
		SDLK_b,
		SDLK_1, // mc.keySlot1
		SDLK_2,
		SDLK_3,
		SDLK_4,
		SDLK_5,
		SDLK_6,
		SDLK_7,
		SDLK_8,
		SDLK_9,
	];

	static assert(keyNames.length == keyDefaults.length);
	static assert(keyArray.length == keyDefaults.length);

	union {
		struct {
			int keyForward;
			int keyBackward;
			int keyLeft;
			int keyRight;
			int keyCameraUp;
			int keyCameraDown;
			int keyJump;
			int keyCrouch;
			int keyRun;
			int keyFlightMode;
			int keyChat;
			int keySelector;
			int keySlot0;
			int keySlot1;
			int keySlot2;
			int keySlot3;
			int keySlot4;
			int keySlot5;
			int keySlot6;
			int keySlot7;
			int keySlot8;
		};
		int[21] keyArray;
	}
	Signal!() keyBindings;


	/*
	 *
	 * Shared gfx resources.
	 *
	 */


	GfxTexture blackTexture;
	GfxTexture whiteTexture;

	GfxSimpleSkeleton.VBO playerSkeleton;
	alias PlayerModelData.bones playerBones;

	Option!(GfxTexture) dirt;
	Option!(GfxTexture) terrain;
	Option!(GfxTextureArray) terrainArray;
	Option!(GfxTexture) classicTerrain;
	Option!(GfxTextureArray) classicTerrainArray;

	GfxTexture[50] classicSides;


	/*
	 *
	 * Renderer settings.
	 *
	 */


	bool rendererBuildIndexed; /**< support array textures */
	char[] rendererString; /**< readable string for current renderer */
	TerrainBuildTypes rendererBuildType;
	Signal!(TerrainBuildTypes, char[]) renderer;


	/*
	 *
	 * Triggers.
	 *
	 */


	/**
	 * Change the terrain texture to this file.
	 */
	bool delegate(char[] file) changeTexture;


	/**
	 * Trigger a change of the renderer, return a human readable string.
	 */
	void delegate() changeRenderer;


public:
	this()
	{
		playerSkeleton = GfxSimpleSkeleton.VBO(PlayerModelData.verts);
		blackTexture = GfxColorTexture(Color4f.Black);
		whiteTexture = GfxColorTexture(Color4f.White);
	}

	~this()
	{
		sysReference(&playerSkeleton, null);
		sysReference(&blackTexture, null);
		sysReference(&whiteTexture, null);

		terrain.destruct();
		renderer.destruct();
		shadow.destruct();
		showDebug.destruct();
		viewDistance.destruct();
		useCmdPrefix.destruct();

		dirt.destruct();
		terrain.destruct();
		terrainArray.destruct();
		classicTerrain.destruct();
		classicTerrainArray.destruct();

		foreach (ref tex; classicSides) {
			sysReference(&tex, null);
		}
	}

	void setRenderer(TerrainBuildTypes bt, char[] s)
	{
		rendererString = s;
		rendererBuildType = bt;
		renderer(bt, s);
	}
}


/**
 * Single option.
 */
private struct Option(T)
{
	Signal!(T) signal;
	T value;

	T opCall()
	{
		return value;
	}

	bool opIn(T value)
	{
		return this.value is value;
	}

	void opAssign(T t)
	{
		static if (is(T : GfxTexture) || is(T : GfxTextureArray))
			sysReference(&value, t);
		else
			value = t;
		signal(t);
	}

	void opCatAssign(signal.Slot slot)
	{
		signal.opCatAssign(slot);
	}

	void opSubAssign(signal.Slot slot)
	{
		signal.opSubAssign(slot);
	}

	static if (is(T : bool)) {
		void toggle()
		{
			value = !value;
			signal(value);
		}
	}

	void destruct()
	{
		signal.destruct();

		static if (is(T : GfxTexture) || is(T : GfxTextureArray))
			sysReference(&value, null);
	}
}


class PlayerModelData
{
	const float sz = 0.215 / 2;
	const float s_2 = sz*2;
	const float s_3 = sz*3;
	const float s_4 = sz*4;
	const float s_5 = sz*5;
	const float s_6 = sz*6;

	const GfxSimpleSkeleton.Vertex verts[] = [
		// HEAD
		// X-
		{[-s_2,   0, -s_2], [ 0,  1], [-1,  0,  0], 0},
		{[-s_2,   0,  s_2], [ 1,  1], [-1,  0,  0], 0},
		{[-s_2, s_4,  s_2], [ 1,  0], [-1,  0,  0], 0},
		{[-s_2, s_4, -s_2], [ 0,  0], [-1,  0,  0], 0},
		// X+
		{[ s_2,   0,  s_2], [ 0,  1], [ 1,  0,  0], 0},
		{[ s_2,   0, -s_2], [ 1,  1], [ 1,  0,  0], 0},
		{[ s_2, s_4, -s_2], [ 1,  0], [ 1,  0,  0], 0},
		{[ s_2, s_4,  s_2], [ 0,  0], [ 1,  0,  0], 0},
		// Y- Bottom
		{[ s_2,   0,  s_2], [ 0,  1], [ 0, -1,  0], 0},
		{[-s_2,   0,  s_2], [ 1,  1], [ 0, -1,  0], 0},
		{[-s_2,   0, -s_2], [ 1,  0], [ 0, -1,  0], 0},
		{[ s_2,   0, -s_2], [ 0,  0], [ 0, -1,  0], 0},
		// Y+ Top
		{[-s_2, s_4,  s_2], [ 0,  1], [ 0,  1,  0], 0},
		{[ s_2, s_4,  s_2], [ 1,  1], [ 0,  1,  0], 0},
		{[ s_2, s_4, -s_2], [ 1,  0], [ 0,  1,  0], 0},
		{[-s_2, s_4, -s_2], [ 0,  0], [ 0,  1,  0], 0},
		// Z- Front
		{[ s_2,   0, -s_2], [ 0,  1], [ 0,  0, -1], 0},
		{[-s_2,   0, -s_2], [ 1,  1], [ 0,  0, -1], 0},
		{[-s_2, s_4, -s_2], [ 1,  0], [ 0,  0, -1], 0},
		{[ s_2, s_4, -s_2], [ 0,  0], [ 0,  0, -1], 0},
		// Z+ Back
		{[-s_2,   0,  s_2], [ 0,  1], [ 0,  0,  1], 0},
		{[ s_2,   0,  s_2], [ 1,  1], [ 0,  0,  1], 0},
		{[ s_2, s_4,  s_2], [ 1,  0], [ 0,  0,  1], 0},
		{[-s_2, s_4,  s_2], [ 0,  0], [ 0,  0,  1], 0},

		// Body
		// X-
		{[-s_2, -s_3, -sz], [ 0,  1], [-1,  0,  0], 1},
		{[-s_2, -s_3,  sz], [ 1,  1], [-1,  0,  0], 1},
		{[-s_2,  s_3,  sz], [ 1,  0], [-1,  0,  0], 1},
		{[-s_2,  s_3, -sz], [ 0,  0], [-1,  0,  0], 1},
		// X+
		{[ s_2, -s_3,  sz], [ 0,  1], [ 1,  0,  0], 1},
		{[ s_2, -s_3, -sz], [ 1,  1], [ 1,  0,  0], 1},
		{[ s_2,  s_3, -sz], [ 1,  0], [ 1,  0,  0], 1},
		{[ s_2,  s_3,  sz], [ 0,  0], [ 1,  0,  0], 1},
		// Y- Bottom
		{[ s_2, -s_3,  sz], [ 0,  1], [ 0, -1,  0], 1},
		{[-s_2, -s_3,  sz], [ 1,  1], [ 0, -1,  0], 1},
		{[-s_2, -s_3, -sz], [ 1,  0], [ 0, -1,  0], 1},
		{[ s_2, -s_3, -sz], [ 0,  0], [ 0, -1,  0], 1},
		// Y+ Top
		{[-s_2,  s_3,  sz], [ 0,  1], [ 0,  1,  0], 1},
		{[ s_2,  s_3,  sz], [ 1,  1], [ 0,  1,  0], 1},
		{[ s_2,  s_3, -sz], [ 1,  0], [ 0,  1,  0], 1},
		{[-s_2,  s_3, -sz], [ 0,  0], [ 0,  1,  0], 1},
		// Z- Front
		{[ s_2, -s_3, -sz], [ 0,  1], [ 0,  0, -1], 1},
		{[-s_2, -s_3, -sz], [ 1,  1], [ 0,  0, -1], 1},
		{[-s_2,  s_3, -sz], [ 1,  0], [ 0,  0, -1], 1},
		{[ s_2,  s_3, -sz], [ 0,  0], [ 0,  0, -1], 1},
		// Z+ Back
		{[-s_2, -s_3,  sz], [ 0,  1], [ 0,  0,  1], 1},
		{[ s_2, -s_3,  sz], [ 1,  1], [ 0,  0,  1], 1},
		{[ s_2,  s_3,  sz], [ 1,  0], [ 0,  0,  1], 1},
		{[-s_2,  s_3,  sz], [ 0,  0], [ 0,  0,  1], 1},

		// Arm 1
		// X-
		{[-sz, -s_5, -sz], [ 0,  1], [-1,  0,  0], 2},
		{[-sz, -s_5,  sz], [ 1,  1], [-1,  0,  0], 2},
		{[-sz,   sz,  sz], [ 1,  0], [-1,  0,  0], 2},
		{[-sz,   sz, -sz], [ 0,  0], [-1,  0,  0], 2},
		// X+
		{[ sz, -s_5,  sz], [ 0,  1], [ 1,  0,  0], 2},
		{[ sz, -s_5, -sz], [ 1,  1], [ 1,  0,  0], 2},
		{[ sz,   sz, -sz], [ 1,  0], [ 1,  0,  0], 2},
		{[ sz,   sz,  sz], [ 0,  0], [ 1,  0,  0], 2},
		// Y- Bottom
		{[ sz, -s_5,  sz], [ 0,  1], [ 0, -1,  0], 2},
		{[-sz, -s_5,  sz], [ 1,  1], [ 0, -1,  0], 2},
		{[-sz, -s_5, -sz], [ 1,  0], [ 0, -1,  0], 2},
		{[ sz, -s_5, -sz], [ 0,  0], [ 0, -1,  0], 2},
		// Y+ Top
		{[-sz,   sz,  sz], [ 0,  1], [ 0,  1,  0], 2},
		{[ sz,   sz,  sz], [ 1,  1], [ 0,  1,  0], 2},
		{[ sz,   sz, -sz], [ 1,  0], [ 0,  1,  0], 2},
		{[-sz,   sz, -sz], [ 0,  0], [ 0,  1,  0], 2},
		// Z- Front
		{[ sz, -s_5, -sz], [ 0,  1], [ 0,  0, -1], 2},
		{[-sz, -s_5, -sz], [ 1,  1], [ 0,  0, -1], 2},
		{[-sz,   sz, -sz], [ 1,  0], [ 0,  0, -1], 2},
		{[ sz,   sz, -sz], [ 0,  0], [ 0,  0, -1], 2},
		// Z+ Back
		{[-sz, -s_5,  sz], [ 0,  1], [ 0,  0,  1], 2},
		{[ sz, -s_5,  sz], [ 1,  1], [ 0,  0,  1], 2},
		{[ sz,   sz,  sz], [ 1,  0], [ 0,  0,  1], 2},
		{[-sz,   sz,  sz], [ 0,  0], [ 0,  0,  1], 2},

		// Arm 2
		// X-
		{[-sz, -s_5, -sz], [ 0,  1], [-1,  0,  0], 3},
		{[-sz, -s_5,  sz], [ 1,  1], [-1,  0,  0], 3},
		{[-sz,   sz,  sz], [ 1,  0], [-1,  0,  0], 3},
		{[-sz,   sz, -sz], [ 0,  0], [-1,  0,  0], 3},
		// X+
		{[ sz, -s_5,  sz], [ 0,  1], [ 1,  0,  0], 3},
		{[ sz, -s_5, -sz], [ 1,  1], [ 1,  0,  0], 3},
		{[ sz,   sz, -sz], [ 1,  0], [ 1,  0,  0], 3},
		{[ sz,   sz,  sz], [ 0,  0], [ 1,  0,  0], 3},
		// Y- Bottom
		{[ sz, -s_5,  sz], [ 0,  1], [ 0, -1,  0], 3},
		{[-sz, -s_5,  sz], [ 1,  1], [ 0, -1,  0], 3},
		{[-sz, -s_5, -sz], [ 1,  0], [ 0, -1,  0], 3},
		{[ sz, -s_5, -sz], [ 0,  0], [ 0, -1,  0], 3},
		// Y+ Top
		{[-sz,   sz,  sz], [ 0,  1], [ 0,  1,  0], 3},
		{[ sz,   sz,  sz], [ 1,  1], [ 0,  1,  0], 3},
		{[ sz,   sz, -sz], [ 1,  0], [ 0,  1,  0], 3},
		{[-sz,   sz, -sz], [ 0,  0], [ 0,  1,  0], 3},
		// Z- Front
		{[ sz, -s_5, -sz], [ 0,  1], [ 0,  0, -1], 3},
		{[-sz, -s_5, -sz], [ 1,  1], [ 0,  0, -1], 3},
		{[-sz,   sz, -sz], [ 1,  0], [ 0,  0, -1], 3},
		{[ sz,   sz, -sz], [ 0,  0], [ 0,  0, -1], 3},
		// Z+ Back
		{[-sz, -s_5,  sz], [ 0,  1], [ 0,  0,  1], 3},
		{[ sz, -s_5,  sz], [ 1,  1], [ 0,  0,  1], 3},
		{[ sz,   sz,  sz], [ 1,  0], [ 0,  0,  1], 3},
		{[-sz,   sz,  sz], [ 0,  0], [ 0,  0,  1], 3},

		// Leg 1
		// X-
		{[-sz, -s_6, -sz], [ 0,  1], [-1,  0,  0], 4},
		{[-sz, -s_6,  sz], [ 1,  1], [-1,  0,  0], 4},
		{[-sz,    0,  sz], [ 1,  0], [-1,  0,  0], 4},
		{[-sz,    0, -sz], [ 0,  0], [-1,  0,  0], 4},
		// X+
		{[ sz, -s_6,  sz], [ 0,  1], [ 1,  0,  0], 4},
		{[ sz, -s_6, -sz], [ 1,  1], [ 1,  0,  0], 4},
		{[ sz,    0, -sz], [ 1,  0], [ 1,  0,  0], 4},
		{[ sz,    0,  sz], [ 0,  0], [ 1,  0,  0], 4},
		// Y- Bottom
		{[ sz, -s_6,  sz], [ 0,  1], [ 0, -1,  0], 4},
		{[-sz, -s_6,  sz], [ 1,  1], [ 0, -1,  0], 4},
		{[-sz, -s_6, -sz], [ 1,  0], [ 0, -1,  0], 4},
		{[ sz, -s_6, -sz], [ 0,  0], [ 0, -1,  0], 4},
		// Y+ Top
		{[-sz,    0,  sz], [ 0,  1], [ 0,  1,  0], 4},
		{[ sz,    0,  sz], [ 1,  1], [ 0,  1,  0], 4},
		{[ sz,    0, -sz], [ 1,  0], [ 0,  1,  0], 4},
		{[-sz,    0, -sz], [ 0,  0], [ 0,  1,  0], 4},
		// Z- Front
		{[ sz, -s_6, -sz], [ 0,  1], [ 0,  0, -1], 4},
		{[-sz, -s_6, -sz], [ 1,  1], [ 0,  0, -1], 4},
		{[-sz,    0, -sz], [ 1,  0], [ 0,  0, -1], 4},
		{[ sz,    0, -sz], [ 0,  0], [ 0,  0, -1], 4},
		// Z+ Back
		{[-sz, -s_6,  sz], [ 0,  1], [ 0,  0,  1], 4},
		{[ sz, -s_6,  sz], [ 1,  1], [ 0,  0,  1], 4},
		{[ sz,    0,  sz], [ 1,  0], [ 0,  0,  1], 4},
		{[-sz,    0,  sz], [ 0,  0], [ 0,  0,  1], 4},

		// Leg 2
		// X-
		{[-sz, -s_6, -sz], [ 0,  1], [-1,  0,  0], 5},
		{[-sz, -s_6,  sz], [ 1,  1], [-1,  0,  0], 5},
		{[-sz,    0,  sz], [ 1,  0], [-1,  0,  0], 5},
		{[-sz,    0, -sz], [ 0,  0], [-1,  0,  0], 5},
		// X5
		{[ sz, -s_6,  sz], [ 0,  1], [ 1,  0,  0], 5},
		{[ sz, -s_6, -sz], [ 1,  1], [ 1,  0,  0], 5},
		{[ sz,    0, -sz], [ 1,  0], [ 1,  0,  0], 5},
		{[ sz,    0,  sz], [ 0,  0], [ 1,  0,  0], 5},
		// Y- Bottom
		{[ sz, -s_6,  sz], [ 0,  1], [ 0, -1,  0], 5},
		{[-sz, -s_6,  sz], [ 1,  1], [ 0, -1,  0], 5},
		{[-sz, -s_6, -sz], [ 1,  0], [ 0, -1,  0], 5},
		{[ sz, -s_6, -sz], [ 0,  0], [ 0, -1,  0], 5},
		// Y+ Top
		{[-sz,    0,  sz], [ 0,  1], [ 0,  1,  0], 5},
		{[ sz,    0,  sz], [ 1,  1], [ 0,  1,  0], 5},
		{[ sz,    0, -sz], [ 1,  0], [ 0,  1,  0], 5},
		{[-sz,    0, -sz], [ 0,  0], [ 0,  1,  0], 5},
		// Z- Front
		{[ sz, -s_6, -sz], [ 0,  1], [ 0,  0, -1], 5},
		{[-sz, -s_6, -sz], [ 1,  1], [ 0,  0, -1], 5},
		{[-sz,    0, -sz], [ 1,  0], [ 0,  0, -1], 5},
		{[ sz,    0, -sz], [ 0,  0], [ 0,  0, -1], 5},
		// Z+ Back
		{[-sz, -s_6,  sz], [ 0,  1], [ 0,  0,  1], 5},
		{[ sz, -s_6,  sz], [ 1,  1], [ 0,  0,  1], 5},
		{[ sz,    0,  sz], [ 1,  0], [ 0,  0,  1], 5},
		{[-sz,    0,  sz], [ 0,  0], [ 0,  0,  1], 5}
	];

	const charge.gfx.skeleton.Bone bones[] = [
		{Quatd(), Vector3d(   0,   s_6*2, 0), uint.max}, // Head
		{Quatd(), Vector3d(   0, s_6+s_3, 0), uint.max}, // Body
		{Quatd(), Vector3d(-s_3, s_6+s_5, 0), uint.max}, // Arm 1
		{Quatd(), Vector3d( s_3, s_6+s_5, 0), uint.max}, // Arm 2
		{Quatd(), Vector3d( -sz,     s_6, 0), uint.max}, // Leg 1
		{Quatd(), Vector3d(  sz,     s_6, 0), uint.max}, // Leg 2
	];
}
