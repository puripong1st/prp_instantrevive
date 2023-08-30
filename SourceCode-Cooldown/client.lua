ESX = nil
local passive = false
local join = false
local AED = false
local reviving = false
local isKPressed = false
local kButton = 311 -- รหัสปุ่ม K
local cooldownTime = 0
local cooldownStartTime = 0
local actionsDone = 0
local cooldownTriggered = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local playerped = GetPlayerPed(-1)

        if IsControlJustReleased(0, kButton) and passive and not cooldownTriggered then
            cooldownTriggered = true
            TriggerEvent("prp_instantrevive:RemoveCooldown")
            
        end

    end
    SetLocalPlayerAsGhost(false)
end)

RegisterNetEvent("prp_instantrevive:RemoveCooldown")
AddEventHandler("prp_instantrevive:RemoveCooldown", function()
    local playerPed = PlayerPedId()
    local playerJob = ESX.GetPlayerData().job
    local playerName = GetPlayerName(PlayerId())

    exports['okokNotify']:Alert("Cooldown", "รออีก 5 วินาที เพื่อที่จะลดคลูดาว", 5000, 'success')
    Citizen.Wait(5000)
    SetLocalPlayerAsGhost(false)
    passive = false
    exports['okokNotify']:Alert("Cooldown", "คุณถูกปลดคูลดาวน์", 5000, 'success')
    if Setting['Debug-Call'] then
    print("^5PRP-Debug : ^7Cooldown Reduced for:", playerName, playerJob and playerJob.name or "nil")
    end
    local x, y, z = table.unpack(GetEntityCoords(playerped))
    local prop = CreateObject(GetHashKey(Setting['พร็อพ']), x, y, z + 0.2,true, true, true)
    local boneIndex = GetPedBoneIndex(playerped, 0x322c)
    local position = GetEntityCoords(GetPlayerPed(PlayerId()), false)
    local object = GetClosestObjectOfType(position.x, position.y,position.z, 15.0,GetHashKey(Setting['พร็อพ']),false, false, false)
    if object ~= 0 then DeleteObject(object) end
    cooldownTriggered = false
end)


if Setting['ตายแล้วตัวล่องหน'] then
    AddEventHandler("playerSpawned", function()
        if not join then
            join = true
        else
            if not AED then
                local playerped = GetPlayerPed(-1)
                local pc = GetEntityCoords(playerped)
                local outzone = false
                local playerPed = PlayerPedId()
                local playerJob = ESX.GetPlayerData().job
                local playerName = GetPlayerName(PlayerId())
                for k, v in pairs(Setting['โซนที่ไม่ติดคลูดาวน์']) do
                    outzone = GetDistanceBetweenCoords(pc, v['ตำแหน่ง'], true) > v['ระยะ']
                    if not outzone then 
                        break 
                    end
                end
                if outzone then
                    if not passive then
                        passive = true
                        SetLocalPlayerAsGhost(true)
                        exports['okokNotify']:Alert("Cooldown ", "คุณได้ติดคลูดาวน์ (โปรดรอ)", 5000, 'error')
                        if Setting['Debug-Call'] then
                            print("^5PRP-Debug : ^7Cooldown have :", playerName, playerJob and playerJob.name or "nil")
                        end
    
                        -- เรียกใช้เวลาที่ติดคูลดาวน์
                        cooldownTime = Setting['เวลาที่ติดคลูดาวน์'] * 1000
                        cooldownStartTime = GetGameTimer()
    
                        if Setting['ตายแล้วมีพร็อพบนหัว'] then
                            local x, y, z = table.unpack(GetEntityCoords(playerped))
                            local prop = CreateObject(GetHashKey(Setting['พร็อพ']), x, y, z + 0.2,true, true, true)
                            local boneIndex = GetPedBoneIndex(playerped, 0x322c)
                            AttachEntityToEntity(prop, playerped, boneIndex, 0.25, 0.00, 0.00, 0.0, 90.00, 198.0, true, true, false, true, 1,true)
                        end
    
                        Citizen.Wait(Setting['เวลาที่ติดคลูดาวน์'] * 1000)
                        SetLocalPlayerAsGhost(false)
                        passive = false
    
                        if Setting['ตายแล้วมีพร็อพบนหัว'] then
                            local position = GetEntityCoords(GetPlayerPed(PlayerId()), false)
                            local object = GetClosestObjectOfType(position.x, position.y,position.z, 15.0,GetHashKey(Setting['พร็อพ']),false, false, false)
                            if object ~= 0 then DeleteObject(object) end
                        end
                        exports['okokNotify']:Alert("Cooldown", "คุณได้คลูดาวน์เสร็จแล้ว", 5000, 'success')
                        if Setting['Debug-Call'] then
                            print("^5PRP-Debug : ^7Cooldown Success :", playerName, playerJob and playerJob.name or "nil")
                        end
                    end
                else
                    Citizen.Wait(Setting['ดีเลย์การเช็คในโซน'])
                    AED = false
                end
            end
        end
    end)
