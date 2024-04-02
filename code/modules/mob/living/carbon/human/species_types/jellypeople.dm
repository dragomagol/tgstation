///The rate at which slimes regenerate their jelly normally
#define JELLY_REGEN_RATE 1.5
///The rate at which slimes regenerate their jelly when they completely run out of it and start taking damage, usually after having cannibalized all their limbs already
#define JELLY_REGEN_RATE_EMPTY 2.5
///The blood volume at which slimes begin to start losing nutrition -- so that IV drips can work for blood deficient slimes
#define BLOOD_VOLUME_LOSE_NUTRITION 550

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "\improper Jellyperson"
	plural_form = "Jellypeople"
	id = SPECIES_JELLYPERSON
	examine_limb_id = SPECIES_JELLYPERSON
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_SLIME
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_TOXINLOVER,
		TRAIT_NOBLOOD,
	)
	mutanttongue = /obj/item/organ/internal/tongue/jelly
	mutantlungs = /obj/item/organ/internal/lungs/slime
	mutanteyes = /obj/item/organ/internal/eyes/jelly
	mutantheart = null
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	blood_deficiency_drain_rate = JELLY_REGEN_RATE + BLOOD_DEFICIENCY_MODIFIER
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_factions = list(FACTION_SLIME)
	species_language_holder = /datum/language_holder/jelly
	hair_color_mode = USE_MUTANT_COLOR
	hair_alpha = 150
	facial_hair_alpha = 150
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly,
	)
	var/datum/action/innate/regenerate_limbs/regenerate_limbs

/datum/species/jelly/on_species_gain(mob/living/carbon/new_jellyperson, datum/species/old_species, pref_load)
	. = ..()
	if(ishuman(new_jellyperson))
		regenerate_limbs = new
		regenerate_limbs.Grant(new_jellyperson)
	new_jellyperson.AddElement(/datum/element/soft_landing)
	RegisterSignal(new_jellyperson, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(slime_blood))

/datum/species/jelly/on_species_loss(mob/living/carbon/former_jellyperson, datum/species/new_species, pref_load)
	if(regenerate_limbs)
		regenerate_limbs.Remove(former_jellyperson)
	former_jellyperson.RemoveElement(/datum/element/soft_landing)
	UnregisterSignal(former_jellyperson, COMSIG_HUMAN_ON_HANDLE_BLOOD)
	return ..()

/datum/species/jelly/proc/slime_blood(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(slime.stat == DEAD)
		return HANDLE_BLOOD_HANDLED

	if(slime.blood_volume <= 0)
		slime.blood_volume += JELLY_REGEN_RATE_EMPTY * seconds_per_tick
		slime.adjustBruteLoss(2.5 * seconds_per_tick)
		to_chat(slime, span_danger("You feel empty!"))

	if(slime.blood_volume < BLOOD_VOLUME_NORMAL)
		if(slime.nutrition >= NUTRITION_LEVEL_STARVING)
			slime.blood_volume += JELLY_REGEN_RATE * seconds_per_tick
			if(slime.blood_volume <= BLOOD_VOLUME_LOSE_NUTRITION) // don't lose nutrition if we are above a certain threshold, otherwise slimes on IV drips will still lose nutrition
				slime.adjust_nutrition(-1.25 * seconds_per_tick)

	if(slime.blood_volume < BLOOD_VOLUME_OKAY)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(slime, span_danger("You feel drained!"))

	if(slime.blood_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(slime)

	regenerate_limbs?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	return HANDLE_BLOOD_NO_NUTRITION_DRAIN|HANDLE_BLOOD_NO_EFFECTS

/datum/species/jelly/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!length(limbs_to_consume))
		H.losebreath++
		return
	if(H.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, span_userdanger("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	H.blood_volume += 20

/datum/species/jelly/get_species_description()
	return "Jellypeople are a strange and alien species with three eyes, made entirely out of gel."

/datum/species/jelly/get_species_lore()
	return list(
		"Jellypeople are actively being experimented on my Nanotrasen scientists, who are trying to unlock the secrets of their unique biology.",
	)

/datum/species/jelly/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = COLOR_PINK
	human.hairstyle = "Bob Hair 2"
	human.hair_color = COLOR_PINK
	human.update_body(is_creating = TRUE)

// Slimes have both TRAIT_NOBLOOD and an exotic bloodtype set, so they need to be handled uniquely here.
// They may not be roundstart but in the unlikely event they become one might as well not leave a glaring issue open.
/datum/species/jelly/create_pref_blood_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Jelly Blood",
		SPECIES_PERK_DESC = "[plural_form] don't have blood, but instead have toxic [initial(exotic_blood.name)]! \
			Jelly is extremely important, as losing it will cause you to lose limbs. Having low jelly will make medical treatment very difficult.",
	))

	return to_add

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
		return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("You feel intact enough as it is."))
		return
	to_chat(H, span_notice("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(H.blood_volume >= 40*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		H.blood_volume -= 40*length(limbs_to_heal)
		to_chat(H, span_notice("...and after a moment you finish reforming!"))
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		to_chat(H, span_warning("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to heal!"))

#undef JELLY_REGEN_RATE
#undef JELLY_REGEN_RATE_EMPTY
#undef BLOOD_VOLUME_LOSE_NUTRITION
