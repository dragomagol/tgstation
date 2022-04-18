/**
 * Generic logging helper
 *
 * reads the type of the log
 * and writes it to the respective log file
 * unless log_globally is FALSE
 * Arguments:
 * * message - The message being logged
 * * message_type - the type of log the message is(ATTACK, SAY, etc)
 * * color - color of the log text
 * * log_globally - boolean checking whether or not we write this log to the log file
 */
/atom/proc/log_message(message, message_type, color = null, log_globally = TRUE)
	if(!log_globally)
		return

	var/log_text = "[key_name(src)] [message] [loc_name(src)]"
	switch(message_type)
		if(LOG_SAY)
			log_say(log_text)
		if(LOG_WHISPER)
			log_whisper(log_text)
		if(LOG_EMOTE)
			log_emote(log_text)
		if(LOG_RADIO_EMOTE)
			log_radio_emote(log_text)
		if(LOG_DSAY)
			log_dsay(log_text)
		if(LOG_PDA)
			log_pda(log_text)
		if(LOG_CHAT)
			log_chat(log_text)
		if(LOG_COMMENT)
			log_comment(log_text)
		if(LOG_ECON)
			log_econ(log_text)
		if(LOG_OOC)
			log_ooc(log_text)
		if(LOG_ADMIN)
			log_admin(log_text)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text)
		if(LOG_ASAY)
			log_adminsay(log_text)
		if(LOG_OWNERSHIP)
			log_game(log_text)
		if(LOG_GAME)
			log_game(log_text)
		if(LOG_MECHA)
			log_mecha(log_text)
		if(LOG_SHUTTLE)
			log_shuttle(log_text)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text)

/* All other items are public. */
/// Logs the contents of a gasmix to the game log, prefixed by text
/proc/log_atmos(atom/source, atom/target, action, details = null, list/tags = list())
	// var/datum/log_entry/atmos/atmos_log = new(source, target)
	// log_game(message)

/proc/log_mecha(text)
	if (CONFIG_GET(flag/log_mecha))
		WRITE_LOG(GLOB.world_mecha_log, "MECHA: [text]")

/proc/log_cloning(text, mob/initiator)
	if(CONFIG_GET(flag/log_cloning))
		WRITE_LOG(GLOB.world_cloning_log, "CLONING: [text]")

/proc/log_paper(text)
	WRITE_LOG(GLOB.world_paper_log, "PAPER: [text]")

/proc/log_asset(text)
	if(CONFIG_GET(flag/log_asset))
		WRITE_LOG(GLOB.world_asset_log, "ASSET: [text]")

/proc/log_silicon(text)
	if (CONFIG_GET(flag/log_silicon))
		WRITE_LOG(GLOB.world_silicon_log, "SILICON: [text]")

/proc/log_tool(text, mob/initiator)
	if(CONFIG_GET(flag/log_tools))
		WRITE_LOG(GLOB.world_tool_log, "TOOL: [text]")

///
/proc/log_bomber(atom/user, details, atom/bomb, additional_details, message_admins = TRUE)
	var/bomb_message = "[details][bomb ? " [bomb.name] at [AREACOORD(bomb)]": ""][additional_details ? " [additional_details]" : ""]."

	if(user)
		log_attack(user, "detonated", bomb, details = "[details][additional_details ? " [additional_details]" : ""]]", tags = list("explosion"))
		bomb_message = "[key_name(user)] at [AREACOORD(user)] [bomb_message]"
	else
		log_game(bomb_message)

	GLOB.bombers += bomb_message

	if(message_admins)
		message_admins("[user ? "[ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(user)] " : ""][details][bomb ? " [bomb.name] at [ADMIN_VERBOSEJMP(bomb)]": ""][additional_details ? " [additional_details]" : ""].")

/proc/log_shuttle(text)
	if (CONFIG_GET(flag/log_shuttle))
		WRITE_LOG(GLOB.world_shuttle_log, "SHUTTLE: [text]")

/proc/log_href(text)
	WRITE_LOG(GLOB.world_href_log, "HREF: [text]")

/proc/log_mob_tag(text)
	WRITE_LOG(GLOB.world_mob_tag_log, "TAG: [text]")

/proc/log_qdel(text)
	WRITE_LOG(GLOB.world_qdel_log, "QDEL: [text]")

/proc/log_query_debug(text)
	WRITE_LOG(GLOB.query_debug_log, "SQL: [text]")

/proc/log_job_debug(text)
	if (CONFIG_GET(flag/log_job_debug))
		WRITE_LOG(GLOB.world_job_debug_log, "JOB: [text]")

/proc/log_filter_raw(text)
	WRITE_LOG(GLOB.filter_log, "FILTER: [text]")

/proc/log_perf(list/perf_info)
	. = "[perf_info.Join(",")]\n"
	WRITE_LOG_NO_FORMAT(GLOB.perf_log, .)
