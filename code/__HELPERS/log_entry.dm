// A new datum for the logging overhaul as outlined here: https://hackmd.io/AbKq0aPVS9OAaU2Wbz6UkA

/**
 *
 */
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
	/// The ckey associated with the source (if any)
	var/source_ckey
	/// The target of this log message
	var/target
	/// The ckey associated with the target (if any)
	var/target_ckey
	/// Non-optional fields specific to this log type (i.e. "channel" for a telecomms log)
	var/list/extended_fields

/datum/log_entry/New(_source, _target)
	/// TODO: make this UNIX timestamp
	timestamp = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")
	round_id = GLOB.round_id ? GLOB.round_id : "NULL"
	server_name = CONFIG_GET(string/serversqlname)

	source = _source
	if(istype(source, /mob))
		var/mob/source_mob = source
		source_ckey = source_mob.ckey

	target = _target
	if(istype(target, /mob))
		var/mob/target_mob = target
		target_ckey = target_mob.ckey

	if(istype(source, /atom))
		var/atom/source_atom = source
		location = list(source_atom.loc.x, source_atom.loc.y, source_atom.loc.z)

	tags = list()
	extended_fields = list()

/datum/log_entry/proc/add_tags(list/new_tags)
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

///////////////////////////////// atmos - investigate
/datum/log_entry/atmospherics/New(_source, _target)
	. = ..(_source, _target)
	category = "ATMOS"
	tags = list("atmospherics")

///////////////////////////////// attack
/datum/log_entry/attack/New(_source, _target)
	. = ..(_source, _target)
	category = "ATTACK"
	tags += list("attack")

/**
 * Attack (Combat) Log
 *
 * Extended fields:
 * * action - a verb describing the action (e.g. punched, thrown, kicked, etc.)
 * * weapon - a tool with which the action was made (usually an item)
 * * details - any additional text, which will be appended to the rest of the log line
 */
/datum/log_entry/attack/combat/New(_source, _target)
	. = ..(_source, _target)
	extended_fields = list(
		"action" = null,
		"weapon" = null,
		"details" = null,
	)

/datum/log_entry/attack/combat/proc/combat_action(action)
	extended_fields["action"] = action

/datum/log_entry/attack/combat/proc/combat_weapon(weapon)
	extended_fields["weapon"] = weapon

/datum/log_entry/attack/combat/proc/combat_details(details)
	extended_fields["details"] = details

/datum/log_entry/attack/combat/to_text()
	// The attack_log syntax is nearly identical to the player log syntax, but with a subject
	return ..() + "[key_name(source)] [src.player_log_text(is_attacker = TRUE)]"

/// The version of the log that will show up in a player's personal logs
/datum/log_entry/attack/combat/proc/player_log_text(is_attacker)
	var/action = extended_fields["action"]
	var/weapon = extended_fields["weapon"]
	var/details = extended_fields["details"]

	var/postfix = ""
	if(weapon)
		postfix += " with [weapon]"
	if(details)
		postfix += " [details]"

	if(is_attacker)
		return "[action] [key_name(target)][postfix]"
	else
		return "was [action] by [key_name(source)][postfix]"

/**
 * Conversion Log
 *
 * Extended fields:
 * * action - the action that was taken (transformed, converted) and
 * *          the new faction (team) this player belongs to
 * * details - optional details
 */
/datum/log_entry/attack/conversion/New(_source, _target)
	. = ..(_source, _target)
	tags += list("conversion")
	extended_fields = list(
		"action" = null,
		"details" = null,
	)

/datum/log_entry/attack/conversion/proc/conversion_action(action)
	extended_fields["action"] = action

/datum/log_entry/attack/conversion/proc/conversion_details(details)
	extended_fields["details"] = details

/datum/log_entry/attack/conversion/to_text()
	return ..() + "[key_name(source)] [src.player_log_text()]"

/datum/log_entry/attack/conversion/proc/player_log_text()
	var/action = extended_fields["action"]
	var/details = extended_fields["details"]
	return "[action][details? " [details]" : ""]"

