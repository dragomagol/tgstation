/// Counter for number of chicken mobs in the universe. Chickens will not lay fertile eggs if it exceeds the MAX_CHICKENS define.
GLOBAL_VAR_INIT(chicken_count, 0)

/mob/living/basic/chicken
	name = "chicken"
	desc = "Hopefully the eggs are good this season."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "pecks"
	response_harm_simple = "peck"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/chicken
	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/fertile = TRUE

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	GLOB.chicken_count++
	AddElement(/datum/element/animal_variety, "chicken", pick("brown", "black", "white"), TRUE)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddComponent(/datum/component/egg_layer,\
		/obj/item/food/egg,\
		list(/obj/item/food/grown/wheat),\
		feed_messages = list("She clucks happily."),\
		lay_messages = EGG_LAYING_MESSAGES,\
		eggs_left = 0,\
		eggs_added_from_eating = rand(1, 4),\
		max_eggs_held = 8,\
		egg_laid_callback = CALLBACK(src, PROC_REF(egg_laid))\
	)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/datum/ai_controller/basic_controller/chicken
	blackboard = list(
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/chicken,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

/mob/living/basic/chicken/Destroy()
	GLOB.chicken_count--
	return ..()

/mob/living/basic/chicken/proc/egg_laid(obj/item/egg)
	if(GLOB.chicken_count <= MAX_CHICKENS && fertile && prob(25))
		egg.AddComponent(/datum/component/fertile_egg,\
			embryo_type = /mob/living/basic/chick,\
			minimum_growth_rate = 1,\
			maximum_growth_rate = 2,\
			total_growth_required = 200,\
			current_growth = 0,\
			location_allowlist = typecacheof(list(/turf)),\
			spoilable = TRUE,\
		)

/mob/living/basic/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "pecks"
	response_harm_simple = "peck"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	health = 3
	maxHealth = 3
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/chick
	/// How much the chick has grown; once it reaches 100 it graduates to chicken
	var/amount_grown = 0

/mob/living/basic/chick/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "chirps!")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/datum/ai_controller/basic_controller/chick
	blackboard = list(
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/chick,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

/mob/living/basic/chick/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(0.5 * seconds_per_tick, 1 * seconds_per_tick)
		if(amount_grown >= 100)
			new /mob/living/basic/chicken(src.loc)
			qdel(src)

/mob/living/basic/chick/holo/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	amount_grown = 0
