
local slots, freeslots, items = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17}, {}, {}


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

local butt = CreateFrame("Button", nil, PaperDollFrame)
butt:SetFrameStrata("DIALOG")
butt:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", -60, -30)
butt:SetWidth(64) butt:SetHeight(64)

-- Textures --
butt:SetNormalTexture("Interface\\Addons\\Nudist\\clothed")
butt:SetPushedTexture("Interface\\Addons\\Nudist\\nude")

-- Tooltip bits
--~ butt:SetScript("OnEnter", ShowTooltip)
--~ butt:SetScript("OnLeave", HideTooltip)


local function handler()

	if CursorHasItem() then ClearCursor() end

	if #items > 0 then

		for s, i in pairs(items) do
			EquipItemByName(i, s)
		end

		C_Timer.After(0.8, function()
			for s = 16, 17 do -- Check only weapon slots [^1]
				if not GetInventoryItemLink("player", s) then
					EquipItemByBagSlot(items[s], s)
				end
			end
			table.wipe(items)
		end)

		butt:SetNormalTexture("Interface\\Addons\\Nudist\\clothed")
		butt:SetPushedTexture("Interface\\Addons\\Nudist\\nude")

	elseif not InCombatLockdown() then

		butt:SetNormalTexture("Interface\\Addons\\Nudist\\nude")
		butt:SetPushedTexture("Interface\\Addons\\Nudist\\clothed")
		GetEmpties()

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
