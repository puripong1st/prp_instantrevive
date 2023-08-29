ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem(Setting['ไอเทมใช้ชุบ'], function(source)
	TriggerClientEvent('prp_instantrevive:onAed2', source)
end)


RegisterServerEvent('prp_instantrevive:RemoveItem')
AddEventHandler('prp_instantrevive:RemoveItem', function(item , count)
	local xPlayer  = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, count)
end)

RegisterServerEvent('prp_instantrevive:revive_sv')
AddEventHandler('prp_instantrevive:revive_sv', function(target)
		TriggerClientEvent('prp_instantrevive:revive_cl', target)
end)

RegisterServerEvent('prp_instantrevive:RemoveCooldown_sv')
AddEventHandler('prp_instantrevive:RemoveCooldown_sv', function(target)
		TriggerClientEvent('prp_instantrevive:RemoveCooldown', target)
end)

ESX.RegisterCommand('cooldown', 'admin', function(xPlayer, args, showError)
	args.playerId.triggerEvent('prp_instantrevive:RemoveCooldown', target)
end, true, {help = 'ลบติดคลูดาวน์', validate = true, arguments = {
	{name = 'playerId', help = 'ไอดีผู้เล่น', type = 'player'}
}})

ESX.RegisterCommand('revivecd', 'admin', function(xPlayer, args, showError)
	args.playerId.triggerEvent('prp_instantrevive:revive_cl', target)
end, true, {help = 'ชุบผู้เล่นแบบไม่ติดคลูดาวน์', validate = true, arguments = {
	{name = 'playerId', help = 'ไอดีผู้เล่น', type = 'player'}
}})
