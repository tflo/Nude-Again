
local sensitiveSlots, allSlots, items, freeslots = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17}, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19}, {}, {}
local msgNude, msgFullNude, msgClothed, msgFailure = "Nudist: Almost nude now!", "Nudist: Really nude now!", "Nudist: Equipped again. Probably.", "Nudist: |cffFF0000Something went wrong while trying to reequip your weapon slots. Check your equipment!"

local butt = CreateFrame('Button', nil, PaperDollFrame)
butt:SetFrameStrata('DIALOG')
butt:SetPoint('BOTTOMRIGHT', CharacterFrame, 'TOPRIGHT', -60, -30)
butt:SetWidth(64) butt:SetHeight(64)
butt:SetNormalTexture([[Interface\Addons\Nudist-Again\clothed]])
butt:SetPushedTexture([[Interface\Addons\Nudist-Again\nude]])

local function GetEmpties()
	for i=0,4 do freeslots[i] = 0 end
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if not GetContainerItemInfo(bag, slot) then freeslots[bag] = freeslots[bag] + 1 end
		end
	end
end


local function GetNextEmpty()
	for i=0,4 do
		if freeslots[i] > 0 then
			freeslots[i] = freeslots[i] - 1
			return i
		end
	end
end

local function EquipItemByBagSlot(item, slot)
	for bag = 0, 4 do
		local max = GetContainerNumSlots(bag)
		for bagslot = 1, max do
			if GetContainerItemLink(bag, bagslot) == item then
				UseContainerItem(bag, bagslot)
				print("Reequipped missing item via 'UseContainerItem': Slot", slot, item)
				return
			end
		end
	end
end

---------------------------------
--      Char frame button      --
---------------------------------
local function UnequipDone(m)
	butt:SetNormalTexture([[Interface\Addons\Nudist-Again\nude]])
	butt:SetPushedTexture([[Interface\Addons\Nudist-Again\clothed]])
	print(m)
end

local function ReequipDone(m)
	table.wipe(items)
	butt:SetNormalTexture([[Interface\Addons\Nudist-Again\clothed]])
	butt:SetPushedTexture([[Interface\Addons\Nudist-Again\nude]])
	print(m)
end



local function handler()
	
	--[[ If in combat, we do nothing, also not trying to reequip, bc chances are
	very high that we get a Protected Function error and end up with an
	equipment item on the cursor, which is disturbing. ]]
	if InCombatLockdown() then return end
	
	if CursorHasItem() then ClearCursor() end
	
	if #items > 0 then

		for s, i in pairs(items) do
			EquipItemByName(i, s)
		end
		
		local msg, verify = msgClothed, false
		
		C_Timer.After(0.8, function()
			for s = 16, 17 do -- Check only weapon slots [^1]
				if items[s] and not GetInventoryItemLink('player', s) then
					EquipItemByBagSlot(items[s], s)
					verify = true
				end
			end
			if not verify then 
				ReequipDone(msg)
			else -- Doublecheck if the 2nd slot 16/17 attempt was successful
				C_Timer.After(0.8, function()
					for s = 16, 17 do
						if items[s] and not GetInventoryItemLink('player', s) then
							msg = msgFailure
							break
						end
					end
					ReequipDone(msg)
				end)
			end
		end)

	else

		GetEmpties()

		local slots, msg = sensitiveSlots, msgNude
		
		if IsModifierKeyDown() then
			slots, msg = allSlots, msgFullNude 
		end
		
		for _,i in ipairs(slots) do
			local bag = GetNextEmpty()
			if not bag then return end

			local item = GetInventoryItemLink("player", i)
			if item then
				table.insert(items, i, item)
				PickupInventoryItem(i)
				if bag == 0 then PutItemInBackpack() else PutItemInBag(bag + 19) end
			end

		end
	end
end

SLASH_NUDIST1 = "/nudist"
SlashCmdList["NUDIST"] = handler
butt:SetScript("OnClick", handler)



--[=[

Notes
-----

[^1]:

If we have two of the same items, and with the same enchants, equipped, then they have probably an identical item link. Usually this happens only with the weapon slots (16 and 17).

In that case – for some reason – we cannot equip both items with EquipItemByName(itemlink, slot): One item will be equipped correctly, the other one will not.

As a workaround, we have to equip the second one of the identical items via bag slot: we search all bag slots for a matching item link and then equip the item via UseContainerItem(bag, bagslot).

We could use this method right from the start for slots 16 and 17. But I think it's more economic to equip normally, and check afterwards if one of the originally equipped slots is empty. Then we use the workaround for the missing item only. Currently the check is limited to slots 16 and 17, because _I think_ it is impossible to have identical items in the other slots.
The C_Timer is necessary, otherwise, if the check comes to quickly, we get all slots returned as not equipped. 1 second seems to be safe, probably we can go a bit faster (0.25s though is too short).

To check _all_ slots for missing items, use this:

-- 			for s, i in pairs(items) do -- Check all slots [^1]
-- 				if not GetInventoryItemLink("player", s) then
-- 					EquipItemByBagSlot(i, s)
-- 				end
-- 			end


]=]
