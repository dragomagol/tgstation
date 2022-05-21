/// Logging for player manifest (ckey, name, job, special role, roundstart/latejoin)
/proc/log_manifest(mob/employee, ckey, latejoin = FALSE)
	if (CONFIG_GET(flag/log_manifest))
		var/datum/log_entry/manifest/manifest_log = new(employee, ckey)
		manifest_log.manifest_job_title(employee.mind.assigned_role.title)
		manifest_log.manifest_special_role(employee.mind.special_role ? employee.mind.special_role : "NONE")
		manifest_log.manifest_joined(latejoin ? "LATEJOIN" : "ROUNDSTART")

		WRITE_LOG(GLOB.world_manifest_log, manifest_log.to_text())
