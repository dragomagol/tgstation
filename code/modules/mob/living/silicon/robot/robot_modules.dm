/************************************************************************************************
 * This is specifically for the behaviours of the modules belonging to the borg.
 * For each of the choosable tools at the borg's disposal, see robot_items.dm and robot_upgrades.dm
 ************************************************************************************************/
/obj/item/robot_model/Initialize()
	. = ..()
	for(var/i in basic_modules)
		var/obj/item/I = new i(src)
		basic_modules += I
		basic_modules -= i
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i

/obj/item/robot_model/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()
	return ..()

/obj/item/robot_model/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in modules)
		O.emp_act(severity)
	..()

/obj/item/robot_model/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/robot_model/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/R = loc
	for(var/module in get_usable_modules())
		if(!(module in R.held_items))
			. += module

/obj/item/robot_model/proc/get_or_create_estorage(storage_type)
	return (locate(storage_type) in storages) || new storage_type(src)

/obj/item/robot_model/proc/add_module(obj/item/I, nonstandard, requires_rebuild)
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/sheet_module = I
		if(ispath(sheet_module.source, /datum/robot_energy_storage))
			sheet_module.source = get_or_create_estorage(sheet_module.source)

		if(istype(sheet_module, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/rglass_module = sheet_module
			if(ispath(rglass_module.glasource, /datum/robot_energy_storage))
				rglass_module.glasource = get_or_create_estorage(rglass_module.glasource)

		if(istype(sheet_module.source))
			sheet_module.cost = max(sheet_module.cost, 1) // Must not cost 0 to prevent div/0 errors.
			sheet_module.is_cyborg = TRUE

	if(I.loc != src)
		I.forceMove(src)
	modules += I
	ADD_TRAIT(I, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(nonstandard)
		added_modules += I
	if(requires_rebuild)
		rebuild_modules()
	return I

/obj/item/robot_model/proc/remove_module(obj/item/I, delete_after)
	basic_modules -= I
	modules -= I
	emag_modules -= I
	added_modules -= I
	rebuild_modules()
	if(delete_after)
		qdel(I)

/obj/item/robot_model/proc/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	for(var/obj/item/I in R.set_model.get_usable_modules())
		if(istype(I, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/F = I
			F.times_used = 0
			F.burnt_out = FALSE
			F.update_icon()
		else if(istype(I, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = I
			if(B.cell)
				B.cell.charge = B.cell.maxcharge
		else if(istype(I, /obj/item/gun/energy))
			var/obj/item/gun/energy/EG = I
			if(!EG.chambered)
				EG.recharge_newshot() //try to reload a new shot.

	R.toner = R.tonermax

/obj/item/robot_model/proc/rebuild_modules() //builds the usable module list from the modules we have
	var/mob/living/silicon/robot/R = loc
	var/list/held_modules = R.held_items.Copy()
	var/active_module = R.set_model.module_active
	R.uneq_all()
	modules = list()
	for(var/obj/item/I in basic_modules)
		add_module(I, FALSE, FALSE)
	if(R.emagged)
		for(var/obj/item/I in emag_modules)
			add_module(I, FALSE, FALSE)
	for(var/obj/item/I in added_modules)
		add_module(I, FALSE, FALSE)
	for(var/i in held_modules)
		if(i)
			R.equip_module_to_slot(i, held_modules.Find(i))
	if(active_module)
		R.select_module(held_modules.Find(active_module))
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()

// -------------------------------------------- Changing between Models
/obj/item/robot_model/proc/transform_to(new_model_type)
	var/mob/living/silicon/robot/R = loc
	var/obj/item/robot_model/RM = new new_model_type(R)
	RM.robot = R
	if(!RM.be_transformed_to(src))
		qdel(RM)
		return
	R.set_model = RM
	R.update_model_innate()
	RM.rebuild_modules()
	R.radio.recalculateChannels()

	INVOKE_ASYNC(RM, .proc/do_transform_animation)
	qdel(src)
	return RM

/obj/item/robot_model/proc/be_transformed_to(obj/item/robot_model/old_model)
	for(var/i in old_model.added_modules)
		added_modules += i
		old_model.added_modules -= i
	did_feedback = old_model.did_feedback
	return TRUE

/obj/item/robot_model/proc/do_transform_animation()
	var/mob/living/silicon/robot/R = loc
	if(R.hat)
		R.hat.forceMove(get_turf(R))
		R.hat = null
	R.cut_overlays()
	R.setDir(SOUTH)
	do_transform_delay()

/obj/item/robot_model/proc/do_transform_delay()
	var/mob/living/silicon/robot/R = loc
	var/prev_lockcharge = R.lockcharge
	sleep(1)
	flick("[R.cyborg_base_icon]_transform", R)
	R.notransform = TRUE
	if(R.locked_transform)
		R.SetLockdown(TRUE)
		R.set_anchored(TRUE)
	R.logevent("Chassis configuration has been set to [name].")
	sleep(1)
	for(var/i in 1 to 4)
		playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
		sleep(7)
	R.SetLockdown(prev_lockcharge)
	R.setDir(SOUTH)
	R.set_anchored(FALSE)
	R.notransform = FALSE
	R.updatehealth()
	R.update_icons()
	R.notify_ai(NEW_MODEL)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_models", 1, R.set_model)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The cyborg mob interacting with the menu
 * * old_module The old cyborg's module
 */
/obj/item/robot_model/proc/check_menu(mob/living/silicon/robot/user, obj/item/robot_model/old_model)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.set_model != old_model)
		return FALSE
	return TRUE

// -------------------------------------------- For model-specific modules
// ---------------------- Miner
/obj/item/robot_model/miner/rebuild_modules()
	. = ..()
	if(!mining_scanner)
		mining_scanner = new(src)

/obj/item/robot_model/miner/Destroy()
	QDEL_NULL(mining_scanner)
	return ..()

// ---------------------- Janitor
/obj/item/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list(/datum/reagent/lube = 250)

/obj/item/robot_model/janitor/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/lightreplacer/LR = locate(/obj/item/lightreplacer) in basic_modules
	if(LR)
		for(var/i in 1 to coeff)
			LR.Charge(R)

	var/obj/item/reagent_containers/spray/cyborg_drying/CD = locate(/obj/item/reagent_containers/spray/cyborg_drying) in basic_modules
	if(CD)
		CD.reagents.add_reagent(/datum/reagent/drying_agent, 5 * coeff)

	var/obj/item/reagent_containers/spray/cyborg_lube/CL = locate(/obj/item/reagent_containers/spray/cyborg_lube) in emag_modules
	if(CL)
		CL.reagents.add_reagent(/datum/reagent/lube, 2 * coeff)

// ---------------------- Security
/obj/item/robot_model/security/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/gun/energy/e_gun/advtaser/cyborg/T = locate(/obj/item/gun/energy/e_gun/advtaser/cyborg) in basic_modules
	if(T)
		if(T.cell.charge < T.cell.maxcharge)
			var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
			T.cell.give(S.e_cost * coeff)
			T.update_icon()
		else
			T.charge_timer = 0

// ---------------------- Service
/obj/item/robot_model/service/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/reagent_containers/O = locate(/obj/item/reagent_containers/food/condiment/enzyme) in basic_modules
	if(O)
		O.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)

// -------------------------------------------- End model modules

/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New(obj/item/robot_model/R = null)
	energy = max_energy
	if(R)
		R.storages |= src
	return

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return 1
		return 2
	else
		return 0

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"

/datum/robot_energy_storage/pipe_cleaner
	max_energy = 50
	recharge_rate = 2
	name = "Pipe Cleaner Synthesizer"
