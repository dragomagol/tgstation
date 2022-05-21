/**
 * Configures a log_entry with given information and writes the textual representation of the
 * datum to the global attack log.
 *
 * Mirrors this log entry to the individual logs for the attacker and victim, if they're mobs.
 */
/proc/log_mecha(list/source, type, log, equipment = null, target = null, list/tags = list())
	if (CONFIG_GET(flag/log_mecha))
		var/driver = source
		// If we have only one driver get the mob, otherwise give a string list of drivers
		if(length(source) == 1)
			driver = source[1]
		else if (source && istype(source, /list))
			driver = source.Join(", ")

		var/datum/log_entry/mecha/mecha_log = new(driver, target)
		mecha_log.add_tags(tags)
		mecha_log.mecha_type(type)
		mecha_log.mecha_log(log)
		mecha_log.mecha_equipment(equipment)

		WRITE_LOG(GLOB.world_mecha_log, mecha_log.to_text())

/// Logging for equipment installed in a mecha
/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type = LOG_MECHA, color = null, log_globally)
	if(chassis)
		return chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	return ..()