end
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerped = GetPlayerPed(-1)

        if passive then
            local coords = GetEntityCoords(playerped)

            local currentTime = GetGameTimer()
            local remainingTime = cooldownTime - (currentTime - cooldownStartTime)
            if remainingTime < 0 then
                remainingTime = 0
            end
            for k, v in pairs(GetNeareastPlayers()) do
                local x, y, z = table.unpack(v.coords)
                time = 1
                local textSize = 0.60  -- ขนาดของตัวอักษร
                if IsPedInAnyVehicle(playerped, false) then
                    textSize = 1.0  -- ขนาดของตัวอักษรเมื่ออยู่ในรถ
                end
                Draw3DText(coords.x, coords.y, coords.z + 1.0, "🐔", textSize)
                Draw3DText(coords.x, coords.y, coords.z + 0.9, "Cooldown : " .. math.floor(remainingTime / 1000) .. "s", textSize - 0.10)
            end
        end
    end
end)


function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players_clean = {}
    local playerCoords = GetEntityCoords(playerPed)
    local players, _ = GetPlayersInArea(playerCoords, Setting['ระยะการมองเห็น'])
    for i = 1, #players, 1 do
        local playerServerId = GetPlayerServerId(players[i])
        local player = GetPlayerFromServerId(playerServerId)
        local ped = GetPlayerPed(player)
        if IsEntityVisible(ped) then
            table.insert(players_clean, {coords = GetEntityCoords(ped)})
        end
    end
    return players_clean
end


function GetPlayersInArea(coords, area)
	local players, playersInArea = GetPlayers(), {}
	local coords = vector3(coords.x, coords.y, coords.z)
	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)

		if #(coords - targetCoords) <= area then
			table.insert(playersInArea, players[i])
		end
	end
	return playersInArea
end
function GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end


-- if Setting['DisableControl'] then
Citizen.CreateThread(function()
    local mezc = 100
    while true do
        local ped = PlayerPedId()
        local playerped = GetPlayerPed(-1)
        if passive then

            mezc = Setting['ลูปการปิดปุ่มต่อย']
            NetworkSetPlayerIsPassive(true)
            NetworkSetFriendlyFireOption(false)
            SetPedCanRagdoll(ped, false)
            DisablePlayerFiring(player, true)
            SetEntityInvincible(playerped, true)
            SetEntityAlpha(playerped, 200, false)
            if Setting['ปิดปุ่มโจมตี'] then
                DisableControlAction(2, 13)
                DisableControlAction(2, 24)
                DisableControlAction(2, 25)
                DisableControlAction(2, 140)
                DisableControlAction(2, 141)
                DisableControlAction(2, 143)
                DisableControlAction(2, 157)
                DisableControlAction(2, 158)
                DisableControlAction(2, 257)
                DisableControlAction(2, 263)
                DisableControlAction(2, 264)
            end
        else

            mezc = 100
            NetworkSetFriendlyFireOption(true)
            SetPedCanRagdoll(ped, true)
            SetEntityInvincible(playerped, false)
            NetworkSetPlayerIsPassive(false)
            ResetEntityAlpha(playerped)
            DeleteObject(object)
        end
        Citizen.Wait(mezc)
    end
end)

