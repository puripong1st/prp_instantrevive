RegisterFontFile('RSU') -- the name of your .gfx, without .gfx
local fontId = RegisterFontId('RSU') -- the name from the .xml
local ZE = GetCurrentResourceName()
local isHeal = false
local useItem = false
local isUsingPainkiller = false

ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
    

	ESX.PlayerData = ESX.GetPlayerData()
end)

-- When Job Changed
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if IsHeal then
            if IsControlPressed(0, 155) then
                Wait(100)
                if IsControlPressed(0, 104) then
                    ClearPedTasks(PlayerPedId())
                end
            end
        end
    end
end)


RegisterNetEvent('prp_instantrevive:useAed')
AddEventHandler('prp_instantrevive:useAed', function()
    if not isUsingAed then
        isUsingAed = true
        if not IsPedOnFoot(PlayerPedId()) then
            TriggerEvent("pNotify:SendNotification", {
                text = "ไม่สามารถใช้งานได้",
                type = "error",
                timeout = 3000,
                layout = "centerRight",
                queue = "global"
            })
            return
        end
    
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer == -1 or closestDistance > 1.3 then
            TriggerEvent("pNotify:SendNotification", {
                text = "ไม่มีผู้เล่นอยู่ใกล้",
                type = "error",
                timeout = 3000,
                layout = "centerRight",
                queue = "global"
            })
            return
        else

            local closestPlayerPed = GetPlayerPed(closestPlayer)

            if IsPedDeadOrDying(closestPlayerPed, 1) then

                useItem = true

                TriggerEvent("mythic_progbar:client:progress", {
                    name = "revive",
                    duration = Setting.ReviveTime,
                    label = "กำลังปั๊มหัวใจ",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    },

                }, function(status)
                    if not status then
                        TriggerServerEvent('prp_instantrevive:removeItem', 'aed')
                        TriggerServerEvent('prp_instantrevive:revive_heal', GetPlayerServerId(closestPlayer))
                        useItem = false
                    end
                end)


                local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
                local cwhile = math.ceil(Setting.ReviveTime/1000)
                for i = 1, cwhile, 1 do
                    Citizen.Wait(900)

                    ESX.Streaming.RequestAnimDict(lib, function()
                        TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                    end)
                end
                isUsingAed = false
            else
                TriggerEvent("pNotify:SendNotification", {
                    text = "ผูเล่นไม่ได้สลบอยู่",
                    type = "error",
                    timeout = 3000,
                    layout = "centerRight",
                    queue = "global"
                })
            end
        end
    end

end)

RegisterNetEvent("mythic_progbar:client:cancel")
AddEventHandler("mythic_progbar:client:cancel", function()
    if useItem then
        ClearPedTasks(PlayerPedId())
        useItem = false
    end
    if isHeal then
        isHeal = false
    end
end)


RegisterNetEvent('prp_instantrevive:usePainkiller')
AddEventHandler('prp_instantrevive:usePainkiller', function()
    if not isUsingPainkiller then
        isUsingPainkiller = true

        if not IsPedOnFoot(PlayerPedId()) then
            TriggerEvent("pNotify:SendNotification", {
                text = "ไม่สามารถใช้งานได้",
                type = "error",
                timeout = 3000,
                layout = "centerRight",
                queue = "global"
            })
            return
        end
    
        if not isHeal then
            isHeal = true
            useItem = true

            RequestAnimDict("anim@heists@narcotics@funding@gang_idle")
            while not HasAnimDictLoaded("anim@heists@narcotics@funding@gang_idle") do
                Citizen.Wait(0)
            end

            TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 8.0, 8.0, -1, 1, 1, 0, 0, 0)

            TriggerEvent("mythic_progbar:client:progress", {
                name = "heal",
                duration = 3000,
                label = "กำลังพันแผล",
                useWhileDead = true,
                canCancel = false,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                },
           
            }, function(status)
                if not status then
                    TriggerServerEvent('prp_instantrevive:removeItem', 'bandage')
                    TriggerEvent('prp_instantrevive:heal', 'small')
                    isHeal = false
                    useItem = false
                end
            end)
            isUsingPainkiller = false
        else
            TriggerEvent("pNotify:SendNotification", {
                text = "รอสักครู่",
                type = "error",
                timeout = 3000,
                layout = "centerRight",
                queue = "global"
            })
        end
    end
end)


RegisterNetEvent('prp_instantrevive:heal')
AddEventHandler('prp_instantrevive:heal', function(healType)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)

    if healType == 'small' then
        local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
        local fixHeal = GetEntityHealth(playerPed) + 40
        SetEntityHealth(playerPed, fixHeal)
    elseif healType == 'big' then
        local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
        SetEntityHealth(playerPed, maxHealth)
    end

end)


RegisterNetEvent('prp_instantrevive:revive_heal')
AddEventHandler('prp_instantrevive:revive_heal', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

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

		StopScreenEffect('DeathFailOut')
		DoScreenFadeIn(800)
	end)
end)

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)
    SetEntityHealth(ped, 150)
	ESX.UI.Menu.CloseAll()
end