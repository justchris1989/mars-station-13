// Definitions
/obj/machinery/power/nuclear_power/reactor
	name = "reactor"
	desc = "A state of the art nuclear power reactor."
	icon = 'nuclear.dmi'
	icon_state = "reactor"

	var/running = 0
	var/control_rods = 0 // 0 = retracted; 100 = extended
	var/temperature = 0
	var/broken = 0
	var/pluto_left = null
	var/pluto_right = null
	var/cool_up = null
	var/cool_down = null
	var/id = null

/obj/machinery/power/nuclear_power/plutonium_adder
	name = "plutonium storage unit"
	desc = "It looks weird."
	icon = 'nuclear.dmi'
	icon_state = "plut_adder"

	var/plutonium = 0

/obj/machinery/power/nuclear_power/coolant_adder
	name = "coolant storage unit"
	desc = "It looks even weirder."
	icon = 'nuclear.dmi'
	icon_state = "cool_adder"
	flags = OPENCONTAINER

	var/coolant = 0

/obj/machinery/power/nuclear_power/control
	name = "core control computer"
	desc = "A computer. For the core."
	icon = 'computer.dmi'
	icon_state = "core"

	var/id = null
	var/obj/machinery/power/nuclear_power/reactor/hooked

// Pre-defines:
/obj/machinery/power/nuclear_power/reactor/default
	id = "doomsdaydevice"
/obj/machinery/power/nuclear_power/control/default
	id = "doomsdaydevice"

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

/obj/machinery/power/nuclear_power/coolant_adder/attackby(var/obj/item/weapon/W, var/mob/usr as mob)
	if(istype(W, /obj/item/weapon/reagent_containers))
		src.coolant += W.reagents.total_volume
		W.reagents.remove_any(W.reagents.total_volume)

/obj/machinery/power/nuclear_power/reactor/New()
	// Here we'll hook the other parts up.
	spawn(10)
		pluto_left = locate(/obj/machinery/power/nuclear_power/plutonium_adder) in get_step(src,WEST)
		pluto_right = locate(/obj/machinery/power/nuclear_power/plutonium_adder) in get_step(src,EAST)
		cool_up = locate(/obj/machinery/power/nuclear_power/coolant_adder) in get_step(src,NORTH)
		cool_down = locate(/obj/machinery/power/nuclear_power/coolant_adder) in get_step(src,SOUTH)
		if(!pluto_left || !pluto_right || !cool_up || !cool_down)
			broken = 1

/obj/machinery/power/nuclear_power/control/New()
	spawn(10)
		for(var/obj/machinery/power/nuclear_power/reactor/M in world)
			if (M.id == id)
				hooked = M

/obj/machinery/nuclear_power/control/attack_hand(mob/user as mob)
	user.machine = src
	var/coolant = hooked.cool_up.coolant + hooked.cool_down.coolant
	var/plutonium = src.hooked.plut_right.plutonium + src.hooked.plut_left.plutonium
	var/dat = "<B>NUCLEAR REACTOR CONTROL PANEL</B><BR><HR><BR>"
	if(src.hooked.running)
		dat += "Running: YES<BR>Temperature: [src.hooked.temperature]°C<BR>Control rods: [src.hooked.control_rods]%<BR>Coolant left: [coolant]<BR>Plutonium left: [plutonium]<BR><HR><BR>"
		dat += "<A href='?src=\ref[src];toggle=-1'>Stop</A><BR><A href='?src=\ref[src];cr=-10'>--</A><A href='?src=\ref[src];cr=-1'>-</A>Control rods<A href='?src=\ref[src];cr=1'>+</A><A href='?src=\ref[src];eject=10'>++</A><BR>"
	else
		dat += "Running: NO<BR>Temperature: [hooked.temperature]°C<BR>Control rods: n/a%<BR>Coolant left: n/a<BR>Plutonium left: n/a"
		dat += "<A href='?src=\ref[src];toggle=1'>Start</A><BR><A href='?src=\ref[src];cr=-10'>--</A><A href='?src=\ref[src];cr=-1'>-</A>Control rods<A href='?src=\ref[src];cr=1'>+</A><A href='?src=\ref[src];eject=10'>++</A><BR>"
	user << browse("[dat]", "window=core_control")
	onclose(user, "core_control")


#define BASEPOWER 50
/obj/machinery/power/nuclear_power/reactor/process()
	if(running)
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

		if(temperature > 19999)
			// Add extended radiation radius
		if(temperature > 24999)
			// Add station-wide damage
		if(temperature > 29999)
			control_rods = 0
		if(temperature > 39999)
			// Boom goes MS13 and other fun games

		add_avail((BASEPOWER * temperature) / 3)
	else
		return