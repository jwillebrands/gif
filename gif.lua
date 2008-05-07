local bankopen
local bagframestring = "ContainerFrame%dItem%d"
local highlighted = {}

--Create frame to monitor some events.
local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("BANKFRAME_CLOSED")
frame:SetScript("OnEvent", function(frame, event) if (event == "BANKFRAME_OPENED") then bankopen = true else bankopen = false end end)


local function GIF_HighlightButton(button)
	local buttonNormalTexture = getglobal(button.."NormalTexture")
	local buttonIconTexture = getglobal(button.."IconTexture")
	buttonNormalTexture:SetVertexColor(0,1,0)
	buttonIconTexture:SetVertexColor(0,1,0)
	table.insert(highlighted, button)
end

local function GIF_ClearHighlights()
	for i,button in ipairs(highlighted) do
		local buttonNormalTexture = getglobal(button.."NormalTexture")
		local buttonIconTexture = getglobal(button.."IconTexture")
		buttonNormalTexture:SetVertexColor(1,1,1)
		buttonIconTexture:SetVertexColor(1,1,1)
		highlighted[i] = nil
	end
end

local function GIF_FindItem(rangestart, rangeend, item)
	GIF_ClearHighlights()
	OpenAllBags(true)
	GIF_Time = time()
	for bagID=rangestart, rangeend do
		if (GetBagName(bagID) or bagID == BANK_CONTAINER) then
			for bagSlot=1, GetContainerNumSlots(bagID) do
				local itemLink = GetContainerItemLink(bagID, bagSlot)
				if itemLink then
					local itemName = GetItemInfo(itemLink)
					if (itemName and itemName:lower():find(item)) then
						if (not frame:GetScript("OnUpdate")) then
							frame:SetScript("OnUpdate", function(frame) if (time() > GIF_Time+10) then GIF_ClearHighlights() GIF_Time = nil frame:SetScript("OnUpdate", nil) end end)
						end						
						--Figure out some way to get the framename and set vertex color.
						if (bagID ~= BANK_CONTAINER) then
							GIF_HighlightButton(string.format(bagframestring, bagID+1, GetContainerNumSlots(bagID)-bagSlot+1))
						else
							GIF_HighlightButton("BankFrameItem"..bagSlot)
						end
					end
				end
			end
		end
	end
end

local function GIF_Slash(item)
	if (item and item ~= "") then
		if bankopen then
			GIF_FindItem(BANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS, item)
		else
			GIF_FindItem(0, NUM_BAG_SLOTS, item)
		end
	else
		ChatFrame1:AddMessage("|cffffff78Item Finder|r - You forgot to enter an item to find. Usage /find item.")
	end
end

--Reg slash command
SlashCmdList["GIF"] = GIF_Slash
SLASH_GIF1 = "/find"
SLASH_GIF2 = "/gif"