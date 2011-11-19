/obj/machinery/mining/energyconverter
	name = "energy converter"
	icon = 'heat_exchanger.dmi'
	icon_state = "intact"
	desc = "A crystal energy converter."
	density = 1
	anchored = 1
	var/crystal_powerpercent = 0.2
	var/disabled = 0
	var/input_area
	var/output_area
	var/smes_found = 0
	var/obj/machinery/power/smes/connected_smes
	// dir is always the direction to the SMES unit

/obj/machinery/mining/energyconverter/New()
	spawn (30)
		// Set the in-and output areas
		if(dir == NORTH)
			input_area = locate(x, y-1, z)
			output_area = locate(x, y+1, z)
		if(dir == SOUTH)
			input_area = locate(x, y+1, z)
			output_area = locate(x, y-1, z)
		if(dir == EAST)
			input_area = locate(x-1, y, z)
			output_area = locate(x+1, y, z)
		if(dir == WEST)
			input_area = locate(x+1, y, z)
			output_area = locate(x-1, y, z)
		// And locate the SMES
		for(var/obj/machinery/power/smes/found_smes in output_area)
			smes_found = 1
			connected_smes = found_smes
		CheckInput()

/obj/machinery/mining/energyconverter/proc/ConvertCrystal(var/obj/item/weapon/crystal/power_crystal as obj, var/batch_mode)
	connected_smes.charge += (connected_smes.capacity / 100) * crystal_powerpercent
	if(batch_mode)
		connected_smes.updateicon()
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
	del(power_crystal)

/obj/machinery/mining/energyconverter/proc/CheckInput()
	var/crystal_converted = 0
	if(disabled)
		spawn(30) CheckInput()
		return
	for(var/obj/item/weapon/crystal/get_crystal in input_area)
		ConvertCrystal(get_crystal, 0)
		crystal_converted = 1
	if(crystal_converted)
		connected_smes.updateicon()
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
	spawn(30) CheckInput()