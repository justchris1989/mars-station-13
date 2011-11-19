// Defines first

/obj/item/weapon/chunk
	name = "chunk"
	icon = 'mining.dmi'
	icon_state = "chunk"
	desc = "A chunk of mars earth."
	throwforce = 14.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/mineral_type = 0

/obj/item/weapon/crystal
	name = "crystal"
	icon = 'mining.dmi'
	icon_state = "crystal"
	desc = "A crystal."
	throwforce = 14.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	w_class = 3.0
	c_units = 10
	flags = FPRINT | TABLEPASS

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'mining.dmi'
	icon_state = "pickaxe"
	desc = "A pickaxe, used to mine valuable minerals."
	throwforce = 14.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	w_class = 3.0
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT

// Then the code

/obj/item/weapon/chunk/proc/SetDescription()
	if(mineral_type == 0)
		desc = "A chunk of mars earth."
		return
	if(mineral_type == 1)
		desc = "A dusty piece of mars earth."
		return
	if(mineral_type == 2)
		desc = "A chunk of mars earth, it looks a bit glittery."
		return

