/**
 * log_virus() is for logging a viral infection
 *
 * infectee - The person who was infected
 * virus - the virus' name and stats ()
 */
/proc/log_virus(atom/infectee, message, datum/disease/virus)
	if (CONFIG_GET(flag/log_virus))
		var/datum/log_entry/virus/virus_log = new(infectee)
		virus_log.virus_disease(virus.admin_details())
		virus_log.virus_message(message)

		WRITE_LOG(GLOB.world_virus_log, virus_log.to_text())

/// Returns a string for admin logging uses, should describe the disease in detail
/datum/disease/proc/admin_details()
	return "[src.name] : [src.type]"

/// Describes this disease to an admin in detail (for logging)
/datum/disease/advance/admin_details()
	var/list/name_symptoms = list()
	for(var/datum/symptom/S in symptoms)
		name_symptoms += S.name
	return "\[[name]\] sym:[english_list(name_symptoms)] r:[totalResistance()] s:[totalStealth()] ss:[totalStageSpeed()] t:[totalTransmittable()]"
