Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local FirstSpawn, PlayerLoaded = true, false

IsDead = false
local PressX = false
ESX = nil
local playerJob = nil


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    playerJob = job
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    PlayerLoaded = true
    ESX.PlayerData = ESX.GetPlayerData()
    playerJob = ESX.GetPlayerData().job
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	PlayerLoaded = true
end)


AddEventHandler('playerSpawned', function()
	IsDead = false

	CloseUi()
	if FirstSpawn then
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false

		NetworkSetFriendlyFireOption(true)

		ESX.TriggerServerCallback('prp_instantrevive:getDeathStatus', function(isDead)
			if isDead and Setting['Debug-Call'] then
				while not PlayerLoaded do
					Citizen.Wait(1000)
				end

				--ESX.ShowNotification(_U('combatlog_message'))
				Citizen.Wait(1000)
				SetEntityHealth(PlayerPedId(), 0)
			end
		end)
	end
end)

-- Disable most inputs when dead
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsDead then
			DisableAllControlActions(0)
			EnableControlAction(0, Keys['Q'], true)
			EnableControlAction(0, Keys['G'], true)
			EnableControlAction(0, Keys['R'], true)
			EnableControlAction(0, Keys['T'], true)
			EnableControlAction(0, Keys['E'], true)
			EnableControlAction(0, Keys['M'], true)
			EnableControlAction(0, Keys['H'], true)
			EnableControlAction(0, Keys['DELETE'], true)
			EnableControlAction(0, Keys['F6'], true)
			EnableControlAction(0, Keys['ENTER'], true)
			EnableControlAction(0, 18, true)
			EnableControlAction(0, 176, true)
			EnableControlAction(0, 191, true)
			EnableControlAction(0, 201, true)
			EnableControlAction(0, 215, true)
			EnableControlAction(0, 44, true)
			EnableControlAction(0, 73, true)
		else
			Citizen.Wait(500)
		end
	end
end)

function OnPlayerDeath()
	IsDead = true
	ESX.UI.Menu.CloseAll()

	TriggerServerEvent('prp_instantrevive:setDeathStatus', true)

	SendNUIMessage({
		type = 'ui',
		status = true,
		id = GetPlayerServerId(PlayerId()),
	})

	StartDeadTimer()

end

function ClearBody()
	Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsDead then
                PressX = true
                ClearPedTasksImmediately(PlayerPedId())
                ClearBodyUi(true)
                Citizen.Wait(5000)
                ClearPedTasksImmediately(PlayerPedId())
                ClearBodyUi(false)
                PressX = false
                break
            end
        end
    end)
end

function secondsToClock(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return "00 : 00"
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))

		return mins .. " นาที " .. secs .. " วินาที"
	end
end

function StartDeadTimer()
	local deadTimer = ESX.Math.Round(Setting.RespawnTime / 1000)

    -- respawn timer
	Citizen.CreateThread(function()
		while deadTimer > 0 and IsDead do
			Citizen.Wait(1000)

			if deadTimer > 0 then
				deadTimer = deadTimer - 1
			end
		end
	end)

    -- Respawn Logic
	Citizen.CreateThread(function()
		while deadTimer > 0 and IsDead do
			Citizen.Wait(0)

            if IsControlPressed(0, Keys['X']) and not PressX then
                ClearBody()
            end

			RespawnTime(secondsToClock(deadTimer)) -- send to ui
		end

		if deadTimer < 1 and IsDead then
			TriggerServerEvent('prp_instantrevive:revive')
		end
	end)
end


function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)
	SetEntityHealth(PlayerPedId(), 110)

	ESX.UI.Menu.CloseAll()
end


function RespawnByJob()
    local playerPed = PlayerPedId()
    local respawnCoords = nil
	local playerName = GetPlayerName(PlayerId())
	if Setting['Debug-Call'] then
        print("^5PRP-Debug : ^7PlayerJob :", playerJob and playerJob.name or "nil") -- Add this line
	end

    if playerJob and playerJob.name == 'burapon' then
        respawnCoords = vector3(-1743.93, 167.08, 64.59) 
    elseif playerJob and playerJob.name == 'inton' then
        respawnCoords = vector3(-1156.92, -1719.03, 4.65) 
	elseif playerJob and playerJob.name == 'prachachuen' then
        respawnCoords = vector3(1013.02, -2335.59, 30.87)
	elseif playerJob and playerJob.name == 'kanok' then
        respawnCoords = vector3(883.36, -28.38, 79.00)
    else
        respawnCoords = vector3(-291.4100036621094, -927.5, 31.29999923706054) 
    end

    local formattedCoords = {
        x = respawnCoords.x,
        y = respawnCoords.y,
        z = respawnCoords.z
    }
	if Setting['Debug-Call'] then
        local playerName = GetPlayerName(PlayerId())
        print("^5PRP-Debug : ^7Respawning:", playerName, playerJob and playerJob.name or "nil", respawnCoords)
    end
    ESX.SetPlayerData('lastPosition', formattedCoords)
    ESX.SetPlayerData('loadout', {})
    TriggerServerEvent('esx:updateLastPosition', formattedCoords)
    RespawnPed(playerPed, formattedCoords, 0.0)
end



AddEventHandler('esx:onPlayerDeath', function(data)
	OnPlayerDeath()
	
end)


RegisterNetEvent('prp_instantrevive:revive')
AddEventHandler('prp_instantrevive:revive', function()
	local playerPed = PlayerPedId()

	TriggerServerEvent('prp_instantrevive:setDeathStatus', false)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(50)
		end

		--local formattedCoords = GetEntityCoords(playerPed)
		--ESX.SetPlayerData('lastPosition', formattedCoords)
		--TriggerServerEvent('esx:updateLastPosition', formattedCoords)
		--RespawnPed(playerPed, formattedCoords, 0.0)
		RespawnByJob()

		StopScreenEffect('SwitchHUDIn')
		DoScreenFadeIn(800)
	end)
end)



RegisterNetEvent('prp_instantrevive:reviveall')
AddEventHandler('prp_instantrevive:reviveall', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

    if IsDead  then
	TriggerServerEvent('prp_instantrevive:setDeathStatus', false)

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(50)
		end

		local formattedCoords = {
			x = ESX.Math.Round(coords.x, 1),
			y = ESX.Math.Round(coords.y, 1),
			z = ESX.Math.Round(coords.z, 1)
		}

		ESX.SetPlayerData('lastPosition', formattedCoords)

		TriggerServerEvent('esx:updateLastPosition', formattedCoords)

		RespawnPed(playerPed, formattedCoords, 0.0)

		StopScreenEffect('SwitchHUDIn') --DeathFailOut ตายแล้วเกิดจอเบลอ
		DoScreenFadeIn(800)
	    end)
    end
end)



CloseUi = function ()
	SendNUIMessage({
		type = 'ui',
		status = false
	})
end


ClearBodyUi = function (A)
	SendNUIMessage({
		type = 'addclass',
		status = A,
	})
end


RespawnTime = function(text)
	SendNUIMessage({
		type = 'time',
		time = text
	})
end