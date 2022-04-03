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
