/obj/machinery/mining/processor
	name = "Mining processor"
	icon_state = "autolathe"
	desc = "An automatic material refining unit."
	density = 1
	var/automatic_processing = 1
	var/mat_efficiency = 1
	var/m_amount = 0.0
	var/g_amount = 0.
	var/c_amount = 0.0
	var/operating = 0.0
	var/temp = null
	anchored = 1.0
	var/list/L = list()
	var/disabled = 0
	var/input_area
	var/output_area_metal
	var/output_area_glass
	var/output_area_crystal

/obj/machinery/mining/processor/New()
	input_area = locate(src.x, src.y+1, src.z)
	output_area_metal = locate(src.x-1, src.y, src.z)
	output_area_glass = locate(src.x, src.y-1, src.z)
	output_area_crystal = locate(src.x+1, src.y, src.z)
	/* The in/output areas look like this:

	   IN

	M [++] C

	   G

	IN is the input port
	M is the metal output port
	G is the glass output port
	C is the crystal output port
	[++] is the procesor
	*/
	CheckMat()

/obj/machinery/mining/processor/proc/ProcessChunk(var/obj/item/weapon/chunk/mat_chunk as obj)
	if(mat_chunk.mineral_type == 0)
		m_amount += mat_efficiency
	if(mat_chunk.mineral_type == 1)
		g_amount += mat_efficiency
	if(mat_chunk.mineral_type == 2)
		c_amount += mat_efficiency
	del(mat_chunk)

/obj/machinery/mining/processor/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/weapon/chunk))
		flick("autolathe_c",src)
		ProcessChunk(O)
		spawn(16)
			flick("autolathe_o",src)
	else
		user << "This object does not contain refinable raw materials, or cannot be accepted by the mining processor due to size or hazardous materials."

/obj/machinery/mining/processor/proc/CheckMat()
	// This proc regularly checks for new materials and processes them, also fixes negative material values
	if(src.m_amount < 0)
		src.m_amount = 0
	if(src.g_amount < 0)
		src.g_amount = 0
	if(src.c_amount < 0)
		src.c_amount = 0
	if(!automatic_processing)
		spawn(30) CheckMat()
		return
	for(var/obj/item/weapon/chunk/material_chunk in input_area)
		ProcessChunk(material_chunk)
	if(m_amount >= 100 || g_amount >= 100 || c_amount >= 30)
		flick("autolathe_c",src)
		spawn(16)
			flick("autolathe_o",src)
	if(m_amount >= 100)
		var/obj/createdobj = new /obj/item/weapon/sheet/metal(output_area_metal)
		createdobj/item/weapon/sheet/metal.amount = 50
		src.m_amount -= 50
	if(g_amount >= 100)
		var/obj/createdobj = new /obj/item/weapon/sheet/glass(output_area_glass)
		createdobj/item/weapon/sheet/glass.amount = 50
		src.g_amount -= 50
	if(c_amount >= 30)
		new /obj/item/weapon/crystal(output_area_crystal)
		src.c_amount -= 10
	spawn(30) CheckMat()


/obj/machinery/mining/processor/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/mining/processor/attack_hand(user as mob)
	var/dat
	if(..())
		return
	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	else
		dat = text("<B>Metal Units:</B> [src.m_amount] / 100<BR>")
		dat += text("<B>Glass Units:</B> [src.g_amount] / 100<BR>")
		dat += text("<B>Crystal Units:</B> [src.c_amount] / 30<HR>")
		var/list/objs = list()
		objs += src.L
		for(var/obj/t in objs)
			var/objname = t.name
			if(t.name == "metal") objname = "50 metal sheets"
			if(t.name == "glass") objname = "50 glass sheets"
			if(t.name == "reinforced glass") objname = "50 reinforced glass sheets"
			if(t.name == "crystal") objname = "Energy crystal"
			dat += text("<A href='?src=\ref[src];make=\ref[t]'>[objname]</A> ([t.m_units]m / [t.g_units]g / [t.c_units]c)<BR>")
	user << browse("<HEAD><TITLE>Mining processor Control Panel</TITLE></HEAD>[dat]", "window=miningprocessor_regular")
	onclose(user, "miningprocessor_regular")
	return

/obj/machinery/mining/processor/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["make"])
		var/obj/template = locate(href_list["make"])
		if(src.m_amount >= template.m_units && src.g_amount >= template.g_units && src.c_amount >= template.c_units)
			src.m_amount -= template.m_units
			src.g_amount -= template.g_units
			src.c_amount -= template.c_units
			spawn(16)
				flick("autolathe_c",src)
				spawn(16)
					flick("autolathe_o",src)
					spawn(16)
						var/obj/createdobj = new template.type(usr.loc)
						if(createdobj.type == /obj/item/weapon/sheet/metal)
							createdobj/item/weapon/sheet/metal.amount = 50
						if(createdobj.type == /obj/item/weapon/sheet/glass)
							createdobj/item/weapon/sheet/glass.amount = 50
						if(createdobj.type == /obj/item/weapon/sheet/rglass)
							createdobj/item/weapon/sheet/rglass.amount = 50
	if (href_list["temp"])
		src.temp = null

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	return

/obj/machinery/mining/processor/New()
	..()
	src.L += new /obj/item/weapon/sheet/metal(src)
	src.L += new /obj/item/weapon/sheet/glass(src)
	src.L += new /obj/item/weapon/sheet/rglass(src)
	src.L += new /obj/item/weapon/crystal(src)
	src.L += new /obj/item/weapon/rcd_ammo(src)

/obj/machinery/mining/processor/proc/get_connection()
	var/turf/T = src.loc
	if(!istype(T, /turf/simulated/floor))
		return

	for(var/obj/cable/C in T)
		if(C.d1 == 0)
			return C.netnum

	return 0