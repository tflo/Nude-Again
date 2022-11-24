local function dp(...) -- debugprint
	-- return
	print('Nudist Debug:', ...)
end

--[[
This has changed in DF! (was 19).
https://www.wowinterface.com/forums/showthread.php?s=285e4b422a2f9c7ae7954929a74a3ac7&p=341652
https://github.com/Ketho/wow-ui-source-df/search?q=CONTAINER_BAG_OFFSET
]]
local CONTAINER_BAG_OFFSET = 30

local SENSITIVE_SLOTS, ALL_SLOTS, items, freeslots =
	{ 1, 3, 5, 6, 7, 8, 9, 10, 16, 17 },
	{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19 }, -- 18 is no longer used in Retail
	{},
	{}

local MSG_PREFIX, MSG_NUDE, MSG_FULL_NUDE, MSG_CLOTHED, MSG_FAILURE =
	'Nudist:',
	'Almost nude now!',
	'Really nude now!',
	'Equipped again.',
	'|cffFF0000Something went wrong while trying to reequip your weapon slots. Check your equipment!'

local function status_msg(...) print(MSG_PREFIX, ...) end

local btn = CreateFrame('Button', nil, PaperDollFrame)
btn:SetFrameStrata 'DIALOG'
btn:SetPoint('BOTTOMRIGHT', CharacterFrame, 'TOPRIGHT', -60, -30)
btn:SetWidth(64)
btn:SetHeight(64)
btn:SetNormalTexture 'Interface/Addons/Nudist-Again/clothed'
btn:SetPushedTexture 'Interface/Addons/Nudist-Again/nude'

local function get_empties()
	for bag = 0, 4 do
		freeslots[bag] = C_Container.GetContainerNumFreeSlots(bag)
	end
end

local function get_next_empty()
	for i = 0, 4 do
		if freeslots[i] > 0 then
			freeslots[i] = freeslots[i] - 1
			return i
		end
	end
end

local function equip_item_by_bagslot(item, slot)
	for bag = 0, 4 do
		local max = C_Container.GetContainerNumSlots(bag)
		for bagslot = 1, max do
			if C_Container.GetContainerItemLink(bag, bagslot) == item then
				C_Container.UseContainerItem(bag, bagslot)
				status_msg("Reequipped missing item via 'UseContainerItem': Slot", slot, item) -- debug
				return
			end
		end
	end
end

local function unequip_done(m)
	btn:SetNormalTexture 'Interface/Addons/Nudist-Again/nude'
	btn:SetPushedTexture 'Interface/Addons/Nudist-Again/clothed'
	status_msg(m)
end

local function reequip_done(m)
	table.wipe(items)
	btn:SetNormalTexture 'Interface/Addons/Nudist-Again/clothed'
	btn:SetPushedTexture 'Interface/Addons/Nudist-Again/nude'
	status_msg(m)
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

		local msg, verify = MSG_CLOTHED, false

		C_Timer.After(0.8, function()
			for s = 16, 17 do -- Check only weapon slots [^1]
				if items[s] and not GetInventoryItemLink('player', s) then
					equip_item_by_bagslot(items[s], s)
					verify = true
				end
			end
			if not verify then
				reequip_done(msg)
			else -- Doublecheck if the 2nd slot 16/17 attempt was successful
				C_Timer.After(0.8, function()
					for s = 16, 17 do
						if items[s] and not GetInventoryItemLink('player', s) then
							msg = MSG_FAILURE
							break
						end
					end
					reequip_done(msg)
				end)
			end
		end)
	else
		get_empties()

		local slots, msg = SENSITIVE_SLOTS, MSG_NUDE

		if IsModifierKeyDown() then
			slots, msg = ALL_SLOTS, MSG_FULL_NUDE
		end

		for _, i in ipairs(slots) do
			local bag = get_next_empty()
			if not bag then return end

			local item = GetInventoryItemLink('player', i)
			if item then
				table.insert(items, i, item)
				PickupInventoryItem(i)
				if bag == 0 then
					PutItemInBackpack()
				else
					PutItemInBag(bag + CONTAINER_BAG_OFFSET)
				end
			end
		end
		unequip_done(msg)
	end
end

SLASH_NUDIST1 = '/nudist'
SlashCmdList['NUDIST'] = handler
btn:SetScript('OnClick', handler)



--[=[

Notes
-----

[^1]:

If we have two of the same items, and with the same enchants, equipped, then they have probably an identical item link. Usually this happens only with the weapon slots (16 and 17).

In that case – for some reason – we cannot equip both items with EquipItemByName(itemlink, slot): One item will be equipped correctly, the other one will not.

As a workaround, we have to equip the second one of the identical items via bag slot: we search all bag slots for a matching item link and then equip the item via UseContainerItem(bag, bagslot).

We could use this method right from the start for slots 16 and 17. But I think it's more economic to equip normally, and check afterwards if one of the originally equipped slots is empty. Then we use the workaround for the missing item only. Currently the check is limited to slots 16 and 17, because _I think_ it is impossible to have identical items in the other slots.
The C_Timer is necessary, otherwise, if the check comes to soon, we get all slots returned as not equipped. 1 second seems to be safe, probably we can go a bit faster (0.25s though is too short).

To check _all_ slots for missing items, use this:

-- 			for s, i in pairs(items) do -- Check all slots [^1]
-- 				if not GetInventoryItemLink('player', s) then
-- 					equip_item_by_bagslot(i, s)
-- 				end
-- 			end


]=]
