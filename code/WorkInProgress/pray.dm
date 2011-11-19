/* A prayer system, availiable in the chapel. */

/mob/verb/pray()
	set name = "Pray"
	var/msg = input(usr,"For what do you want to pray?","Praying") as text
	for(var/area/myarea in usr.loc) // Insert the the check here. I don't get the areas
		if(ispath(/area/myarea, /area/chapel))
			usr.emote("clap")
			usr.whisper("[msg]")
			sendprayer(msg, key_name(src, usr))
			return
		else
			usr << "This place just dont feel spiritual enough..."

/proc/sendprayer(var/text, var/key, var/admin_ref = 0)
	for (var/mob/M in world)
		if (M.client && M.client.holder && M.client.listenpray)
			M << "\blue <b>PRAY: [key](<A HREF='?src=\ref[M.client.holder];prayeropts=\ref[key]'>X</A>):</b> [text]"
			return
		else
			return

/*

/proc/pray_thunder(var/name)
	name:eye_stat += rand(0, 5)
	name << "\red You hear a crackle of thunder!"
	return

/proc/item_in_face(var/name)
	var/list/selectable = list()
	for(var/O in typesof(/obj/item/))
		//Note, these istypes don't work
		if(istype(O, /obj/item/weapon/gun))
			continue
		if(istype(O, /obj/item/assembly))
			continue
		if(istype(O, /obj/item/weapon/camera))
			continue
		if(istype(O, /obj/item/weapon/cloaking_device))
			continue
		if(istype(O, /obj/item/weapon/dummy))
			continue
		if(istype(O, /obj/item/weapon/sword))
			continue
		if(istype(O, /obj/item/device/shield))
			continue
		selectable += O

	var/hsbitem = input(usr, "Choose an object to spawn.", "Pray penalty:") in selectable + "Cancel"
	if(hsbitem != "Cancel")
		pray_thunder(name)
		new hsbitem(name:loc)
		return
	else
		return

*/