RegisterNetEvent("prp_instantrevive:onAed2")
AddEventHandler("prp_instantrevive:onAed2", function()
    if not reviving then
        reviving = true
        if not passive then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer == -1 or closestDistance > 1.3 then
                reviving = false
                exports['okokNotify']:Alert("Cooldown", "ไม่มีผู้เล่นอยู่ใกล้", 5000, 'error')
            else
                local closestPlayerPed = GetPlayerPed(closestPlayer)
                reviving = false
                if IsPedDeadOrDying(closestPlayerPed, 1) then
                    if not delay then
                        use = true
                        delay = true
                        local playerPed = PlayerPedId()

                        local lib, anim = "mini@cpr@char_a@cpr_str", "cpr_pumpchest"

                        TriggerEvent("mythic_progbar:client:progress", {
                            name = "unique_action_name",
                            duration = (Setting['เวลาในการใช้ยาชุบ'] * 1000),
                            label = "HEALING IN PROCESS",
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = false
                            }
                        }, function(cancelled)
                            if not cancelled then
                                if not IsPedDeadOrDying(GetPlayerPed(-1), 1) then
                                    reviving = false
                                    TriggerServerEvent("prp_instantrevive:revive_sv",GetPlayerServerId(closestPlayer))
                                else
                                    reviving = false
                                end
                            end
                        end)

                        for i = 1, 7, 1 do
                            Citizen.Wait(800)
                            ESX.Streaming.RequestAnimDict(lib, function()
                                TaskPlayAnim(PlayerPedId(), lib, anim, 5.0, -8.0,
                                            -1, 0, 0, false, false, false)
                            end)
                        end
                        TriggerServerEvent("prp_instantrevive:RemoveItem", Setting['ไอเทมใช้ชุบ'] , 1)
                        Citizen.Wait(2000)
                        delay = false
                    else
                        exports['okokNotify']:Alert("Cooldown", "กรุณารอ", 5000, 'error')
                    end
                else
                    reviving = false
                    ESX.ShowNotification("player not unconscious!")
                end
            end
        else
            reviving = false
            exports['okokNotify']:Alert("Cooldown", "ติดคูลดาวน์อยู่", 5000, 'error')
        end
    end
end)

RegisterNetEvent("prp_instantrevive:revive_cl")
AddEventHandler("prp_instantrevive:revive_cl", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    AED = true
    TriggerServerEvent("prp_instantrevive:setDeathStatus", false)

    Citizen.CreateThread(function()
        DoScreenFadeOut(800) -- effect

        while not IsScreenFadedOut() do 
            Wait(50) 
        end
        local formattedCoords = {
            x = ESX.Math.Round(coords.x, 1),
            y = ESX.Math.Round(coords.y, 1),
            z = ESX.Math.Round(coords.z, 1)
        }
        ESX.SetPlayerData("lastPosition", formattedCoords)

        TriggerServerEvent("esx:updateLastPosition", formattedCoords)
        -- ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		-- 	TriggerEvent('skinchanger:loadSkin', skin)
		-- end)

		RespawnPed(playerPed, coords)
        StopScreenEffect('DeathFailOut') -- effect
        DoScreenFadeIn(800) -- effect
    end)
end)

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	ClearPedBloodDamage(ped)
    SetEntityHealth(PlayerPedId(), Setting['เลือดตอนฟื้น'])
	ESX.UI.Menu.CloseAll()
end
RegisterFontFile('RSU') 
local fontId = RegisterFontId('RSU') 

function Draw3DText(x, y, z, text, newScale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = newScale * (1 / dist) * (1 / GetGameplayCamFov()) * 100
        SetTextScale(scale, scale)
        SetTextFont(fontId)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end