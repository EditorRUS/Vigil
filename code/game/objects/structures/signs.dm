/*//////////////////////////////////////////
//			WARNING! ACHTUNG!			  //
//		WHEN YOU'RE MAKING A SIGN:		  //
//		REMEMBER TO USE \improper		  //
//	ONLY IF NAME IS CAPITALIZED AND 	  //
//ACTUALLY NOT PROPER; FAILURE TO DO THIS //
// WILL RESULT IN MESSAGES LIKE "The The  //
//	Periodic Table has been hit..."		  //
//	PLEASE REMEMBER THAT AND THANKS.	  //
//			HAVE A NICE DAY!			  //
*///////////////////////////////////////////

/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = 1
	opacity = 0
	density = 0
	layer = ABOVE_WINDOW_LAYER


/obj/structure/sign/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			qdel(src)
			return
		else
	return

/obj/structure/sign/blob_act()
	qdel(src)
	return

/obj/structure/sign/attackby(obj/item/tool as obj, mob/user as mob)	//deconstruction
	if(isscrewdriver(tool) && !istype(src, /obj/structure/sign/double))
		to_chat(user, "You unfasten the sign with your [tool].")
		var/obj/item/sign/S = new(src.loc)
		S.name = name
		S.desc = desc
		S.icon_state = icon_state
		//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
		//S.icon = I.Scale(24, 24)
		S.sign_state = icon_state
		qdel(src)
		return
	else
		..()

/obj/item/sign
	name = "sign"
	desc = ""
	icon = 'icons/obj/decals.dmi'
	w_class = W_CLASS_MEDIUM		//big
	var/sign_state = ""

/obj/item/sign/attackby(obj/item/tool as obj, mob/user as mob)	//construction
	if(isscrewdriver(tool) && isturf(user.loc))
		var/direction = input("In which direction?", "Select direction.") in list("North", "East", "South", "West", "Cancel")
		if(direction == "Cancel" || src.loc == null)
			return // We can get qdel'd if someone spams screwdrivers on signs before responding to the prompt.
		var/obj/structure/sign/S = new(user.loc)
		switch(direction)
			if("North")
				S.pixel_y = WORLD_ICON_SIZE
			if("East")
				S.pixel_x = WORLD_ICON_SIZE
			if("South")
				S.pixel_y = -WORLD_ICON_SIZE
			if("West")
				S.pixel_x = -WORLD_ICON_SIZE
			else
				return
		S.name = name
		S.desc = desc
		S.icon_state = sign_state
		to_chat(user, "You fasten \the [S] with your [tool].")
		qdel(src)
		return
	else
		..()

/obj/structure/sign/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(prob(70))
		to_chat(H, "<span class='userdanger'>Ouch! That hurts!</span>")

		H.apply_damage(rand(5,7), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))

/obj/structure/sign/double/map
	name = "station map"
	desc = "A framed picture of the station."

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

//For efficiency station
/obj/structure/sign/map/efficiency
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map_efficiency"

/obj/structure/sign/map/meta/left
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map-left-MS"

/obj/structure/sign/map/meta/right
	name = "station map"
	desc = "A framed picture of the station."
	icon_state = "map-right-MS"

/obj/structure/sign/securearea
	name = "SECURE AREA"
	desc = "A warning sign which reads 'SECURE AREA'."
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = "BIOHAZARD"
	desc = "A warning sign which reads 'BIOHAZARD'."
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "HIGH VOLTAGE"
	desc = "A warning sign which reads 'HIGH VOLTAGE'."
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "EXAM"
	desc = "A guidance sign which reads 'EXAM ROOM'."
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "HARD VACUUM AHEAD"
	desc = "A warning sign which reads 'HARD VACUUM AHEAD'."
	icon_state = "space"

/obj/structure/sign/deathsposal
	name = "DISPOSAL LEADS TO SPACE"
	desc = "A warning sign which reads 'DISPOSAL LEADS TO SPACE'."
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "ESCAPE PODS"
	desc = "A warning sign which reads 'ESCAPE PODS'."
	icon_state = "pods"

/obj/structure/sign/fire
	name = "DANGER: FIRE"
	desc = "A warning sign which reads 'DANGER: FIRE'."
	icon_state = "fire"

/obj/structure/sign/nosmoking_1
	name = "NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking"

/obj/structure/sign/nosmoking_2
	name = "NO SMOKING"
	desc = "A warning sign which reads 'NO SMOKING'."
	icon_state = "nosmoking2"

/obj/structure/sign/redcross
	name = "Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	icon_state = "redcross"

