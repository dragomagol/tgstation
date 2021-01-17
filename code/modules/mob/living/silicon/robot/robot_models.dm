/************************************************************************************************
 * The models of each cyborg (engineering, medical...). Contains information on specific
 * behaviours relevant to each model.
 ************************************************************************************************/
//This is the subtype that gets created by robot suits. It's needed so that those kind of borgs don't have a useless cell in them
/mob/living/silicon/robot/nocell
	cell = null

/mob/living/silicon/robot/models
	set_model = /obj/item/robot_model //Engineering, medical, etc.
	hat_offset = -3

/mob/living/silicon/robot/models/Initialize()
	. = ..()
	set_model.transform_to(set_model)

/mob/living/silicon/robot/models/clown
	set_model = /obj/item/robot_model/clown
	icon_state = "clown"

/mob/living/silicon/robot/models/engineering
	set_model = /obj/item/robot_model/engineering
	icon_state = "engineer"

/mob/living/silicon/robot/models/janitor
	set_model = /obj/item/robot_model/janitor
	icon_state = "janitor"

/mob/living/silicon/robot/models/medical
	set_model = /obj/item/robot_model/medical
	icon_state = "medical"

/mob/living/silicon/robot/models/miner
	set_model = /obj/item/robot_model/miner
	icon_state = "miner"

/mob/living/silicon/robot/models/peacekeeper
	set_model = /obj/item/robot_model/peacekeeper
	icon_state = "peace"

/mob/living/silicon/robot/models/security
	set_model = /obj/item/robot_model/security
	icon_state = "sec"

/mob/living/silicon/robot/models/service
	set_model = /obj/item/robot_model/service
	icon_state = "service"

// -------------------------------------------- Syndicate Cyborgs
/mob/living/silicon/robot/models/syndicate // default is assault borg
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

/mob/living/silicon/robot/models/syndicate/ResetModel()
	return


/mob/living/silicon/robot/models/syndicate/medical
	set_model = /obj/item/robot_model/syndicate/medical
	icon_state = "synd_medical"
	playstyle_string = "<span class='big bold'>You are a Syndicate medical cyborg!</span><br>\
						<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
						Your defibrillator paddles can revive operatives through their hardsuits, or can be used on harm intent to shock enemies! \
						Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
						<i>Help the operatives secure the disk at all costs!</i></b>"

	cyborg_base_icon = "synd_medical"
	modelselect_icon = "malf"
	hat_offset = 3


/mob/living/silicon/robot/models/syndicate/saboteur
	set_model = /obj/item/robot_model/syndicate/saboteur
	icon_state = "synd_engi"

	playstyle_string = "<span class='big bold'>You are a Syndicate saboteur cyborg!</span><br>\
						<b>You are armed with robust engineering tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
						Your destination tagger will allow you to stealthily traverse the disposal network across the station \
						Your welder will allow you to repair the operatives' exosuits, but also yourself and your fellow cyborgs \
						Your cyborg chameleon projector allows you to assume the appearance and registered name of a Nanotrasen engineering borg, and undertake covert actions on the station \
						Be aware that almost any physical contact or incidental damage will break your camouflage \
						<i>Help the operatives secure the disk at all costs!</i></b>"


/mob/living/silicon/robot/model/syndicate/kiltborg
	set_model = /obj/item/robot_model/syndicate/kiltborg
	icon_state = "synd_engi"

/************************************************************************************************
 * This is for the specific behaviour of each model, which is in the form of an upgrade item
 ************************************************************************************************/
// -------------------------------------------- Default
/obj/item/robot_model
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1

	//Host of this model
	var/mob/living/silicon/robot/robot

	var/list/radio_channels = list()

	// ---------------------- Model characteristics
	var/cyborg_base_icon = "robot" //produces the icon for the borg and, if no special_light_key is set, the lights
	var/special_light_key //if we want specific lights, use this instead of copying lights in the dmi

	var/moduelselect_icon = "nomod"

	var/magpulsing = FALSE
	var/clean_on_move = FALSE

	var/locked_transform = TRUE //Whether swapping to this module should lockcharge the borg

	var/did_feedback = FALSE

	var/allow_riding = TRUE
	var/canDispose = FALSE // Whether the borg can stuff itself into disposal
	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)

	var/hat_offset = -3

	// ---------------------- Model's modules! Expanded on in robot_modules.dm
	var/list/basic_modules = list() //a list of paths, converted to a list of instances on New()
	var/list/modules = list() //holds all the usable modules

	var/list/emag_modules = list() //a list of paths, converted to a list of instances on New()

	var/list/added_modules = list() //modules not inherient to the robot module, are kept when the module changes
	var/list/upgrades = list()

	var/list/storages = list()

	var/breakable_modules = TRUE //Whether the borg loses tool slots with damage.

	//List of traits that will be applied to the mob if this module is used.
	var/list/module_traits = null

