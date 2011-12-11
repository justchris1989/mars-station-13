// Definitions
/obj/machinery/power/nuclear_power/reactor
	name = "reactor"
	desc = "A state of the art nuclear power reactor."
	icon = 'nuclear.dmi'
	icon_state = "reactor"
	anchored = 1
	density = 1

	var/running = 0
	var/power_out = 0
	var/control_rods = 0 // 0 = retracted; 100 = extended
	var/temperature = 30
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
	anchored = 1
	density = 1

	var/plutonium = 0

/obj/machinery/power/nuclear_power/coolant_adder
	name = "coolant storage unit"
	desc = "It looks even weirder."
	icon = 'nuclear.dmi'
	icon_state = "cool_adder"
	flags = OPENCONTAINER
	anchored = 1
	density = 1

	var/coolant = 0

/obj/machinery/power/nuclear_power/control
	name = "core control computer"
	desc = "A computer. For the core."
	icon = 'computer.dmi'
	icon_state = "core"
	anchored = 1
	density = 1

	var/id = null
	var/obj/machinery/power/nuclear_power/reactor/hooked
	var/obj/machinery/power/nuclear_power/plutonium_adder/plut_one
	var/obj/machinery/power/nuclear_power/plutonium_adder/plut_two
	var/obj/machinery/power/nuclear_power/coolant_adder/cool_one
	var/obj/machinery/power/nuclear_power/coolant_adder/cool_two

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
	src.process()

/obj/machinery/power/nuclear_power/control/New()
	spawn(10)
		for(var/obj/machinery/power/nuclear_power/reactor/M in world)
			if (M.id == id)
				hooked = M
				plut_one = locate(/obj/machinery/power/nuclear_power/plutonium_adder) in get_step(hooked,WEST)
				plut_two = locate(/obj/machinery/power/nuclear_power/plutonium_adder) in get_step(hooked,EAST)
				cool_one = locate(/obj/machinery/power/nuclear_power/coolant_adder) in get_step(hooked,NORTH)
				cool_two = locate(/obj/machinery/power/nuclear_power/coolant_adder) in get_step(hooked,SOUTH)

/obj/machinery/power/nuclear_power/control/attack_hand(mob/user as mob)
	user.machine = src
	var/coolant = cool_one.coolant + cool_two.coolant
	var/plutonium = plut_one.plutonium + plut_two.plutonium
	var/dat = "<B>NUCLEAR REACTOR CONTROL PANEL</B><BR><HR><BR>"
	if(src.hooked.running)
		dat += "Running: YES<BR>Temperature: [src.hooked.temperature]°C<BR>Control rods: [src.hooked.control_rods]%<BR>Power output: [hooked.power_out]<BR>Coolant left: [coolant]<BR>Plutonium left: [plutonium]<BR><HR><BR>"
		dat += "<A href='?src=\ref[src];toggle=1'>Stop</A><BR><A href='?src=\ref[src];cr_minusten=1'>--</A> <A href='?src=\ref[src];cr_minus=1'>-</A>Control rods<A href='?src=\ref[src];cr_plus=1'>+</A> <A href='?src=\ref[src];cr_plusten=1'>++</A><BR>"
	else
		dat += "Running: NO<BR>Temperature: [hooked.temperature]°C<BR>Control rods: n/a%<BR>Power output: [hooked.power_out]<BR>Coolant left: n/a<BR>Plutonium left: n/a<BR><HR><BR>"
		dat += "<A href='?src=\ref[src];toggle=1'>Start</A><BR><A href='?src=\ref[src];cr_minusten=-1'>--</A> <A href='?src=\ref[src];cr_minus=1'>-</A>Control rods<A href='?src=\ref[src];cr_plus=1'>+</A> <A href='?src=\ref[src];cr_plusten=1'>++</A><BR>"
	user << browse("[dat]", "window=core_control")
	onclose(user, "core_control")

/obj/machinery/power/nuclear_power/control/Topic(href, href_list)
	if(stat & BROKEN) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	usr.machine = src

	if (href_list["toggle"])
		if(src.hooked.running)
			src.hooked.running = 0
		else
			src.hooked.running = 1
	if (href_list["cr_minusten"])
		if((src.hooked.control_rods - 10) >= 0)
			src.hooked.control_rods -= 10
		else
			hooked.control_rods = 0
	if (href_list["cr_minus"])
		if((src.hooked.control_rods - 1) >= 0)
			src.hooked.control_rods -= 1
		else
			hooked.control_rods = 0
	if (href_list["cr_plusten"])
		if((src.hooked.control_rods + 10) <= 100)
			src.hooked.control_rods += 10
		else
			hooked.control_rods = 100
	if (href_list["cr_plus"])
		if((src.hooked.control_rods + 1) <= 100)
			src.hooked.control_rods += 1
		else
			src.hooked.control_rods = 100
	src.updateUsrDialog()


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

		src.cool_up:coolant -= (temperature / 100) / 2
		src.cool_up:coolant -= (temperature / 100) / 2

		//if(temperature > 19999)
			// Add extended radiation radius
		//if(temperature > 24999)
			// Add station-wide damage
		//if(temperature > 29999)
//			control_rods = 0
		//if(temperature > 39999)
			// Boom goes MS13 and other fun games

		power_out = (BASEPOWER * temperature) / 3
		add_avail(power_out)
		src.temperature += 100 // DEBUG
		spawn(cycle_pause)
			src.process()