/**
 * Wound Log
 *
 * Extended fields:
 * * type - The wound, already applied, that we're logging. It has to already be attached so we can get the limb from it
 * * damage - How much damage is associated with the attack that dealt with this wound.
 * * wound_bonus - The wound_bonus, if one was specified, of the wounding attack
 * * bare_wound_bonus - The bare_wound_bonus, if one was specified *and applied*, of the wounding attack. Not shown if armor was present
 * * base_roll - Base wounding ability of an attack is a random number from 1 to (damage ** WOUND_DAMAGE_EXPONENT). This is the number that was rolled in there, before mods
 */
/datum/log_entry/attack/wound/New(_source)
	. = ..(_source, null)
	tags += list("wound")
	extended_fields = list(
		"type" = null,
		"damage" = null,
		"bonus" = null,
		"bare_bonus" = null,
		"base_roll" = null,
	)

/datum/log_entry/attack/wound/proc/wound_type(datum/wound/type)
	extended_fields["type"] = type

/datum/log_entry/attack/wound/proc/wound_damage(damage)
	extended_fields["damage"] = damage

/datum/log_entry/attack/wound/proc/wound_bonus(bonus)
	extended_fields["bonus"] = bonus

/datum/log_entry/attack/wound/proc/wound_bare_bonus(bare_bonus)
	extended_fields["bare_bonus"] = bare_bonus

/datum/log_entry/attack/wound/proc/wound_base_roll(base_roll)
	extended_fields["base_roll"] = base_roll

/datum/log_entry/attack/wound/to_text()
	return ..() + "[key_name(source)] [src.player_log_text()]"

/datum/log_entry/attack/wound/proc/player_log_text()
	var/datum/wound/type = extended_fields["type"]
	var/damage = extended_fields["damage"]
	var/bonus = extended_fields["bonus"]
	var/bare_bonus = extended_fields["bare_bonus"]
	var/base_roll = extended_fields["base_roll"]

	var/stats = ""
	if(damage)
		stats += " | Damage: [damage]"
		if(base_roll)
			stats += " (rolled [base_roll]/[damage ** WOUND_DAMAGE_EXPONENT])"

	if(bonus)
		stats += " | WB: [bonus]"

	if(bare_bonus)
		stats += " | BWB: [bare_bonus]"

	return "has suffered: [type][type.limb ? " to [type.limb.name]" : null]" + stats

/**
 * Death Log
 *
 * Extended fields:
 * * cause - cause of death (natural death, suicide, succumb)
 */
/datum/log_entry/attack/death/New(_source)
	. = ..(_source, null)
	tags += list("death")
	extended_fields = list(
		"cause" = null,
	)

/datum/log_entry/attack/death/proc/death_cause(cause)
	extended_fields["cause"] = cause

/datum/log_entry/attack/death/to_text()
	var/cause = extended_fields["cause"]
	return ..() + "[key_name(source)] has [cause]"

/datum/log_entry/attack/death/proc/player_log_text()
	var/cause = extended_fields["cause"]
	return "has [cause]"

///////////////////////////////// botany
/datum/log_entry/botany
	category = "BOTANY"
	tags = list("botany")

///////////////////////////////// cargo
/datum/log_entry/cargo
	category = "CARGO"
	tags = list("cargo")

///////////////////////////////// cloning
/datum/log_entry/cloning
	category = "CLONING"
	tags = list("cloning")

///////////////////////////////// crafting
/datum/log_entry/crafting
	category = "CRAFTING"
	tags = list("crafting")

///////////////////////////////// dream daemon?

///////////////////////////////// dynamic

///////////////////////////////// econ
/**
 * Economy Log
 *
 * Extended fields:
 * * credits - the number of credits involved
 * * purchased_item - what was bought (optional)
 * * account_owner - who owns the account (optional)
 */
/datum/log_entry/economy/New(_source, _target)
	. = ..(_source, _target)
	category = "ECONOMY"
	tags = list("economy")

/datum/log_entry/economy/transaction/New(_source, _target)
	. = ..(_source, _target)
	tags += list("transaction")
	extended_fields = list(
		"credits" = null,
		"purchased_item" = null,
		"account_owner" = null,
	)

