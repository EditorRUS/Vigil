/*********************************
For the main html chat area
*********************************/

/var/list/chatResources = list(
	"code/modules/html_interface/jquery.min.js",
	"goon/browserassets/js/json2.min.js",
	"goon/browserassets/js/browserOutput.js",
	"goon/browserassets/css/fonts/fontawesome-webfont.eot",
	"goon/browserassets/css/fonts/fontawesome-webfont.svg",
	"goon/browserassets/css/fonts/fontawesome-webfont.ttf",
	"goon/browserassets/css/fonts/fontawesome-webfont.woff",
	"goon/browserassets/css/font-awesome.css",
	"goon/browserassets/css/browserOutput.css"
)

//Precaching a bunch of shit
/var/savefile/iconCache = new /savefile("data/iconCache.sav") //Cache of icons for the browser output

//On client, created on login
/datum/chatOutput
	var/client/owner = null //client ref
	var/loaded       = 0 // Has the client loaded the browser output area?
	var/list/messageQueue = list() //If they haven't loaded chat, this is where messages will go until they do
	var/cookieSent   = 0 // Has the client sent a cookie for analysis
	var/list/connectionHistory = list() //Contains the connection history passed from chat cookie
	var/broken       = FALSE

/datum/chatOutput/New(client/C)
	. = ..()

	owner = C
	// world.log << "chatOutput: New()"

/datum/chatOutput/proc/start()
	//Check for existing chat
	if(!owner)
		return 0

	if(!winexists(owner, "browseroutput")) // Oh goddamnit.
		alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		broken = TRUE
		return 0

	if(winget(owner, "browseroutput", "is-disabled") == "false") //Already setup
		doneLoading()

	else //Not setup
		load()

	return 1

/datum/chatOutput/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	// world.log << "chatOutput: load()"

	for(var/attempts = 1 to 5)
		for(var/asset in global.chatResources) // No asset cache, just get this fucking shit SENT.
			owner << browse_rsc(file(asset))

		// world.log << "Sending main chat window to client [owner.ckey]"
		owner << browse(file("goon/browserassets/html/browserOutput.html"), "window=browseroutput")
		sleep(20 SECONDS)
		if(!owner || loaded)
			break

	// world.log << "chatOutput: load() completed"

/datum/chatOutput/Topic(var/href, var/list/href_list)
	if(usr.client != owner)
		return 1

	// Build arguments.
	// Arguments are in the form "param[paramname]=thing"
	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param")) // 7 is the amount of characters in the basic param key template.
			var/param_name = copytext(key, 7, -1)
			var/item       = href_list[key]

			params[param_name] = item

	var/data // Data to be sent back to the chat.
	switch(href_list["proc"])
		if("doneLoading")
			data = doneLoading(arglist(params))

		if("debug")
			data = debug(arglist(params))

		if("ping")
			data = ping(arglist(params))

		if("analyzeClientData")
			data = analyzeClientData(arglist(params))

		if("encoding")
			var/encoding = href_list["encoding"]
			var/static/regex/RE = regex("windows-(874|125\[0-8])")
			if (RE.Find(encoding))
				owner.encoding = RE.group[1]

			else if (encoding == "gb2312")
				owner.encoding = "2312"

			// This seems to be the result on Japanese locales, but the client still seems to accept 1252.
			else if (encoding == "_autodetect")
				owner.encoding = "1251"

			else
				stack_trace("Unknown encoding received from client: \"[sanitize(encoding)]\". Please report this as a bug.")

	if(data)
		ehjax_send(data = data)

//Called on chat output done-loading by JS.
/datum/chatOutput/proc/doneLoading()
	if(loaded)
		return

	loaded = TRUE
	winset(owner, "browseroutput", "is-disabled=false")
	for(var/message in messageQueue)
		to_chat(owner, message)

	messageQueue = null
	src.sendClientData()

	pingLoop()

/datum/chatOutput/proc/pingLoop()
	set waitfor = FALSE

	while (owner)
		ehjax_send(data = owner.is_afk(29 SECONDS) ? "softPang" : "pang") // SoftPang isn't handled anywhere but it'll always reset the opts.lastPang.
		sleep(30 SECONDS)

