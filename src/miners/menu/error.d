// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module miners.menu.error;

import std.string;

import charge.charge;
import charge.game.gui.layout;
import charge.game.gui.textbased;

import miners.menu.base;
import miners.menu.runner;


class ErrorMenu : public MenuBase
{
private:
	Text te[];

	const char[] header = `Charged Miners`;

public:
	this(MenuRunner mr, char[][] errorTexts, bool panic)
	{
		auto b = panic ? Buttons.QUIT : Buttons.OK;
		super(mr, header, b);

		auto vc = new VerticalContainer(null, 0, 0, 300, 0, 8);
		replacePlane(vc);

		te.length = errorTexts.length;
		foreach(uint i, t; errorTexts) {
			te[i] = new Text(this, 0, 0, t);
		}

		repack();
	}
}