/datum/log_entry/economy/transaction/proc/transaction_credits(credits)
	extended_fields["credits"] = credits

/datum/log_entry/economy/transaction/proc/transaction_purchased_item(purchased_item)
	extended_fields["purchased_item"] = purchased_item

/datum/log_entry/economy/transaction/proc/transaction_account_owner(account_owner)
	extended_fields["account_owner"] = account_owner

/datum/log_entry/economy/transaction/to_text()
	var/credits = extended_fields["credits"]
	var/purchased_item = extended_fields["purchased_item"]
	var/account_owner = extended_fields["account_owner"]

	return ..() + "[source] has transferred [credits] credits to [target]\
		[account_owner ? " (belonging to [account_owner])" : ""]\
		[purchased_item ? " to purchase [purchased_item]" : ""]"

/datum/log_entry/economy/round_end/New()
	. = ..(null, null)
	tags += list("round_end")
	extended_fields = list(
		"report" = null,
		"credits" = null,
	)

/datum/log_entry/economy/round_end/proc/round_end_report(report)
	extended_fields["report"] = report

/datum/log_entry/economy/round_end/proc/round_end_credits(credits)
	extended_fields["credits"] = credits

/datum/log_entry/economy/round_end/to_text()
	var/report = extended_fields["report"]
	var/credits = extended_fields["credits"]
	return ..() + "Round end [report]: [credits] credits."

///////////////////////////////// engine
/datum/log_entry/engine
	category = "ENGINE"
	tags = list("engineering")

///////////////////////////////// filters
/datum/log_entry/filter
	category = "FILTER"
	tags = list("filter")

///////////////////////////////// game
/datum/log_entry/game
	category = "GAME"
	tags = list("game")

///////////////////////////////// gravity
/datum/log_entry/gravity
	category = "GRAVITY"
	tags = list("engineering", "gravity")

///////////////////////////////// hallucinations
/datum/log_entry/hallucination
	category = "HALLUCINATION"
	tags = list("hallucination")

///////////////////////////////// hrefs
/datum/log_entry/href
	category = "HREF"
	tags = list("href")

///////////////////////////////// id card changes
/datum/log_entry/id_access_change
	category = "ID_ACCESS"
	tags = list("access_change")

///////////////////////////////// init profiler

///////////////////////////////// initialize

///////////////////////////////// job debug

///////////////////////////////// manifest
/datum/log_entry/manifest/New(_source, _source_ckey)
	..(_source, null)
	// when this is called in datacore for roundstart players, players' bodies and minds
	// aren't yet connected so we have to set the ckey ourselves
	source_ckey = _source_ckey
	category = "MANIFEST"
	tags = list("manifest")
	extended_fields = list(
		"job_title" = null,
		"special_role" = null,
		"joined" = null
	)

/datum/log_entry/manifest/proc/manifest_job_title(job_title)
	extended_fields["job_title"] = job_title

/datum/log_entry/manifest/proc/manifest_special_role(special_role)
	extended_fields["special_role"] = special_role

/datum/log_entry/manifest/proc/manifest_joined(joined)
	extended_fields["joined"] = joined

/datum/log_entry/manifest/to_text()
	var/mob/source_mob = source
	var/job_title = extended_fields["job_title"]
	var/special_role = extended_fields["special_role"]
	var/joined = extended_fields["joined"]

	return ..() + "[source_ckey] \\ [source_mob.real_name] \\ [job_title] \\ [special_role] \\ [joined]"

///////////////////////////////// map errors

///////////////////////////////// mecha
/datum/log_entry/mecha
	category = "MECH"
	tags = list("mech")

///////////////////////////////// mob tags
/datum/log_entry/mob_tag
	category = "MOB"
	tags = list("mob_tag")

///////////////////////////////// newscaster - this has JSON already, integrate it
/datum/log_entry/newscaster
	category = "NEWSCASTER"
	tags = list("newscaster")

///////////////////////////////// paper
/datum/log_entry/paper
	category = "PAPER"
	tags = list("paper")

///////////////////////////////// pda
/datum/log_entry/pda
	category = "PDA"
	tags = list("pda")