/obj/structure/sign/greencross
	name = "Medbay"
	desc = "The Intergalactic symbol of Medical institutions. You'll probably get help here.'"
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "The Most Robust Men Award for Robustness"
	desc = "\"To be robust is not an action or a way of life, but a mental state. Only those with the force of will strong enough to act during a crisis, saving friend from foe, acting when everyone else may think and act against you, are truly robust. Stay robust, my friends.\""
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "\improper AI developer's plaque"
	desc = "Next to the extremely long list of names and job titles, there is a drawing of a little child. The child appears to be retarded. Beneath the image, someone has scratched the word \"PACKETS\"."
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "\improper FEA Atmospherics Division plaque"
	desc = "This plaque commemorates the fall of the Atmos FEA division. For all the charred, dizzy, and brittle men who have died in its hands."
	icon_state = "atmosplaque"

/obj/structure/sign/science			//These 3 have multiple types, just var-edit the icon_state to whatever one you want on the map
	name = "SCIENCE!"
	desc = "A warning sign which reads 'SCIENCE!'."
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "CHEMISTRY"
	desc = "A warning sign which reads 'CHEMISTRY'."
	icon_state = "chemistry1"

/obj/structure/sign/chemtable
	name = "The Periodic Table"
	desc = "A very colorful and detailed table of all the chemical elements you could blow up or burn down a chemistry laboratory with, titled 'The Space Periodic Table - To be continued'. Just the mere sight of it makes you feel smarter."
	icon_state = "periodic"

/obj/structure/sign/botany
	name = "HYDROPONICS"
	desc = "A warning sign which reads 'HYDROPONICS'."
	icon_state = "hydro1"

/obj/structure/sign/directions/science
	name = "Science department"
	desc = "A direction sign, pointing out which way Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "Engineering department"
	desc = "A direction sign, pointing out which way Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "Security department"
	desc = "A direction sign, pointing out which way Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "Medical Bay"
	desc = "A direction sign, pointing out the direction of the medical bay."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "Escape Arm"
	desc = "A direction sign, pointing out which way escape shuttle dock is."
	icon_state = "direction_evac"

/obj/structure/sign/crime
	name = "CRIME DOES NOT PAY"
	desc = "A warning sign which suggests that you reconsider your poor life choices."
	icon_state = "crime"

/obj/structure/sign/chinese
	name = "incomprehensible sign"
	desc = "A sign written using traditional chinese characters. A native Sol Common speaker might understand it."

/obj/structure/sign/chinese/restricted_area
	icon_state = "CH_restricted_area"

/obj/structure/sign/chinese/caution
	icon_state = "CH_caution"

/obj/structure/sign/chinese/danger
	icon_state = "CH_danger"

/obj/structure/sign/chinese/electrical_equipment
	icon_state = "CH_electrical_equipment"

/obj/structure/sign/chinese/access_restricted
	icon_state = "CH_access_restricted"

/obj/structure/sign/chinese/notice
	icon_state = "CH_notice"

/obj/structure/sign/chinese/security
	icon_state = "CH_security"

/obj/structure/sign/chinese/engineering
	icon_state = "CH_engineering"

/obj/structure/sign/chinese/science
	icon_state = "CH_science"

/obj/structure/sign/chinese/medbay
	icon_state = "CH_medbay"

/obj/structure/sign/chinese/evacuation
	icon_state = "CH_evacuation"

/obj/structure/sign/russian
	name = "incomprehensible sign"
	desc = "A sign written in russian."

/obj/structure/sign/russian/electrical_danger
	icon_state = "RU_electrical_danger"

/obj/structure/sign/russian/caution
	icon_state = "RU_caution"

/obj/structure/sign/russian/staff_only
	icon_state = "RU_staff_only"

/obj/structure/sign/portrait
	name = "Clear Portrait"
	desc = "Stay Animus. Stay Robust."
	icon = 'icons/obj/portraits.dmi'
	icon_state = "clear"
	var/blesses = 1

/obj/structure/sign/portrait/rodger
	name = "Rodger Wheeler's Portrait"
	desc = "�������� ������������ ���� ������ ������� �� ��� � �������. ���� ������� ������� �����, �������� � �����&#1103;����� ������� ��������."
	icon_state = "portrait-rodger"

