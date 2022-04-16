/proc/log_uplink(text)
	if (CONFIG_GET(flag/log_uplink))
		WRITE_LOG(GLOB.world_uplink_log, "UPLINK: [text]")

/proc/log_spellbook(text)
	if (CONFIG_GET(flag/log_uplink))
		WRITE_LOG(GLOB.world_uplink_log, "SPELLBOOK: [text]")

/proc/log_heretic_knowledge(text)
	if (CONFIG_GET(flag/log_uplink))
		WRITE_LOG(GLOB.world_uplink_log, "HERETIC RESEARCH: [text]")

/proc/log_changeling_power(text)
	if (CONFIG_GET(flag/log_uplink))
		WRITE_LOG(GLOB.world_uplink_log, "CHANGELING: [text]")