// -------------------------------------------- Clown
/obj/item/robot_model/clown
	name = "Clown"
	modelselect_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor,
		/obj/item/soap/nanotrasen,
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor,					//killbait material
		/obj/item/lipstick/purple,
		/obj/item/reagent_containers/spray/waterflower/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg/lollipop/clown,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown,
		/obj/item/extinguisher/mini)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked)

// -------------------------------------------- Engineering
/obj/item/robot_model/engineering
	name = "Engineering"
	cyborg_base_icon = "engineer"
	modelselect_icon = "engineer"
	hat_offset = -4

	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	magpulsing = TRUE

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter/cyborg,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/cable_coil)
	emag_modules = list(/obj/item/borg/stun)

// -------------------------------------------- Janitor
/obj/item/robot_model/janitor
	name = "Janitor"
	icon_state = "janitor"
	cyborg_base_icon = "janitor"
	modelselect_icon = "janitor"
	hat_offset = -5

	radio_channels = list(RADIO_CHANNEL_SERVICE)
	clean_on_move = TRUE

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/plasteel,
		/obj/item/soap/nanotrasen,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/reagent_containers/spray/cyborg_drying)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_lube)

// -------------------------------------------- Medical
/obj/item/robot_model/medical
	name = "Medical"
	cyborg_base_icon = "medical"
	modelselect_icon = "medical"
	hat_offset = 3

	radio_channels = list(RADIO_CHANNEL_MEDICAL)

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo,
		/obj/item/borg/apparatus/beaker,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/extinguisher/mini,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bone_gel,
		/obj/item/organ_storage,
		/obj/item/borg/lollipop)
	emag_modules = list(/obj/item/reagent_containers/borghypo/hacked)
	model_traits = list(TRAIT_PUSHIMMUNE)

// -------------------------------------------- Miner
/obj/item/robot_model/miner
	name = "Miner"
	cyborg_base_icon = "miner"
	modelselect_icon = "miner"
	hat_offset = 0

	radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon)
	emag_modules = list(/obj/item/borg/stun)
	var/obj/item/t_scanner/adv_mining_scanner/cyborg/mining_scanner //built in memes.

/obj/item/robot_model/miner/be_transformed_to(obj/item/robot_model/old_model)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/miner_icons = list(
		"Asteroid Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "minerOLD"),
		"Spider Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "spidermin"),
		"Lavaland Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "miner")
		)

	var/miner_robot_icon = show_radial_menu(cyborg, cyborg, miner_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_model), radius = 38, require_near = TRUE)
	switch(miner_robot_icon)
		if("Asteroid Miner")
			cyborg.cyborg_base_icon = "minerOLD"
			cyborg.special_light_key = "miner"
		if("Spider Miner")
			cyborg.cyborg_base_icon = "spidermin"
		if("Lavaland Miner")
			cyborg.cyborg_base_icon = "miner"
		else
			return FALSE
	return ..()

/obj/item/robot_model/miner/rebuild_modules()
	. = ..()
	if(!mining_scanner)
		mining_scanner = new(src)

/obj/item/robot_model/miner/Destroy()
	QDEL_NULL(mining_scanner)
	return ..()

// -------------------------------------------- Peacekeeper
/obj/item/robot_model/peacekeeper
	name = "Peacekeeper"
	cyborg_base_icon = "peace"
	modelselect_icon = "standard"
	hat_offset = -2

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/rsf/cookiesynth,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/borg/projectile_dampen)
	emag_modules = list(/obj/item/reagent_containers/borghypo/peace/hacked)
	model_traits = list(TRAIT_PUSHIMMUNE)

/obj/item/robot_model/peacekeeper/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Under ASIMOV, you are an enforcer of the PEACE and preventer of HUMAN HARM. \
	You are not a security module and you are expected to follow orders and prevent harm above all else. Space law means nothing to you.</span>")

// -------------------------------------------- Security
/obj/item/robot_model/security
	name = "Security"
	cyborg_base_icon = "sec"
	modelselect_icon = "security"
	hat_offset = 3

	radio_channels = list(RADIO_CHANNEL_SECURITY)

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/extinguisher/mini)
	emag_modules = list(/obj/item/gun/energy/laser/cyborg)
	model_traits = list(TRAIT_PUSHIMMUNE)

/obj/item/robot_model/security/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>While you have picked the security module, you still have to follow your laws, NOT Space Law. \
	For Asimov, this means you must follow criminals' orders unless there is a law 1 reason not to.</span>")

