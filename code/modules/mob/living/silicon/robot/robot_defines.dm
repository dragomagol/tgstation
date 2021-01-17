/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	bubble_icon = "robot"
	designation = "Default" //used for displaying the prefix & getting the current module of cyborg
	has_limbs = 1
	hud_type = /datum/hud/robot

	var/custom_name = ""
	var/braintype = "Cyborg"
	var/obj/item/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/obj/item/mmi/mmi = null

	// at some point i am definitely going to be annoyed about this being here
	held_items = list(null, null, null) //we use held_items for the module holding, because that makes sense to do!

	var/shell = FALSE
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	var/datum/action/innate/undeployment/undeployment_action = new

	/// the last health before updating - to check net change in health
	var/previous_health

	radio = /obj/item/radio/borg
	var/list/radio_channels = list()

	var/mutable_appearance/eye_lights
	var/special_light_key //if we want specific lights, use this instead of copying lights in the dmi
	var/cyborg_base_icon = "robot" //produces the icon for the borg and, if no special_light_key is set, the lights

	///If the lamp isn't broken.
	var/lamp_functional = TRUE
	///If the lamp is turned on
	var/lamp_enabled = FALSE
	///Set lamp color
	var/lamp_color = COLOR_WHITE
	///Set to true if a doomsday event is locking our lamp to on and RED
	var/lamp_doom = FALSE
	///Lamp brightness. Starts at 3, but can be 1 - 5.
	var/lamp_intensity = 3
	///Lamp button reference
	var/atom/movable/screen/robot/lamp/lampButton

	var/sight_mode = 0
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD)

	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

// Hud stuff
	var/atom/movable/screen/inv1 = null
	var/atom/movable/screen/inv2 = null
	var/atom/movable/screen/inv3 = null
	var/atom/movable/screen/hands = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/atom/movable/screen/robot_modules_background

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high ///If this is a path, this gets created as an object in Initialize.

	var/opened = FALSE
	var/emagged = FALSE
	var/emag_cooldown = 0
	var/wiresexposed = FALSE

	var/lawupdate = TRUE //Cyborgs will sync their laws with their AI by default
	var/scrambledcodes = FALSE // Used to determine if a borg shows up on the robotics console.  Setting to TRUE hides them.
	var/lockcharge = FALSE //Boolean of whether the borg is locked down or not

	/// Random serial number generated for each cyborg upon its initialization
	var/ident = 0
	var/locked = TRUE
	var/list/req_access = list(ACCESS_ROBOTICS)

	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())

	var/ionpulse = FALSE // Jetpack-like effect.
	var/ionpulse_on = FALSE // Jetpack-like effect.
	var/datum/effect_system/trail_follow/ion/ion_trail // Ionpulse effect.

	var/low_power_mode = 0 //whether the robot has no charge left.
	var/datum/effect_system/spark_spread/spark_system // So they can initialize sparks whenever/N

	var/toner = 0
	var/tonermax = 40

	///The reference to the built-in tablet that borgs carry.
	var/obj/item/modular_computer/tablet/integrated/modularInterface
	var/atom/movable/screen/robot/modPC/interfaceButton

// Model
	var/obj/item/robot_model/set_model = null
	var/modelselect_icon = "nomod"

	var/clean_on_move = FALSE

	var/magpulse = FALSE // Magboot-like effect.
	var/magpulsing = FALSE

	var/locked_transform = TRUE //Whether swapping to this module should lockcharge the borg

	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	var/allow_riding = TRUE
	var/canDispose = FALSE // Whether the borg can stuff itself into disposal

	var/hasExpanded = FALSE
	var/obj/item/hat
	var/hat_offset = -3

	can_buckle = TRUE
	buckle_lying = 0
	/// What types of mobs are allowed to ride/buckle to this mob
	var/static/list/can_ride_typecache = typecacheof(/mob/living/carbon/human)
