ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('prp_instantrevive:revive')
AddEventHandler('prp_instantrevive:revive', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local zPlayer = ESX.GetPlayerFromId(target)

	TriggerClientEvent('prp_instantrevive:revive', source)
end)

RegisterServerEvent('prp_instantrevive:reviveFast')
AddEventHandler('prp_instantrevive:reviveFast', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local zPlayer = ESX.GetPlayerFromId(target)

	TriggerClientEvent('prp_instantrevive:reviveFast', source)
end)


TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			print(('prp_instantrevive: %s used admin revive'):format(GetPlayerIdentifiers(source)[1]))
			TriggerClientEvent('prp_instantrevive:revive', tonumber(args[1]))
		end
	else
		TriggerClientEvent('prp_instantrevive:revive', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, { help = "revive", params = {{ name = 'id' }} })

TriggerEvent('es:addGroupCommand', 'reviveall', 'admin', function(source, args)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			print(('prp_instantrevive: %s used admin reviveall'):format(GetPlayerIdentifiers(source)[1]))
			TriggerClientEvent('prp_instantrevive:reviveall', tonumber(args[1]))
		end
	else
		TriggerClientEvent('prp_instantrevive:reviveall', -1)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, { help = "revive All" })



ESX.RegisterServerCallback('prp_instantrevive:getDeathStatus', function(source, cb)
	local identifier = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchScalar('SELECT is_dead FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(isDead)
		if isDead then
			print(('prp_instantrevive: %s attempted combat logging!'):format(identifier))
		end

		cb(isDead)
	end)
end)

RegisterServerEvent('prp_instantrevive:setDeathStatus')
AddEventHandler('prp_instantrevive:setDeathStatus', function(isDead)
	local identifier = GetPlayerIdentifiers(source)[1]

	if type(isDead) ~= 'boolean' then
		print(('prp_instantrevive: %s attempted to parse something else than a boolean to setDeathStatus!'):format(identifier))
		return
	end

	MySQL.Sync.execute('UPDATE users SET is_dead = @isDead WHERE identifier = @identifier', {
		['@identifier'] = identifier,
		['@isDead'] = isDead
	})
end)