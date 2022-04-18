/proc/log_telecomms(text)
	if (CONFIG_GET(flag/log_telecomms))
		var/datum/log_entry/telecomms/network/network_log = new()
		network_log.network_log(text)

		WRITE_LOG(GLOB.world_telecomms_log, network_log.to_text())

/proc/log_broadcast(atom/speaker, channel, spans, message, language)
	if (CONFIG_GET(flag/log_telecomms))
		var/datum/log_entry/telecomms/broadcast/broadcast_log = new(speaker)
		broadcast_log.broadcast_channel(channel)
		broadcast_log.broadcast_spans(spans)
		broadcast_log.broadcast_message(message)
		broadcast_log.broadcast_language(language)

		WRITE_LOG(GLOB.world_telecomms_log, broadcast_log.to_text())