/datum/chatOutput/proc/ehjax_send(var/client/C = owner, var/window = "browseroutput", var/data)
	if(islist(data))
		data = json_encode(data)
	C << output("[data]", "[window]:ehjaxCallback")

//Sends client connection details to the chat to handle and save
/datum/chatOutput/proc/sendClientData()
	//Get dem deets
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	var/data = list2json(deets)
	ehjax_send(data = data)

//Called by client, sent data to investigate (cookie history so far)
/datum/chatOutput/proc/analyzeClientData(cookie = "")
	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json2list(cookie)
		if (connData && islist(connData) && connData.len > 0 && connData["connData"])
			src.connectionHistory = connData["connData"] //lol fuck
			var/list/found = new()
			for (var/i = src.connectionHistory.len; i >= 1; i--)
				var/list/row = src.connectionHistory[i]
				if (!row || row.len < 3 || (!row["ckey"] && !row["compid"] && !row["ip"])) //Passed malformed history object
					return
				if (world.IsBanned(row["ckey"], row["compid"], row["ip"]))
					found = row
					break

			//Uh oh this fucker has a history of playing on a banned account!!
			if (found.len > 0)
				//TODO: add a new evasion ban for the CURRENT client details, using the matched row details
				message_admins("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				log_admin("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")

	cookieSent = 1

//Called by js client every 60 seconds
/datum/chatOutput/proc/ping()
	return "pong"

//Called by js client on js error
/datum/chatOutput/proc/debug(error)
	world.log <<"\[[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]\] Client: [(src.owner.key ? src.owner.key : src.owner)] triggered JS error: [error]"

/client/verb/debug_chat()
	set hidden = 1
	chatOutput.ehjax_send(data = list("firebug" = 1))

//Global chat procs

/var/list/bicon_cache = list()

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(var/icon/icon, var/iconKey = "misc")
	if (!isicon(icon))
		return 0

	iconCache[iconKey] << icon
	var/iconData = iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/bicon(var/obj)
	if (!obj)
		return

	if (isicon(obj))
		//Icons get pooled constantly, references are no good here.
		/*if (!bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			bicon_cache["\ref[obj]"] = icon2base64(obj)
		return "<img class='icon misc' src='data:image/png;base64,[bicon_cache["\ref[obj]"]]'>"*/
		return "<img class='icon misc' src='data:image/png;base64,[icon2base64(obj)]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = obj
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"
	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(obj)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
		bicon_cache[key] = icon2base64(I, key)

	return "<img class='icon [A.icon_state]' src='data:image/png;base64,[bicon_cache[key]]'>"

//Aliases for bicon
/proc/bi(obj)
	bicon(obj)

//Costlier version of bicon() that uses getFlatIcon() to account for overlays, underlays, etc. Use with extreme moderation, ESPECIALLY on mobs.
/proc/costly_bicon(var/obj)
	if (!obj)
		return

	if (isicon(obj))
		return bicon(obj)

	var/icon/I = getFlatIcon(obj)
	return bicon(I)

/proc/to_chat(target, message)
	//Ok so I did my best but I accept that some calls to this will be for shit like sound and images
	//It stands that we PROBABLY don't want to output those to the browser output so just handle them here
	if (istype(message, /image) || istype(message, /sound) || istype(target, /savefile) || !(ismob(target) || islist(target) || isclient(target) || istype(target, /datum/log) || target == world))
		target << message
		if (!isatom(target)) // Really easy to mix these up, and not having to make sure things are mobs makes the code cleaner.
			CRASH("DEBUG: Boutput called with invalid message")
		return

	//Otherwise, we're good to throw it at the user
	else if (istext(message))
		if (istext(target))
			return

		//Some macros remain in the string even after parsing and fuck up the eventual output
		if (findtext(message, "\improper"))
			message = replacetext(message, "\improper", "")
		if (findtext(message, "\proper"))
			message = replacetext(message, "\proper", "")

		//Grab us a client if possible
		var/client/C
		if (istype(target, /client))
			C = target
		else if (istype(target, /mob))
			C = target:client
		else if (istype(target, /datum/mind) && target:current)
			C = target:current:client

		if (C && C.chatOutput)
			if(C.chatOutput.broken) // Either a secret repo fuck up or a player who hasn't updated his skin file.
				C << message
				return

			if(!C.chatOutput.loaded && C.chatOutput.messageQueue && islist(C.chatOutput.messageQueue))
				//Client sucks at loading things, put their messages in a queue
				C.chatOutput.messageQueue.Add(message)
				return

		if(istype(target, /datum/log))
			var/datum/log/L = target
			L.log += (message + "\n")
			return

		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "�", "&#1040;")
		message = replacetext(message, "�", "&#1041;")
		message = replacetext(message, "�", "&#1042;")
		message = replacetext(message, "�", "&#1043;")
		message = replacetext(message, "�", "&#1044;")
		message = replacetext(message, "�", "&#1045;")
		message = replacetext(message, "�", "&#1046;")
		message = replacetext(message, "�", "&#1047;")
		message = replacetext(message, "�", "&#1048;")
		message = replacetext(message, "�", "&#1049;")
		message = replacetext(message, "�", "&#1050;")
		message = replacetext(message, "�", "&#1051;")
		message = replacetext(message, "�", "&#1052;")
		message = replacetext(message, "�", "&#1053;")
		message = replacetext(message, "�", "&#1054;")
		message = replacetext(message, "�", "&#1055;")
		message = replacetext(message, "�", "&#1056;")
		message = replacetext(message, "�", "&#1057;")
		message = replacetext(message, "�", "&#1058;")
		message = replacetext(message, "�", "&#1059;")
		message = replacetext(message, "�", "&#1060;")
		message = replacetext(message, "�", "&#1061;")
		message = replacetext(message, "�", "&#1062;")
		message = replacetext(message, "�", "&#1063;")
		message = replacetext(message, "�", "&#1064;")
		message = replacetext(message, "�", "&#1065;")
		message = replacetext(message, "�", "&#1066;")
		message = replacetext(message, "�", "&#1067;")
		message = replacetext(message, "�", "&#1068;")
		message = replacetext(message, "�", "&#1069;")
		message = replacetext(message, "�", "&#1070;")
		message = replacetext(message, "�", "&#1071;")
		message = replacetext(message, "�", "&#1072;")
		message = replacetext(message, "�", "&#1073;")
		message = replacetext(message, "�", "&#1074;")
		message = replacetext(message, "�", "&#1075;")
		message = replacetext(message, "�", "&#1076;")
		message = replacetext(message, "�", "&#1077;")
		message = replacetext(message, "�", "&#1078;")
		message = replacetext(message, "�", "&#1079;")
		message = replacetext(message, "�", "&#1080;")
		message = replacetext(message, "�", "&#1081;")
		message = replacetext(message, "�", "&#1082;")
		message = replacetext(message, "�", "&#1083;")
		message = replacetext(message, "�", "&#1084;")
		message = replacetext(message, "�", "&#1085;")
		message = replacetext(message, "�", "&#1086;")
		message = replacetext(message, "�", "&#1087;")
		message = replacetext(message, "�", "&#1088;")
		message = replacetext(message, "�", "&#1089;")
		message = replacetext(message, "�", "&#1090;")
		message = replacetext(message, "�", "&#1091;")
		message = replacetext(message, "�", "&#1092;")
		message = replacetext(message, "�", "&#1093;")
		message = replacetext(message, "�", "&#1094;")
		message = replacetext(message, "�", "&#1095;")
		message = replacetext(message, "�", "&#1096;")
		message = replacetext(message, "�", "&#1097;")
		message = replacetext(message, "�", "&#1098;")
		message = replacetext(message, "�", "&#1099;")
		message = replacetext(message, "�", "&#1100;")
		message = replacetext(message, "�", "&#1101;")
		message = replacetext(message, "�", "&#1102;")
		message = replacetext(message, "�", "&#1105;")
		message = replacetext(message, "�", "&#1025;")

		// url_encode it TWICE, this way any UTF-8 characters are able to be decoded by the Javascript.
		target << output(url_encode(url_encode(message)), "browseroutput:output")

/datum/log	//exists purely to capture to_chat() output
	var/log = ""
