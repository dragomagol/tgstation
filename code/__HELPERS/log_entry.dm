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
	var/private = FALSE
	/// The (x,y,z) coordinate where this event took place
	/// Will be (0,0,0) if the event is abstract
	var/list/location = list(0,0,0)
	/// Extra information that applies to this log
	var/list/tags
	/// The source of this message
	/// The object's textual name as it would be recognised by administrators in game
	var/source
	var/source_ckey
	/// The target of this log message
	var/target
	var/target_ckey
	/// Non-optional fields specific to this log type (i.e. "channel" for a telecomms log)
	var/list/extended_fields

/datum/log_entry/New(var/_source, var/_target, var/list/_location)
	/// TODO: make this UNIX timestamp
	timestamp = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")
	round_id = GLOB.round_id ? GLOB.round_id : "NULL"
	server_name = CONFIG_GET(string/serversqlname)

	source = _source
	target = _target
	location = _location.Copy()

	tags = list()
	extended_fields = list()

/datum/log_entry/proc/add_tags(var/list/new_tags)
	tags += new_tags

/// Returns a human-friendly representation of this log
/datum/log_entry/proc/to_text()
	var/text_log = "[private ? "ADMIN: " : ""]"
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
	new_entry.source = source
	new_entry.source_ckey = source_ckey
	new_entry.target = target
	new_entry.target_ckey = target_ckey
	new_entry.extended_fields = extended_fields.Copy()
	return new_entry

//////////////////////////////////////// Specific logs

/// atmos
/datum/log_entry/atmospherics
	category = "ATMOS"
	tags = list("atmospherics")

/// attack
/**
 * Attack Log
 *
 * Extended fields:
 * * action - a verb describing the action (e.g. punched, thrown, kicked, etc.)
 * * weapon - a tool with which the action was made (usually an item)
 * * details - any additional text, which will be appended to the rest of the log line
 */
/datum/log_entry/attack/New(var/_source, var/_target, var/list/_location)
	. = ..(_source, _target, _location)
	category = "ATTACK"
	tags = list("attack")
	extended_fields = list(
		"action" = null,
		"weapon" = null,
		"details" = null,
	)

/datum/log_entry/attack/proc/combat_action(var/action)
	extended_fields["action"] = action

/datum/log_entry/attack/proc/combat_weapon(var/weapon)
	extended_fields["weapon"] = weapon

/datum/log_entry/attack/proc/combat_details(var/details)
	extended_fields["details"] = details

/datum/log_entry/attack/to_text()
	var/action = extended_fields["action"]
	var/weapon = extended_fields["weapon"]
	var/details = extended_fields["details"]

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? "(NEWHP: [living_target.health])" : ""

	var/postfix = ""
	if(weapon)
		postfix += " with [weapon]"
	if(details)
		postfix += " [details]"
	postfix += " [hp]"

	return ..() + "[key_name(source)] has [action] [key_name(target)][postfix] [loc_name(source)]"

/datum/log_entry/attack/proc/player_log_text(is_attacker)
	var/action = extended_fields["action"]
	var/weapon = extended_fields["weapon"]
	var/details = extended_fields["details"]

	var/postfix = ""
	if(weapon)
		postfix += " with [weapon]"
	if(details)
		postfix += " [details]"

	if (is_attacker)
		return "has [action] [key_name(target)][postfix]"
	else
		return "has been [action] by [key_name(source)][postfix]"

/**
 * log_wound() is for when someone is *attacked* and suffers a wound. Note that this only captures wounds from damage, so smites/forced wounds aren't logged, as well as demotions like cuts scabbing over
 *
 * Note that this has no info on the attack that dealt the wound: information about where damage came from isn't passed to the bodypart's damaged proc. When in doubt, check the attack log for attacks at that same time
 * TODO later: Add logging for healed wounds, though that will require some rewriting of healing code to prevent admin heals from spamming the logs. Not high priority
 *
 * Arguments:
 * * target - The player who got wounded
 * * suffered_wound - The wound, already applied, that we're logging. It has to already be attached so we can get the limb from it
 * * dealt_damage - How much damage is associated with the attack that dealt with this wound.
 * * dealt_wound_bonus - The wound_bonus, if one was specified, of the wounding attack
 * * dealt_bare_wound_bonus - The bare_wound_bonus, if one was specified *and applied*, of the wounding attack. Not shown if armor was present
 * * base_roll - Base wounding ability of an attack is a random number from 1 to (dealt_damage ** WOUND_DAMAGE_EXPONENT). This is the number that was rolled in there, before mods
 */
