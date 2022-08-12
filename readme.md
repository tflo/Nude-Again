## What this addon does:

Clicking the icon (button) on your char screen or entering “/nudist” in the console strips your char off of all items that would suffer from death (durability-wise).

Doing the same again re-equips you to exactly the same state you were at when you clicked the button first (or when you entered the command).
This is the main point of this addon: It re-equips you to the state of when you clicked the button, completely independent of any Blizz equip sets or BtWLoadouts equip sets or such. 

What for? I can create a “Nude” set?

In my experience, making a “nude” equip set only works in theory. It works to nude, but to de-nude you would have to call your equip sets, and often these are not only one but some sets in a row. (Eg base equip set for the class, then for the spec, then some different rune variants for the weapons of your DK, you got it, I think). 

Nudist solves this issue by just and simply re-equipping what you had at the point in time when you clicked Nudist. Exactly what you had at that point in time.

## Notes on changes since the “old” version by tekkub:

Since the last version of the Nudist addon dates to WoW 4 (WotLK), I took the liberty to refresh it a bit and make it work with SL.

Note that the last WotLK version of the addon still “works” with SL (!), but there was one major issue:

Trying to re-equip two items with the same link (i.e. same item ID and same enchants, may happen with duel-wielded daggers and such) fails.

I solved (hopefully) this problem by restructuring the way the tables are built and introducing an additional check to see if all weapon slots are equipped. If not, we do UseContainerItem(bag, bagslot) on the empty slot, after a 0.8s or so delay.