/obj/structure/sign/portrait/rodger/attackby(var/obj/item/weapon/W, mob/living/user, params)
	if(istype(W,/obj/item/weapon/extinguisher))
		if(blesses > 0)
			user << "<span class='userdanger'>� ���� ��������&#1103;� ���!</span>"
			new /obj/item/weapon/reagent_containers/food/drinks/milk(user.loc)
			blesses--
		else
			user.visible_message("<span class='warning'>� ��� �� ��� ����������, ����� [user] ������� �������. ���� �� ���&#1103;� �����.</span>", \
								 "<span class='userdanger'>� ���� �� ������� ���� ��������!</span>")
			playsound(loc, 'sound/effects/sparks1.ogg', 50, 1)
			user.adjustBrainLoss(5)

/obj/structure/sign/portrait/ruben
	name = "Ruben Mills Portrait"
	desc = "����� �&#1103;�����! ������ ����� ����� ���&#1103;�������� ����������� ������ ���� ������� �������� �������."
	icon_state = "portrait-ruben1"

/obj/structure/sign/portrait/ruben/attackby(var/obj/item/weapon/W, mob/living/user, params)
	if(istype(W,/obj/item/weapon/extinguisher))
		if(blesses > 0)
			user << "<span class='userdanger'>� ���� ��������&#1103;� ���!</span>"
			new /obj/item/clothing/head/collectable/kitty(user.loc)
			blesses--
		else
			user.visible_message("<span class='warning'>� ��� �� ��� ����������, ����� [user] ������� �������. ���� �� ���&#1103;� �����.</span>", \
								 "<span class='userdanger'>� ���� �� ������� ���� ��������!</span>")
			playsound(loc, 'sound/effects/sparks1.ogg', 50, 1)
			user.adjustBrainLoss(5)

/obj/structure/sign/portrait/bisher
	name = "Unknown's Portrait"
	desc = "������ ����&#1103;� �������� �������, ��������&#1103; ��������, ����������&#1103; ��&#1103;. �� ����� �������� ����� �������, ���������� ���������."
	icon_state = "portrait-bishehlop"

/obj/structure/sign/portrait/bisher/attackby(var/obj/item/weapon/W, mob/living/user, params)
	if(istype(W,/obj/item/weapon/extinguisher))
		if(blesses > 0)
			user << "<span class='userdanger'>� ���� ��������&#1103;� ���!</span>"
			new /obj/item/clothing/glasses/eyepatch(user.loc)
			blesses--
		else
			user.visible_message("<span class='warning'>� ��� �� ��� ����������, ����� [user] ������� �������. ���� �� ���&#1103;� �����.</span>", \
								 "<span class='userdanger'>� ���� �� ������� ���� ��������!</span>")
			playsound(loc, 'sound/effects/sparks1.ogg', 50, 1)
			user.adjustBrainLoss(5)

/obj/structure/sign/portrait/bisher/examine(mob/user)
	..()
	user.emote("salute")

/obj/structure/sign/portrait/delaverte
	name = "Santiago Delaverte's Portrait"
	desc = "Picture of the Great Comediant in his funniest role."
	icon_state = "delaverte"

/obj/structure/sign/portrait/enzosokal1
	name = "Enzo Sokal's Portrait"
	desc = "The best of the best CE and scientist. One of the SS13 Project founders."
	icon_state = "enzosokal1"

/obj/structure/sign/portrait/enzosokal2
	name = "Enzo Sokal's Portrait"
	desc = "The best of the best CE and scientist. One of the SS13 Project founders."
	icon_state = "enzosokal2"

/obj/structure/sign/portrait/georgemellon
	name = "George Mellon's Portrait"
	desc = "Honorfull picture of the NanoTrasen SEO Director. Stay Robust my friends."
	icon_state = "georgemellon"

/obj/structure/sign/portrait/kenzi
	name = "Kenzie Powers Portrait"
	desc = "The brilliant chemist, which loved to wear schoolgirl suit."
	icon_state = "kenzi"

/obj/structure/sign/portrait/derelictmonster
	name = "Mystical Portrait"
	desc = "You thought he blinked a couple of seconds ago.."
	icon_state = "derelictmonster"

/obj/structure/sign/portrait/becket
	name = "Mystical Portrait"
	desc = "One of the youngest detectives, ever worked on the Space Station 13 project. Her mind and body helped her to win in the Robust Tournament in the Jule of 2411. We will remember it forever."
	icon_state = "kate_becket"

/obj/structure/sign/portrait/morganjames
	name = "Portrait of the Morgan James"
	desc = "Honorfull picture of old NanoTrasen SEO Director. Stay Robust my friends."
	icon_state = "morganjames"

/obj/structure/sign/portrait/quin
	name = "Quinn Tey's Portrait"
	desc = "One of the mad scientists, which restored the AI technology. Will stay in our hearts."
	icon_state = "quin"