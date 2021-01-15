/**
 * The models of each cyborg (engineering, medical...). Contains information on what modules each model gets,
 * as well as other specific behaviours relevant to each model.
 */

//This is the subtype that gets created by robot suits. It's needed so that those kind of borgs don't have a useless cell in them
/mob/living/silicon/robot/nocell
	cell = null

/mob/living/silicon/robot/models
	set_model = /obj/item/robot_model //Engineering, medical, etc.
	hat_offset = -3

/mob/living/silicon/robot/models/Initialize()
	. = ..()
	module.transform_to(set_model)

/mob/living/silicon/robot/models/clown
	set_model = /obj/item/robot_model/clown
	icon_state = "clown"
	modelselect_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2


/mob/living/silicon/robot/models/engineering
	set_model = /obj/item/robot_model/engineering
	icon_state = "engineer"
	cyborg_base_icon = "engineer"
	modelselect_icon = "engineer"
	hat_offset = -4

	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	magpulsing = TRUE


/mob/living/silicon/robot/models/janitor
	set_model = /obj/item/robot_model/janitor
	icon_state = "janitor"
	cyborg_base_icon = "janitor"
	modelselect_icon = "janitor"
	hat_offset = -5

	radio_channels = list(RADIO_CHANNEL_SERVICE)
	clean_on_move = TRUE


/mob/living/silicon/robot/models/medical
	set_model = /obj/item/robot_model/medical
	icon_state = "medical"
	cyborg_base_icon = "medical"
	modelselect_icon = "medical"
	hat_offset = 3

	radio_channels = list(RADIO_CHANNEL_MEDICAL)


/mob/living/silicon/robot/models/miner
	set_model = /obj/item/robot_model/miner
	icon_state = "miner"
	cyborg_base_icon = "miner"
	modelselect_icon = "miner"
	hat_offset = 0

	robot.radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)


mob/living/silicon/robot/models/miner/be_transformed_to(obj/item/robot_model/old_model)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/miner_icons = list(
		"Asteroid Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "minerOLD"),
		"Spider Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "spidermin"),
		"Lavaland Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "miner")
		)
	var/miner_robot_icon = show_radial_menu(cyborg, cyborg, miner_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_model), radius = 38, require_near = TRUE)
	switch(miner_robot_icon)
		if("Asteroid Miner")
			cyborg_base_icon = "minerOLD"
			special_light_key = "miner"
		if("Spider Miner")
			cyborg_base_icon = "spidermin"
		if("Lavaland Miner")
			cyborg_base_icon = "miner"
		else
			return FALSE
	return ..()


/mob/living/silicon/robot/models/peacekeeper
	set_model = /obj/item/robot_model/peacekeeper
	icon_state = "peace"
	cyborg_base_icon = "peace"
	modelselect_icon = "standard"
	at_offset = -2


/mob/living/silicon/robot/models/security
	set_model = /obj/item/robot_model/security
	icon_state = "sec"
	cyborg_base_icon = "sec"
	modelselect_icon = "security"
	hat_offset = 3

	radio_channels = list(RADIO_CHANNEL_SECURITY)


/mob/living/silicon/robot/models/service
	set_model = /obj/item/robot_model/service
	icon_state = "service"
	robot.modelselect_icon = "service"
	robot.special_light_key = "service"
	robot.hat_offset = 0

	robot.radio_channels = list(RADIO_CHANNEL_SERVICE)


/mob/living/silicon/robot/models/service/be_transformed_to(obj/item/robot_model/old_model)
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
			cyborg_base_icon = "brobot"
		if("Butler")
			cyborg_base_icon = "service_m"
		if("Kent")
			cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("Tophat")
			cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY //He is already wearing a hat
		if("Waitress")
			cyborg_base_icon = "service_f"
		else
			return FALSE
	return ..()


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


/mob/living/silicon/robot/models/syndicate/kiltborg
	set_model = /obj/item/robot_model/kiltborg
	icon_state = "kiltborg"

