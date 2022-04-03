SUBSYSTEM_DEF(logging)
	name = "Logging"
	init_order = INIT_ORDER_LOGGING

	var/list/print_queue

/datum/controller/subsystem/logging/Initialize(timeofday)
	print_queue = list()
	return ..()

/// Put the log entry onto the logging queue to be printed
/datum/controller/subsystem/logging/proc/queue_log(var/datum/log_entry/entry)
	/// TODO: Make sure this item isn't already in the queue?
	print_queue += entry.clone()
	return

/// Dequeue a log and print it
/datum/controller/subsystem/logging/fire()
	// Nothing in queue
	if (!length(print_queue))
		return

	// dequeue item & process
	var/datum/log_entry/current_item = print_queue[1]
	message_admins(current_item.to_text())
	message_admins(current_item.to_json())
	print_queue.Cut(1,2)
	return

/// Process this entry immediately (for things like admin notifications)
/datum/controller/subsystem/logging/proc/log_priority()
	// do something
	return
