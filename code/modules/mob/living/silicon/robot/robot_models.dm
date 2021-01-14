/obj/item/robot_model

/obj/item/robot_model/clown

/obj/item/robot_model/engineering

/obj/item/robot_model/janitor

/obj/item/robot_model/medical

/obj/item/robot_model/mining

/obj/item/robot_model/peacekeeper

/obj/item/robot_model/security

/obj/item/robot_model/syndicate

/obj/item/robot_model/syndicate/syndicate/medical

/obj/item/robot_model/syndicate/saboteur

// --------------------------------------------

///This is the subtype that gets created by robot suits. It's needed so that those kind of borgs don't have a useless cell in them
/mob/living/silicon/robot/nocell
	cell = null

/mob/living/silicon/robot/models
	var/set_model = /obj/item/robot_model

/mob/living/silicon/robot/modules/Initialize()
	. = ..()
	module.transform_to(set_model)

/mob/living/silicon/robot/models/medical
	set_model = /obj/item/robot_model/medical
	icon_state = "medical"

/mob/living/silicon/robot/models/engineering
	set_model = /obj/item/robot_model/engineering
	icon_state = "engineer"

/mob/living/silicon/robot/models/security
	set_model = /obj/item/robot_model/security
	icon_state = "sec"

/mob/living/silicon/robot/models/clown
	set_model = /obj/item/robot_model/clown
	icon_state = "clown"

/mob/living/silicon/robot/models/peacekeeper
	set_model = /obj/item/robot_model/peacekeeper
	icon_state = "peace"

/mob/living/silicon/robot/models/miner
	set_model = /obj/item/robot_model/miner
	icon_state = "miner"

/mob/living/silicon/robot/models/janitor
	set_model = /obj/item/robot_model/janitor
	icon_state = "janitor"

// -------------------------------------------- Syndicate Cyborgs
/mob/living/silicon/robot/models/syndicate
	icon_state = "synd_sec"
	faction = list(ROLE_SYNDICATE)
	bubble_icon = "syndibot"
	req_access = list(ACCESS_SYNDICATE)
	lawupdate = FALSE
	scrambledcodes = TRUE // These are rogue borgs.
	ionpulse = TRUE
	var/playstyle_string = "<span class='big bold'>You are a Syndicate assault cyborg!</span><br>\
							<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
							Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
							<i>Help the operatives secure the disk at all costs!</i></b>"
	set_model = /obj/item/robot_model/syndicate
	cell = /obj/item/stock_parts/cell/hyper
	radio = /obj/item/radio/borg/syndicate

/mob/living/silicon/robot/models/syndicate/Initialize()
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	addtimer(CALLBACK(src, .proc/show_playstyle), 5)

/mob/living/silicon/robot/models/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated/syndicate(src)
	return ..()

/mob/living/silicon/robot/models/syndicate/proc/show_playstyle()
	if(playstyle_string)
		to_chat(src, playstyle_string)

/mob/living/silicon/robot/models/syndicate/ResetModule()
	return

/mob/living/silicon/robot/models/syndicate/medical
	icon_state = "synd_medical"
	playstyle_string = "<span class='big bold'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_model = /obj/item/robot_model/syndicate/medical

/mob/living/silicon/robot/models/syndicate/saboteur
	icon_state = "synd_engi"
	playstyle_string = "<span class='big bold'>You are a Syndicate saboteur cyborg!</span><br>\
						<b>You are armed with robust engineering tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your destination tagger will allow you to stealthily traverse the disposal network across the station \
						Your welder will allow you to repair the operatives' exosuits, but also yourself and your fellow cyborgs \
						Your cyborg chameleon projector allows you to assume the appearance and registered name of a Nanotrasen engineering borg, and undertake covert actions on the station \
						Be aware that almost any physical contact or incidental damage will break your camouflage \
						<i>Help the operatives secure the disk at all costs!</i></b>"
	set_model = /obj/item/robot_model/syndicate/saboteur
