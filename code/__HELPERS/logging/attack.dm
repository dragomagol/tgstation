/**
 * Configures a log_entry with given information and writes the textual representation of the
 * datum to the global attack log.
 *
 * Mirrors this log entry to the individual logs for the attacker and victim, if they're mobs.
 */
/proc/log_attack(atom/source, atom/target, action, weapon = null, details = null, list/tags = list())
	if (CONFIG_GET(flag/log_attack))
		var/datum/log_entry/attack/combat/attack_log = new(source, target)
		attack_log.add_tags(tags)
		attack_log.combat_action(action)
		attack_log.combat_weapon(weapon)
		attack_log.combat_details(details)

		WRITE_LOG(GLOB.world_attack_log, attack_log.to_text())

		// If the source and/or target are mobs, add the attack logs to their player logs
		var/mob/living/attacker = source
		if(attacker)
			var/message = attack_log.player_log_text(is_attacker = TRUE)
			attacker.log_message(message, LOG_ATTACK, color = "red", log_globally = FALSE)

		var/mob/living/defender = target
		if(defender && attacker != defender)
			var/reverse_message = attack_log.player_log_text(is_attacker = FALSE)
			defender.log_message(reverse_message, LOG_VICTIM, color = "orange", log_globally = FALSE)

/**
 * log_conversion() is for joining a new team, such as a hypnotized victim, cultist, or thrall
 * This also falls under the log_attack() umbrella
 *
 * inductee - The person who was converted
 * faction - What the inductee is converted to
 */
/proc/log_conversion(mob/inductee, action, details = null, list/tags = list())
	if (CONFIG_GET(flag/log_attack))
		var/datum/log_entry/attack/conversion/convert_log = new(inductee, action)
		convert_log.add_tags(tags)
		convert_log.conversion_action(action)
		convert_log.conversion_details(details)

		WRITE_LOG(GLOB.world_attack_log, convert_log.to_text())

		// Add the attack logs to their player logs
		var/mob/converted = inductee
		if(converted)
			var/message = convert_log.player_log_text()
			converted.log_message(message, LOG_ATTACK, color = "green", log_globally = FALSE)

/**
 * log_death() is for logging a death
 * This also falls under the log_attack() umbrella
 *
 * corpse - The person who has died
 * cause - cause of death (suicide, succumbing)
 */
/proc/log_death(mob/living/corpse, cause)
	if (CONFIG_GET(flag/log_attack))
		var/datum/log_entry/attack/death/death_log = new(corpse)
		death_log.death_cause(cause)

		WRITE_LOG(GLOB.world_attack_log, death_log.to_text())

		// Add the attack logs to their player logs
		var/mob/torso = corpse
		if(torso)
			var/message = death_log.player_log_text()
			torso.log_message(message, LOG_ATTACK, color = "red", log_globally = FALSE)

/**
 * log_wound() is for when someone is *attacked* and suffers a wound. Note that this only captures wounds from damage, so smites/forced wounds aren't logged, as well as demotions like cuts scabbing over
 *
 * Note that this has no info on the attack that dealt the wound: information about where damage came from isn't passed to the bodypart's damaged proc. When in doubt, check the attack log for attacks at that same time
 *
 * Arguments:
 * * victim - The person who got wounded
 * * suffered_wound - The wound, already applied, that we're logging. It has to already be attached so we can get the limb from it
 * * dealt_damage - How much damage is associated with the attack that dealt with this wound.
 * * dealt_wound_bonus - The wound_bonus, if one was specified, of the wounding attack
 * * dealt_bare_wound_bonus - The bare_wound_bonus, if one was specified *and applied*, of the wounding attack. Not shown if armor was present
 * * base_roll - Base wounding ability of an attack is a random number from 1 to (dealt_damage ** WOUND_DAMAGE_EXPONENT). This is the number that was rolled in there, before mods
 */
/proc/log_wound(atom/victim, datum/wound/suffered_wound, dealt_damage, dealt_wound_bonus, dealt_bare_wound_bonus, base_roll)
	if (CONFIG_GET(flag/log_attack))
		if(QDELETED(victim) || !suffered_wound)
			return

		var/datum/log_entry/attack/wound/wound_log = new(victim)

		wound_log.wound_type(suffered_wound)
		wound_log.wound_damage(dealt_damage)
		wound_log.wound_bonus(dealt_wound_bonus)
		wound_log.wound_bare_bonus(dealt_bare_wound_bonus)
		wound_log.wound_base_roll(base_roll)

		WRITE_LOG(GLOB.world_attack_log, wound_log.to_text())

		// Add the attack logs to their player logs
		var/mob/torso = victim
		if(torso)
			torso.log_message(wound_log.player_log_text(), LOG_ATTACK, color = "#6c80f0")
