### Preliminary note:

This is a maintenance/fix/improvement release of the (apparantly) abandoned [Nudist](https://www.curseforge.com/wow/addons/nudist) addon by tekkub. 

Some of the code is unchanged from the original. All images for the iconic Gnome button are unchanged. So, of course credits to tekkub.

If you are the author of the original addon, and don’t like to see this fork of your addon posted here or anywhere, just leave a note in the Issues thread.


## What this addon does:

Clicking the Gnome button on your char frame or entering “/nudist” in the console (or via macro) strips your char off of all items that would suffer from death (durability-wise).

Doing the same again re-equips you to exactly the same state you were at when you clicked the button first (or when you entered the command).
This is the main point of this addon: It re-equips you to the state of when you clicked the button, completely independent of any Blizz equip sets or BtWLoadouts equip sets or such. 

What for? I can create a “Nude” set?

A “nude” equip set works of course fine for getting nude. But to de-nude (reequip) you would have to call your equip sets, and often these are not only one but some sets in a row. E.g., with a base equip set for the class + set for the spec + set for the weapons + set for the legendary you would have to activate 4 equip sets to get back to the state where you have been before nuding. 

Nudist solves this issue by one-click re-equipping exactly what you had at the point in time when you first clicked Nudist. It does not know or care about your equip sets or BtWLoadouts, i.e. the addon memorizes your actual equips and restores them. (Thus, it restores equally fine if your equipment wasn’t saved in a set at all.)

## Notes on changes since the “old” version by tekkub:

With the last version of the Nudist addon dating back to 2011 (Cataclysm), I took the liberty to refresh it a bit and make it work with SL.

To my surprise, the last (WoW 4) version of the addon still “worked” with Shadowlands, but there was one major issue:

Trying to re-equip two items that have the same item link (i.e. same item ID and same enchants, may happen with dual-wielded daggers and such) failed without warning. (You ended up with just _one_ weapon, either in slot 16 or in slot 17.)

I solved (hopefully 100%) this problem by restructuring the way the tables are built and introducing an additional check to see if all weapon slots are equipped. If not, we do `UseContainerItem(bag, bagslot)` on the empty slot, after a short delay. `UseContainerItem` is more expensive than `EquipItemByName` (which is used for the “uncomplicated” re-equips) but seems to be the only way to get those dupe-ID items back into their slots correctly.

As a new feature, now you have also the option to unequip _all_ slots. For this, hold down any modifier key while clicking the button or executing the command or macro. (Useful if you have to strip everything to reduce damage output for low-level achievements etc.)
