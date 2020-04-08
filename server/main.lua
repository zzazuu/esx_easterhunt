ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('esx_easterhunt:reward')
AddEventHandler('esx_easterhunt:reward', function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    --local money   = math.random(Config.MoneyReward.min, Config.MoneyReward.max);
    --local item = math.random(1, #Config.Items)
    local reward = math.random(1, 10)
        if reward > 5 then
          local money = math.random(Config.MoneyReward.min, Config.MoneyReward.max);
          Citizen.Wait(200)
          xPlayer.addMoney(money)
          notification(_U('money_reward'), _source, 'success')
        elseif reward < 5 then
          local item = math.random(1, #Config.Items)
          Citizen.Wait(200)
          xPlayer.addInventoryItem(Config.Items[item], 1)
          notification(_U('item_reward'), _source, 'success')
        end
end)

function notification(text, target, type)
    if type == nil then
        type = 'inform'
    end
    if Config.UseMythicNotify then
        TriggerClientEvent('mythic_notify:client:SendAlert', target, { type = type, text = text})
    else
        TriggerClientEvent('esx:showNotification', target, text)
    end
end