///////////////////////////////// portals
/datum/log_entry/portal
	category = "PORTAL"
	tags = list("portal")

///////////////////////////////// qdel
/datum/log_entry/qdel
	category = "QDEL"
	tags = list("qdel")

///////////////////////////////// radiation
/datum/log_entry/radiation
	category = "RADIATION"
	tags = list("radiation")

///////////////////////////////// records
/datum/log_entry/records
	category = "RECORD"
	tags = list("records", "security")

///////////////////////////////// research
/datum/log_entry/research
	category = "RESEARCH"
	tags = list("research", "rnd")

///////////////////////////////// round end data

///////////////////////////////// runtime
/datum/log_entry/runtime
	category = "RUNTIME"
	tags = list("debug", "runtime")

///////////////////////////////// shuttle
/datum/log_entry/shuttle
	category = "SHUTTLE"
	tags = list("shuttle")

///////////////////////////////// silicon
/datum/log_entry/silicon
	category = "SILICON"
	tags = list("silicon")

///////////////////////////////// sql
/datum/log_entry/sql
	category = "SQL"
	tags = list("debug", "sql")

///////////////////////////////// telecomms - Radio channels
/datum/log_entry/telecomms/New()
	..(null, null) // it's all abstract
	category = "TCOMMS"
	tags = list("telecomms")

/**
 * Network Log
 *
 * Extended fields:
 * * log - the message to be logged (there is no "standard" tcomms log)
 */
/datum/log_entry/telecomms/network/New()
	..()
	category = "NETWORK"
	extended_fields = list(
		"log" = null
	)

/datum/log_entry/telecomms/network/proc/network_log(log)
	extended_fields["log"] = log

/datum/log_entry/telecomms/network/to_text()
	var/log = extended_fields["log"]
	return ..() + log

/**
 * Economy Log
 *
 * Extended fields:
 * * channel - the channel broadcasted over
 * * spans - who owns the account (optional)
 * * message - what was said
 * * language - what language it was said in
 */
/datum/log_entry/telecomms/broadcast/New(_source)
	..(_source, null)
	category = "COMMS"
	extended_fields = list(
		"channel" = null,
		"spans" = null,
		"message" = null,
		"language" = null
	)

/datum/log_entry/telecomms/broadcast/proc/broadcast_channel(channel)
	extended_fields["channel"] = channel

/datum/log_entry/telecomms/broadcast/proc/broadcast_spans(spans)
	extended_fields["spans"] = spans

/datum/log_entry/telecomms/broadcast/proc/broadcast_message(message)
	extended_fields["message"] = message

/datum/log_entry/telecomms/broadcast/proc/broadcast_language(language)
	extended_fields["language"] = language

/datum/log_entry/telecomms/broadcast/to_text()
	var/channel = extended_fields["channel"]
	var/spans = extended_fields["spans"]
	var/message = extended_fields["message"]
	var/language = extended_fields["language"]

	return ..() + "\[[channel]\] ["[spans] " || ""]\"[message]\" (language: [language])"

///////////////////////////////// tgui
/datum/log_entry/tgui
	category = "TGUI"
	tags = list("tgui")

///////////////////////////////// tools
/datum/log_entry/tools
	category = "TOOL"
	tags = list("tools")

///////////////////////////////// uplink
/datum/log_entry/uplink
	category = "UPLINK"
	tags = list("antagonists", "uplink")

///////////////////////////////// virus
/datum/log_entry/virus/New(_source)
	..(_source, null)
	category = "VIRUS"
	tags = list("virus")
	extended_fields = list(
		"disease" = null,
		"message" = null,
	)

/datum/log_entry/virus/proc/virus_disease(disease)
	extended_fields["disease"] = disease

/datum/log_entry/virus/proc/virus_message(message)
	extended_fields["message"] = message

/datum/log_entry/virus/to_text()
	var/disease = extended_fields["disease"]
	var/message = extended_fields["message"]
	return ..() + "[key_name(source)] [message] [disease]"

///////////////////////////////// wires
/datum/log_entry/wires
	category = "WIRE"
	tags = list("engineering", "wires")
