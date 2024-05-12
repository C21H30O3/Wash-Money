RegisterNetEvent('c21:washmoneys')
AddEventHandler('c21:washmoneys', function() 
    local player = source
    local blackMoney = exports.ox_inventory:GetItemCount(player, Config.BlackMoney)
    if blackMoney <= 0 then
        TriggerClientEvent('esx:showNotification', player, 'Nie masz juz brudnych pieniedzy, wracaj na baze!')
        return
    end    
    local moneyToWash
    if blackMoney < Config.MinWash then
        moneyToWash = blackMoney
    else
        moneyToWash = math.random(Config.MinWash, Config.MaxWash)
    end        
    exports.ox_inventory:RemoveItem(player, Config.BlackMoney, moneyToWash)
    exports.ox_inventory:AddItem(player, Config.Money, moneyToWash)
    TriggerClientEvent('esx:showNotification', player, 'Wyprales ' .. moneyToWash .. '$')
end)
