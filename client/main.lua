ESX = nil
local PlayerData = {}
local eggsLoaded = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

Citizen.CreateThread(function()
	while true do
		local sleepThread = 500
		local player = PlayerPedId()
        local coords = GetEntityCoords(player)
		for i=1, #Config.Locations do
			local egg = Config.Locations[i]
			if GetDistanceBetweenCoords(coords, egg.coords, true) <= 2.0 and not egg.taken then
				if IsPedOnFoot(player) then
				  sleepThread = 5
				  ESX.ShowHelpNotification(_U('pick_egg'))
				    if IsControlJustReleased(0, 51) then
				    	collectEgg(player, egg)
				    	egg.taken = true
					end
				end
			end
		end
	  Citizen.Wait(sleepThread)
	end
end)


function collectEgg(player, egg)
	exports['mythic_progbar']:Progress({
        name = "collect_easter_egg",
        duration = Config.PickUpTime * 1000,
        label = _U('picking_egg'),
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistfbisetup1",
            anim = "hassle_intro_loop_f",
            flags = 1,
        },
    }, function(cancelled)
        if not cancelled then
			ClearPedTasksImmediately(player)
			Citizen.Wait(100)
			TriggerServerEvent('esx_easterhunt:reward')
			notification(_U('picked_egg'), 'inform')
		else
			notification(_U('not_picked_egg'), 'error')
        end
    end)
end

function spawnEggs()
	while not eggsLoaded do
		Citizen.Wait(0)
		for i=1, #Config.Locations do
			ESX.Game.SpawnObject(Config.Prop, Config.Locations[i].coords, function(egg)
				PlaceObjectOnGroundProperly(egg)
				Citizen.Wait(300)
				FreezeEntityPosition(egg, true)
			end)
		end
		eggsLoaded = true
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)--grace
		if NetworkIsHost() then
			spawnEggs()
		end
		break
    end
end)

function notification(text, type)
    if type == nil then
        type = 'inform'
    end
	if Config.UseMythicNotify then
		exports['mythic_notify']:DoLongHudText(type, text)
    else
        ESX.ShowNotification(text)
    end
end