/* Here will be Tweet's alcohol system. I guess I won't be able to do this *sigh *

IDEA: Every alcoholic drink gives a amount of alcohol saved in alc for the human mob.
The entire alcohol-effects will be calculated here and not in the drink anymore,
using the alc var.
With the alc var pukes and posioning will be calculated too. */


/world/proc/Puke(mob/M as mob)
	if(M:alc >= 50)
		M << "\red You puke all over the floor!"
		M:alc -= 10