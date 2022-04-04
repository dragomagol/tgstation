// A new datum for the logging overhaul as outlined here: https://hackmd.io/AbKq0aPVS9OAaU2Wbz6UkA

/datum/log_entry
	/// Unix timestamp of the real server time this log was created
	var/timestamp
	/// Following https://semver.org/, the version number of this logging datum
	var/version = "1.0.0"
	/// Round ID this log entry was recorded on, as a string
	var/round_id
	/// Unique name of the server this log was generated on, as a string
	var/server_name
	/// Type of log entry as uppercase text string (SAY, OOC, GAME, ATTACK, etc.)
	var/category = "NONE"
	/// Indicates whether this log should be omitted from public-facing logs
	/// 0 for public and 1 for private
	var/private = TRUE
	/// The (x,y,z) coordinate where this event took place
	/// Will be (0,0,0) if the event is abstract
	var/list/location = list(0,0,0)
	/// Extra information that applies to this log
	var/list/tags
	/// TODO: The below needs some more thought into the structure
	/// The source of this message
	/// The object's textual name as it would be recognised by administrators in game
	var/source
	/// The ckey (if any) associated with the source
	var/source_ckey
	/// The target of this log message
	var/target
	/// The ckey (if any) associated with the source
	var/target_ckey
	/// Non-optional fields specific to this log type (i.e. "channel" for a telecomms log)
	var/list/extended_fields

/datum/log_entry/New()
	/// TODO: make this UNIX timestamp
	timestamp = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")
	round_id = GLOB.round_id ? GLOB.round_id : "NULL"
	server_name = CONFIG_GET(string/serversqlname)

	tags = list()
	extended_fields = list()

/// Returns a human-friendly representation of this log
/datum/log_entry/proc/to_text()
	var/text_log = ""
	text_log += ["\[[timestamp]\] "]
	text_log += "[private ? "ADMIN: " : ""]"
	text_log += "[category]: "
	return text_log

/// Returns a JSON representation of this log
/datum/log_entry/proc/to_json()
	var/list/json_log = list()
	json_log["timestamp"] = timestamp
	json_log["version"] = version
	json_log["roundid"] = round_id
	json_log["servername"] = server_name
	json_log["category"] = category
	json_log["private"] = private
	json_log["location"] = "\[[location.Join(",")]\]"
	json_log["tags"] = "\[[tags.Join(",")]\]"
	json_log["source"] = source
	json_log["source_ckey"] = source_ckey
	json_log["target"] = target
	json_log["target_ckey"] = target_ckey
	json_log["extended_fields"] = json_encode(extended_fields)
	return json_encode(json_log)

/// JSON representation of the extended fields
/datum/log_entry/proc/extended_fields_json()
	return json_encode(list())

/// Sends this log to SSlog to be printed
/datum/log_entry/proc/write_log()
	SSlogging.queue_log(src)
	return

/// Sends a human-friendly version of this log to admin chat, including a JMP link to the loc
/// Must process immediately, not wait on the SSlog queue
/datum/log_entry/proc/notify_admins()
	var/log_text = to_text()
	message_admins(log_text) // + Admin_Coordinates_Readable()

/// Create a deep copy of this log entry
/datum/log_entry/proc/clone()
	var/datum/log_entry/new_entry = new

	new_entry.timestamp = timestamp
	new_entry.category = category
	new_entry.private = private
	new_entry.location = location.Copy()
	new_entry.tags = tags.Copy()
	new_entry.source = source // TODO: what type is this?
	new_entry.source_ckey = source_ckey
	new_entry.target = target // TODO: what type is this?
	new_entry.target_ckey = target_ckey
	new_entry.extended_fields = extended_fields.Copy()

	return new_entry

/// atmos
/datum/log_entry/atmospherics
	category = "ATMOS"
	tags += ["atmospherics"]

/// attack
/// extended fields: new_hp
/datum/log_entry/attack
	category = "ATTACK"
	tags += ["attack"]

/// botany
/datum/log_entry/botany
	category = "BOTANY"
	tags += ["botany"]

/// cargo
/datum/log_entry/cargo
	category = "CARGO"
	tags += ["cargo"]

/// cloning
/datum/log_entry/cloning
	category = "CLONING"
	tags += ["cloning"]

/// crafting
/datum/log_entry/crafting
	category = "CRAFTING"
	tags += ["crafting"]

/// dd?

/// dynamic

/// econ

/// engine
/datum/log_entry/engine
	category = "ENGINE"
	tags += ["engineering"]

/// filters
/datum/log_entry/filter
	category = "FILTER"
	tags += ["filter"]

/// game
/datum/log_entry/game
	category = "GAME"
	tags += ["game"]

/// gravity
/datum/log_entry/gravity
	category = "GRAVITY"
	tags += ["engineering", "gravity"]

/// hallucinations
/datum/log_entry/hallucination
	category = "HALLUCINATION"
	tags += ["hallucination"]

/// hrefs
/datum/log_entry/href
	category = "HREF"
	tags += ["href"]

/// id card changes
/datum/log_entry/id_access_change
	category = "ID_ACCESS"
	tags += ["access_change"]

/// init profiler

/// initialize

/// job debug

/// manifest
/datum/log_entry/manifest
	category = "MANIFEST"
	tags += ["manifest"]

/// map errors

/// mecha
/datum/log_entry/mecha
	category = "MECH"
	tags += ["mech"]

/// mob tags
/datum/log_entry/mob_tag
	category = "MOB"
	tags += ["mob_tag"]

/// newscaster - this has JSON already, integrate it
/datum/log_entry/newscaster
	category = "NEWSCASTER"
	tags += ["newscaster"]

/// paper
/datum/log_entry/paper
	category = "PAPER"
	tags += ["paper"]

/// pda
/datum/log_entry/pda
	category = "PDA"
	tags += ["pda"]

/// portals
/datum/log_entry/portal
	category = "PORTAL"
	tags += ["portal"]

/// qdel
/datum/log_entry/qdel
	category = "QDEL"
	tags += ["qdel"]

/// radiation
/datum/log_entry/radiation
	category = "RADIATION"
	tags += ["radiation"]

/// records
/datum/log_entry/records
	category = "RECORD"
	tags += ["records", "security"]

/// research
/datum/log_entry/research
	category = "RESEARCH"
	tags += ["research", "rnd"]

/// round end data

/// runtime
/datum/log_entry/runtime
	category = "RUNTIME"
	tags += ["debug", "runtime"]

/// shuttle
/datum/log_entry/shuttle
	category = "SHUTTLE"
	tags += ["shuttle"]

/// silicon
/datum/log_entry/silicon
	category = "SILICON"
	tags += ["silicon"]

/// sql
/datum/log_entry/sql
	category = "SQL"
	tags += ["debug", "sql"]

/// telecomms - Radio channels
/datum/log_entry/telecommunications
	category = "TCOMMS"
	tags += ["telecommunications"]

/// tgui
/datum/log_entry/tgui
	category = "TGUI"
	tags += ["tgui"]

/// tools
/datum/log_entry/tools
	category = "TOOL"
	tags += ["tools"]

/// uplink
/datum/log_entry/uplink
	category = "UPLINK"
	tags += ["antagonists", "uplink"]

/// virus
/datum/log_entry/virus
	category = "VIRUS"
	tags += ["virus"]

/// wires
/datum/log_entry/wires
	category = "WIRE"
	tags += ["engineering", "wires"]
