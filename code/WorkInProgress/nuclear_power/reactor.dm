// Definitions
/obj/machinery/power/nuclear_power/reactor
	name = "reactor"
	desc = "A state of the art nuclear power reactor."

	var/control_rods = 0 // 0 = retracted; 100 = extended
	var/temperature = 0
	var/broken = 0
	var/pluto_left = null
	var/pluto_right = null
	var/cool_up = null
	var/cool_down = null

/obj/machinery/power/nuclear_power/plutonium_adder
	name = "plutonium storage unit"
	desc = "It looks weird."

	var/plutonium = 0

/obj/machinery/power/nuclear_power/coolant_adder
	name = "coolant storage unit"
	desc = "It looks even weirder."

	var/coolant = 0
// Actual code
/obj/machinery/power/nuclear_power/plutonium_adder/attackby(var/obj/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/nuclear/leadbox) || istype(O, /obj/item/weapon/nuclear/plutonium))
		if(istype(O, /obj/item/weapon/nuclear/leadbox))
			if(O:amount > 0)
				src.plutonium += O:amount
				O:amount = 0
				usr << "\blue You add the plutonium to the storage unit"
			else
				O:amount += src.plutonium
				src.plutonium = 0
				usr << "\blue You remove the plutonium from the storage unit."
		else
			src.plutonium += O:amount
			del(O)
			usr << "\red You add the plutonium to the storage unit."

/obj/machinery/power/nuclear_power/reactor/New()
	// Here we'll hook the other parts up.
	spawn(10)
		pluto_left = locate(/obj/machinery/power/nuclear_power/plutonium_adder) in get_step(src,WEST)
		pluto_right = locate(/obj/machinery/power/nuclear_power/plutonium_adder) in get_step(src,EAST)
		cool_up = locate(/obj/machinery/power/nuclear_power/coolant_adder) in get_step(src,NORTH)
		cool_down = locate(/obj/machinery/power/nuclear_power/coolant_adder) in get_step(src,SOUTH)
		if(!pluto_left || !pluto_right || !cool_up || !cool_down)
			broken = 1

#define BASEPOWER 50
/obj/machinery/power/nuclear_power/reactor/process()
	var/bufftmp = 0
	if((pluto_right:plutonium + pluto_left:plutonium) == 0) // no further heating if there's no plutonium
		bufftmp = temperature // instead get the old temperature
	else
		bufftmp = temperature * control_rods / 5 //So the control rods have any use.
		if(bufftmp < temperature && control_rods > 0)
			bufftmp = temperature + (temperature - bufftmp) // But also don't lower the temperature
	if((cool_up:coolant + cool_down:coolant) > 0)
		bufftmp -= rand(500)
	temperature = bufftmp

	cool_up:coolant -= (temperature / 100) / 2
	cool_up:coolant -= (temperature / 100) / 2

	if(temperature > 1999)
		// Add extended radiation radius
	if(temperature > 2499)
		// Add station-wide damage
	if(temperature > 2999)
		// Shuts down itself if nuclear disk isn't authorizing
	if(temperature > 3999)
		// Boom goes MS13 and other fun games

	add_avail((BASEPOWER * temperature) / 3)