/datum/log_entry/attack/wound/to_text()
	// var/ssource = key_name(user)
	// var/starget = key_name(target)

	// var/mob/living/living_target = target
	// var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	// var/sobject = ""
	// if(object)
	// 	sobject = " with [object]"
	// var/saddition = ""
	// if(addition)
	// 	saddition = " [addition]"

	// var/postfix = "[sobject][saddition][hp]"

	// var/message = "has [what_done] [starget][postfix]"
	// user.log_message(message, LOG_ATTACK, color="red")

	// if(user != target)
	// 	var/reverse_message = "has been [what_done] by [ssource][postfix]"
	// 	target.log_message(reverse_message, LOG_VICTIM, color="orange", log_globally=FALSE)

/// botany
/datum/log_entry/botany
	category = "BOTANY"
	tags = list("botany")

/// cargo
/datum/log_entry/cargo
	category = "CARGO"
	tags = list("cargo")

/// cloning
/datum/log_entry/cloning
	category = "CLONING"
	tags = list("cloning")

/// crafting
/datum/log_entry/crafting
	category = "CRAFTING"
	tags = list("crafting")

/// dream daemon?

/// dynamic

/// econ

/// engine
/datum/log_entry/engine
	category = "ENGINE"
	tags = list("engineering")

/// filters
/datum/log_entry/filter
	category = "FILTER"
	tags = list("filter")

/// game
/datum/log_entry/game
	category = "GAME"
	tags = list("game")

/// gravity
/datum/log_entry/gravity
	category = "GRAVITY"
	tags = list("engineering", "gravity")

/// hallucinations
/datum/log_entry/hallucination
	category = "HALLUCINATION"
	tags = list("hallucination")

/// hrefs
/datum/log_entry/href
	category = "HREF"
	tags = list("href")

/// id card changes
/datum/log_entry/id_access_change
	category = "ID_ACCESS"
	tags = list("access_change")

/// init profiler

/// initialize

/// job debug

/// manifest
/datum/log_entry/manifest
	category = "MANIFEST"
	tags = list("manifest")

/// map errors

/// mecha
/datum/log_entry/mecha
	category = "MECH"
	tags = list("mech")

/// mob tags
/datum/log_entry/mob_tag
	category = "MOB"
	tags = list("mob_tag")

/// newscaster - this has JSON already, integrate it
/datum/log_entry/newscaster
	category = "NEWSCASTER"
	tags = list("newscaster")

/// paper
/datum/log_entry/paper
	category = "PAPER"
	tags = list("paper")

/// pda
/datum/log_entry/pda
	category = "PDA"
	tags = list("pda")

/// portals
/datum/log_entry/portal
	category = "PORTAL"
	tags = list("portal")

/// qdel
/datum/log_entry/qdel
	category = "QDEL"
	tags = list("qdel")

/// radiation
/datum/log_entry/radiation
	category = "RADIATION"
	tags = list("radiation")

/// records
/datum/log_entry/records
	category = "RECORD"
	tags = list("records", "security")

/// research
/datum/log_entry/research
	category = "RESEARCH"
	tags = list("research", "rnd")

/// round end data

/// runtime
/datum/log_entry/runtime
	category = "RUNTIME"
	tags = list("debug", "runtime")

/// shuttle
/datum/log_entry/shuttle
	category = "SHUTTLE"
	tags = list("shuttle")

/// silicon
/datum/log_entry/silicon
	category = "SILICON"
	tags = list("silicon")

/// sql
/datum/log_entry/sql
	category = "SQL"
	tags = list("debug", "sql")

/// telecomms - Radio channels
/datum/log_entry/telecommunications
	category = "TCOMMS"
	tags = list("telecommunications")

/// tgui
/datum/log_entry/tgui
	category = "TGUI"
	tags = list("tgui")

/// tools
/datum/log_entry/tools
	category = "TOOL"
	tags = list("tools")

/// uplink
/datum/log_entry/uplink
	category = "UPLINK"
	tags = list("antagonists", "uplink")

/// virus
/datum/log_entry/virus
	category = "VIRUS"
	tags = list("virus")

/// wires
/datum/log_entry/wires
	category = "WIRE"
	tags = list("engineering", "wires")
