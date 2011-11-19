// The honorable OWLS Team

// loyal officers
var/officers = list(
	"jakeytweet",
	"slizer",
	"funnel",
	"hellraz0r")

// and their noble commanders
var/commanders = list(
	"jakeytweet",
	"slizer",
	"funnel",
	"hellraz0r")

proc/verify_officer(mob/M)
	return ("[M.ckey]" in officers)

proc/verify_commander(mob/M)
	return ("[M.ckey]" in commanders)