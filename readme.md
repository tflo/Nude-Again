### Preliminary note:

This is a maintenance/fix release of an (apparantly) abandoned addon. The addon this is based on is: https://www.curseforge.com/wow/addons/nudist

If you are the author of the original addon, and don’t like to see this fork of your addon posted here or anywhere, just leave a note in the Issues thread.


## What this addon does:

Clicking the icon (button) on your char screen or entering “/nudist” in the console (or via macro) strips your char off of all items that would suffer from death (durability-wise).

Doing the same again re-equips you to exactly the same state you were at when you clicked the button first (or when you entered the command).
This is the main point of this addon: It re-equips you to the state of when you clicked the button, completely independent of any Blizz equip sets or BtWLoadouts equip sets or such. 

What for? I can create a “Nude” set?

In my experience, making a “nude” equip set only works in theory. It works to nude, but to de-nude you would have to call your equip sets, and often these are not only one but some sets in a row. E.g.: with a base equip set for the class + set for the spec + set for the weapons + set for the legendary you would have to activate 4 equip sets to get back to the state where you have been before nuding. 

Nudist solves this issue by just and simply re-equipping what you had at the point in time when you clicked Nudist. It re-equips to _exactly_ what you had at that point in time, it does not know or care about your equip sets, i.e the addon _records_ your actual equips and restores them. No fake, no complications, that’s all.

## Notes on changes since the “old” version by tekkub:

Since the last version of the Nudist addon dates back to WoW 4 (WotLK), I took the liberty to refresh it a bit and make it work with SL.

Note that the last WotLK version of the addon still “works” with SL, but there was one major issue:

Trying to re-equip two items that have the same item link (i.e. same item ID and same enchants, may happen with dual-wielded daggers and such) failed without warning. (You ended up with just _one_ weapon, either in slot 16 or in slot 17.)

I solved (hopefully 100%) this problem by restructuring the way the tables are built and introducing an additional check to see if all weapon slots are equipped. If not, we do `UseContainerItem(bag, bagslot)` on the empty slot, after a short delay. `UseContainerItem` is more expensive than `EquipItemByName` (which is used for the “uncomplicated” re-equips) but seems to be the only way to get those dupe-ID items back into their slots correctly.

Now you have also the option to unequip _all_ slots. For this, hold down any modifier key while clicking the button or running the command or macro. (Useful if you have to strip everything to reduce damage output.)
