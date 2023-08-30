local ZE = GetCurrentResourceName()

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function IsInventoryAvailable(xPlayer, class, amount)
	if xPlayer["canCarryItem"] then
		return xPlayer["canCarryItem"](class, amount)
	else
		local item = xPlayer.getInventoryItem(class)
		return item and item["limit"] and (item["limit"] == -1 or item["limit"] ~= -1 and (item.count + amount) <= item["limit"]) or false
	end
end

RegisterServerEvent('prp_instantrevive:revive_heal')
AddEventHandler('prp_instantrevive:revive_heal', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('prp_instantrevive:revive_heal', target)
end)

ESX.RegisterUsableItem('bandage', function(source)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	TriggerClientEvent('prp_instantrevive:usePainkiller', _source)
end)

ESX.RegisterUsableItem(Setting.ReviveItem, function(source)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	TriggerClientEvent('prp_instantrevive:useAed', _source)
end)

RegisterServerEvent('prp_instantrevive:removeItem')
AddEventHandler('prp_instantrevive:removeItem', function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, 1)
end)