/mob/living/silicon/robot/models/be_transformed_to(obj/item/robot_module/old_module)
	. = ..()
	qdel(robot.radio)
	radio = new /obj/item/radio/borg/syndicate(robot)
	scrambledcodes = TRUE
	maxHealth = 50 //DIE IN THREE HITS, LIKE A REAL SCOT
	break_cyborg_slot(3) //YOU ONLY HAVE TWO ITEMS ANYWAY
	var/obj/item/pinpointer/nuke/diskyfinder = locate(/obj/item/pinpointer/nuke) in robot.basic_modules
	diskyfinder.attack_self(robot)

/mob/living/silicon/robot/models/do_transform_delay() //AUTO-EQUIPPING THESE TOOLS ANY EARLIER CAUSES RUNTIMES OH YEAH
	. = ..()
	equip_module_to_slot(locate(/obj/item/claymore/highlander/robot) in basic_modules, 1)
	equip_module_to_slot(locate(/obj/item/pinpointer/nuke) in basic_modules, 2)
	place_on_head(new /obj/item/clothing/head/beret/highlander(robot)) //THE ONLY PART MORE IMPORTANT THAN THE SWORD IS THE HAT
	ADD_TRAIT(robot.hat, TRAIT_NODROP, HIGHLANDER)


// This is for the specific behaviour of each model, which is in the form of an upgrade item
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

 	/**
	* List of traits that will be applied to the mob if this module is used.
	*/
	var/list/model_traits = null

	//Host of this model
	var/mob/living/silicon/robot/robot

	// Model's modules!
	var/obj/item/module_active = null
	held_items = list(null, null, null) //we use held_items for the module holding, because that makes sense to do!

	var/breakable_modules = TRUE // Whether the borg loses tool slots with damage.
	var/disabled_modules // For checking which modules (1, 2, 3) are disabled or not.

	var/list/basic_modules = list() //a list of paths, converted to a list of instances on New()
	var/list/modules = list() //holds all the usable modules for this model (incl upgrades)

	var/list/added_modules = list() //modules not inherent to the robot model, are kept when the model changes
	var/list/upgrades = list()
	var/list/emag_modules = list() //a list of paths, converted to a list of instances on New()

// -------------------------------------------- Clown
/obj/item/robot_model/clown
	name = "Clown"
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

// -------------------------------------------- Peacekeeper
/obj/item/robot_model/peacekeeper
	name = "Peacekeeper"
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
	robot.model_traits = list(TRAIT_PUSHIMMUNE)

/obj/item/robot_module/peacekeeper/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Under ASIMOV, you are an enforcer of the PEACE and preventer of HUMAN HARM. \
	You are not a security module and you are expected to follow orders and prevent harm above all else. Space law means nothing to you.</span>")

// -------------------------------------------- Security
/obj/item/robot_model/security
	name = "Security"
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

// -------------------------------------------- Syndicate Assault
/obj/item/robot_model/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg)

	robot.cyborg_base_icon = "synd_sec"
	robot.modelselect_icon = "malf"
	robot.model_traits = list(TRAIT_PUSHIMMUNE)
	hrobot.at_offset = 3

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

	robot.cyborg_base_icon = "synd_medical"
	robot.modelselect_icon = "malf"
	robot.model_traits = list(TRAIT_PUSHIMMUNE)
	robot.hat_offset = 3

// -------------------------------------------- Syndicate Saboteur
/obj/item/robot_model/syndicate/saboteur
	name = "Syndicate Saboteur"
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

	robot.cyborg_base_icon = "synd_engi"
	robot.modelselect_icon = "malf"
	model_traits = list(TRAIT_PUSHIMMUNE)
	robot.magpulsing = TRUE
	robot.hat_offset = -4
	robot.canDispose = TRUE

// -------------------------------------------- Highlander
/obj/item/robot_model/syndicate/kiltborg
	name = "Highlander"
	basic_modules = list(
		/obj/item/claymore/highlander/robot,
		/obj/item/pinpointer/nuke,)
	robot.cyborg_base_icon = "kilt"
	robot.modelselect_icon = "kilt"
	robot.hat_offset = -2
	robot.breakable_modules = FALSE
	robot.locked_transform = FALSE //GO GO QUICKLY AND SLAUGHTER THEM ALL
