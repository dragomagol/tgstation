/**
 * log_econ()
 *
 * Arguments:
 * * buyer - the person who is transferring credits
 * * seller - the person (or budget) receiving credits
 * * credits - the number of credits exchanged
 * * account_owner - who owns the account being transfered to
 * * purchased_item - what was bought (if applicable)
 */
/proc/log_econ(atom/buyer, atom/seller, credits, account_owner = null, purchased_item = null)
	if (CONFIG_GET(flag/log_econ))
		var/datum/log_entry/economy/transaction/purchase_log = new(buyer, seller)

		purchase_log.transaction_credits(credits)
		purchase_log.transaction_account_owner(account_owner)
		purchase_log.transaction_purchased_item(purchased_item)

		WRITE_LOG(GLOB.world_econ_log, purchase_log.to_text())

/// Logs a round-end summary report
/proc/log_econ_summary(report, credits)
	if (CONFIG_GET(flag/log_econ))
		var/datum/log_entry/economy/round_end/round_end_log = new()

		round_end_log.round_end_report(report)
		round_end_log.round_end_credits(credits)

		WRITE_LOG(GLOB.world_econ_log, round_end_log.to_text())