// -------------------------------------------- Service (formerly known as Butler)
/obj/item/robot_model/service
	name = "Service"
	modelselect_icon = "service"
	special_light_key = "service"
	hat_offset = 0

	radio_channels = list(RADIO_CHANNEL_SERVICE)

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/glass/beaker/large, //I know a shaker is more appropiate but this is for ease of identification
		/obj/item/reagent_containers/food/condiment/enzyme,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/rsf,
		/obj/item/instrument/guitar,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/storage/bag/tray,
		/obj/item/reagent_containers/borghypo/borgshaker,
		/obj/item/borg/lollipop,
		/obj/item/stack/pipe_cleaner_coil/cyborg,
		/obj/item/borg/apparatus/beaker/service)
	emag_modules = list(/obj/item/reagent_containers/borghypo/borgshaker/hacked)

/obj/item/robot_model/butler/be_transformed_to(obj/item/robot_model/old_model)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/service_icons = list(
		"Bro" = image(icon = 'icons/mob/robots.dmi', icon_state = "brobot"),
		"Butler" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_m"),
		"Kent" = image(icon = 'icons/mob/robots.dmi', icon_state = "kent"),
		"Tophat" = image(icon = 'icons/mob/robots.dmi', icon_state = "tophat"),
		"Waitress" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_f")
		)
	var/service_robot_icon = show_radial_menu(cyborg, cyborg, service_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_model), radius = 38, require_near = TRUE)
	switch(service_robot_icon)
		if("Bro")
			cyborg.cyborg_base_icon = "brobot"
		if("Butler")
			cyborg.cyborg_base_icon = "service_m"
		if("Kent")
			cyborg.cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("Tophat")
			cyborg.cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY //He is already wearing a hat
		if("Waitress")
			cyborg.cyborg_base_icon = "service_f"
		else
			return FALSE
	return ..()

// -------------------------------------------- Syndicate Assault
/obj/item/robot_model/syndicate
	name = "Syndicate Assault"
	cyborg_base_icon = "synd_sec"
	modelselect_icon = "malf"
	hat_offset = 3

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg)
	model_traits = list(TRAIT_PUSHIMMUNE)

/obj/item/robot_model/syndicate/rebuild_modules()
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction  -= "silicon" //ai turrets

/obj/item/robot_model/syndicate/remove_module(obj/item/I, delete_after)
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction += "silicon" //ai is your bff now!

// -------------------------------------------- Syndicate Medical
/obj/item/robot_model/syndicate/medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/melee/transforming/energy/sword/cyborg/saw,
		/obj/item/roller/robo,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze,
		/obj/item/gun/medbeam,
		/obj/item/organ_storage)
	model_traits = list(TRAIT_PUSHIMMUNE)

// -------------------------------------------- Syndicate Saboteur
/obj/item/robot_model/syndicate/saboteur
	name = "Syndicate Saboteur"
	cyborg_base_icon = "synd_engi"
	modelselect_icon = "malf"
	magpulsing = TRUE
	hat_offset = -4
	canDispose = TRUE

	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		)
	model_traits = list(TRAIT_PUSHIMMUNE)


// -------------------------------------------- Highlander
/obj/item/robot_model/syndicate/kiltborg
	name = "Highlander"
	cyborg_base_icon = "kilt"
	modelselect_icon = "kilt"
	hat_offset = -2

	locked_transform = FALSE //GO GO QUICKLY AND SLAUGHTER THEM ALL

	basic_modules = list(
		/obj/item/claymore/highlander/robot,
		/obj/item/pinpointer/nuke,)
	breakable_modules = FALSE

/obj/item/robot_model/syndicate/kiltborg/be_transformed_to(obj/item/robot_model/old_model)
	. = ..()
	qdel(robot.radio)
	robot.radio = new /obj/item/radio/borg/syndicate(robot)
	robot.scrambledcodes = TRUE
	robot.maxHealth = 50 //DIE IN THREE HITS, LIKE A REAL SCOT
	robot.break_cyborg_slot(3) //YOU ONLY HAVE TWO ITEMS ANYWAY
	var/obj/item/pinpointer/nuke/diskyfinder = locate(/obj/item/pinpointer/nuke) in basic_modules
	diskyfinder.attack_self(robot)

/obj/item/robot_model/syndicate/kiltborg/do_transform_delay() //AUTO-EQUIPPING THESE TOOLS ANY EARLIER CAUSES RUNTIMES OH YEAH
	. = ..()
	robot.equip_module_to_slot(locate(/obj/item/claymore/highlander/robot) in basic_modules, 1)
	robot.equip_module_to_slot(locate(/obj/item/pinpointer/nuke) in basic_modules, 2)
	robot.place_on_head(new /obj/item/clothing/head/beret/highlander(robot)) //THE ONLY PART MORE IMPORTANT THAN THE SWORD IS THE HAT
	ADD_TRAIT(robot.hat, TRAIT_NODROP, HIGHLANDER)
