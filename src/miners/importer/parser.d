// Copyright © 2011, Jakob Bornecrantz.  All rights reserved.
// See copyright notice in src/charge/charge.d (GPLv2 only).
module miners.importer.parser;

import lib.xml.xml : DomParser, Element, Handle;
import std.string : find, format;
import std.conv : toUshort;
import std.regexp : RegExp;
import charge.util.html;
import miners.types;
import miners.importer.network;


/**
 * Parse the source of the classic list page from
 * minecraft.net and retrive a list of servers.
 *
 * Will only work if you where logged in when retriving the list.
 *
 * Will throw various exceptions if the page is malformed.
 */
ClassicServerInfo[] getClassicServerList(in char[] text)
{
	// Only parse the interesting parts.
	const startText = "<table";
	const endText = "</table>";
	auto start = cast(size_t)find(text, startText);
	auto end = cast(size_t)find(text, endText) + endText.length;

	// Did we find the start? (-1 = size_t.max)
	if (start == size_t.max)
		throw new Exception("Could not find start of table");
	// Did we find the end?
	if (end == size_t.max)
		throw new Exception("Could not find end of table");

	// Crop the text.
	text = text[start .. end];

	// Remove any nasty characters the parser might freak out over.
	auto temp = new char[text.length + 4];
	int i, k;
	while(k < text.length) {
		auto c = text[k++];
		if (c < 32)
			continue;
		if (c != '&') {
			temp[i++] = c;
			continue;
		}

		// Escape some weird stuff.
		auto endEsc = cast(int)find(text[k .. $], ";");
		if (endEsc < 0)
			throw new Exception("Invalid '&' escape in html");

		// Include the '&' and ';' char
		endEsc = k + endEsc + 1;
		k -= 1;

		// Get and set the replacement string.
		auto replace = htmlToXmlEscape(text[k .. endEsc]);
		temp[i .. i + replace.length] = replace[0 .. $];

		// Fixup the pointers.
		k = endEsc;
		i += replace.length;
	}
	text = temp[0 .. i];

	// The parser will crap out eventually since the page is not
	// valid xml, but we get the parts we are interested in.
	auto p = new DomParser();
	scope(exit)
		delete p;
	auto root = p.parseData(text);

	// Sanity checking.
	if (root is null)
		throw new Exception("Failed to parse server list page");

	// More sanity checking.
	if (root.value != "table")
		throw new Exception("Root element is not a table");

	// Yet more sanity checking.
	auto f = root.first("tbody");
	if (null is f)
		throw new Exception("Could not find table body");

	// Loop over all the rows and get the name and url.
	ClassicServerInfo[] list;
	foreach(Element e; f) {
		// Just in case.
		if (e.value != "tr")
			continue;

		auto tr = Handle(e);
		auto ha = tr.first("td").first("a");
		auto a = ha.element();
		auto text = ha.first().text();

		if (a is null || text is null || text.value is null)
			continue;

		// Lets strip the first part of the url.
		const strip = "/classic/play/";
		auto url = a.attribute("href");

		if (url[0 .. strip.length] != strip)
			throw new Exception("Server url is malformed (start)");

		if (url.length <= strip.length + 1)
			throw new Exception("Server url is malformed (length)");

		// Fill in the info that we got.
		auto csi = new ClassicServerInfo();
		csi.webId = url[strip.length .. $].dup;
		csi.webName = text.value;

		list ~= csi;
	}

	return list;
}

/**
 * Parse the source of the classic list page from
 * classicube.net and retrive a list of servers.
 */
ClassicServerInfo[] getClassiCubeServerList(in char[] text)
{
	auto tableStart = find(text, `<table id="servers">`);
	auto tableEnd = find(text[tableStart .. $], `</table>`);

	text = text[tableStart .. tableStart + tableEnd];

	auto mcUrl = RegExp(mcUrlStr);

	ClassicServerInfo[] list;
	do {
		auto trStart = find(text, `<tr class="server">`);
		if (trStart == size_t.max)
			break;
		auto trEnd = find(text[trStart .. $], `</tr>`);

		auto server = text[trStart .. trStart + trEnd];

		auto nameStart = find(server, `<a href="/server/play/`);
		auto nameEnd = find(server[nameStart .. $], `">`);

		nameStart = nameStart + nameEnd + 2;
		nameEnd = find(server[nameStart .. $], `</a>`);

		auto name = server[nameStart .. nameStart + nameEnd];

		auto urlStart = find(server, `mc://`);
		auto urlEnd = find(server[urlStart .. $], `">`);

		auto url = server[urlStart .. urlStart + urlEnd];

		auto csi = new ClassicServerInfo();

		auto r = mcUrl.exec(url);
		csi.hostname = r[1];

		if (r[5].length > 0)
			csi.username = r[5];
		if (r[7].length > 0)
			csi.verificationKey = r[7];

		try {
			if (r[3].length > 0)
				csi.port = cast(ushort)toUshort(r[3]);
		} catch (Exception e) {
		}

		csi.webName = name;

		list ~= csi;

		text = text[trEnd .. $];
	} while (true);

	return list;
}

/**
 * Parse the source of the classic play page from minecraft.net and
 * retrive the list of properties needed to connect to the server.
 * The given ClassicServerInfo is both input and output.
 *
 * Will only work if you where logged in when retriving the page.
 *
 * Will throw various exceptions if the page is malformed.
 */
void getClassicServerInfo(ClassicServerInfo csi, in char[] text)
{
	// Only parse the interesting parts.
	const startText = "<applet";
	const endText = "</applet>";
	auto start = cast(size_t)find(text, startText);
	auto end = cast(size_t)find(text, endText) + endText.length;

	// Did we find the start? (-1 = size_t.max)
	if (start == size_t.max)
		throw new Exception("Could not find start of applet tag");
	// Did we find the end?
	if (end == size_t.max)
		throw new Exception("Could not find end of applet tag");

	// Crop the text.
	text = text[start .. end];

	// Fix the html to be valid xml. Skip the first found `">`.
	auto pos = cast(size_t)find(text, `">`);
	if (pos == size_t.max)
		throw new Exception("Something went really bad");
	auto temp = text[pos+1 .. $];

	// Loop over and fix all the problem points.
	while((pos = cast(size_t)find(temp, `">`)) != size_t.max) {
		temp[pos .. pos + 3] = `"/>`;
		temp = temp[pos+3 .. $];
	}

	// The parser will crap out eventually since the page is not
	// valid xml, but we get the parts we are interested in.
	auto p = new DomParser();
	scope(exit)
		delete p;
	auto root = p.parseData(text);

	// Sanity checking.
	if (root is null)
		throw new Exception("Failed to parse server list page");

	// More sanity checking.
	if (root.value != "applet")
		throw new Exception("Root element is not a table");

	foreach(Element e; root) {
		// Just in case.
		if (e.value != "param")
			continue;

		auto name = e.attribute("name");
		auto value = e.attribute("value");

		// Just in case.
		if (name is null || value is null)
			continue;

		switch(name) {
		case "username":
			csi.username = value;
			break;
		case "server":
			csi.hostname = value;
			break;
		case "port":
			csi.port = toUshort(value);
			break;
		case "mppass":
			csi.verificationKey = value;
			break;
		default:
			break;
		}
	}
}
