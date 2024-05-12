local isWashing = false
local vehicle = nil
local deliveryBlip = nil
local deliveryCoords = nil
local lastDelivery = nil

local atmModels = {
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_flecca_atm'
}

function SpawnPed()
    local model = GetHashKey(Config.PedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    local pedLoc = Config.PedLocation.pedLoc
    print(Config.PedLocation.pedLoc)
    local ped = CreatePed(4, model, pedLoc.x, pedLoc.y, pedLoc.z, Config.PedLocation.heading, false, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
end

exports.ox_target:addModel(atmModels, {
    {
        name = "washmoney",
        label = "Wypierz pieniądze",
        icon = "fa-solid fa-washing-machine",
        onSelect = function(data)
            TriggerServerEvent('c21:washmoney')
            randomPoint()
        end,    
        canInteract = function(entity)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, deliveryCoords.x, deliveryCoords.y, deliveryCoords.z)
            return isWashing and distance < 3.0 
        end,
    }
})
exports.ox_target:addModel('s_m_y_winclean_01', {
    {
        name = "startwashmoney",
        label = "Wypierz pieniądze",
        icon = "fa-solid fa-washing-machine",
        event = "c21:startwashmoney",
        canInteract = function(entity)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local pedCoords = GetEntityCoords(entity)
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z)
            return distance < 5.0 and not isWashing
        end,
    },
    {
        name = "finishwashmoney",
        label = "Skończ pranie pieniądzy",
        icon = "fa-solid fa-washing-machine",
        event = "c21:finishwashmoney",
        canInteract = function(entity)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local pedCoords = GetEntityCoords(entity)
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z)
            return distance < 5.0 and isWashing
        end,
    },
})

function randomPoint()
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end

    local randomPoint
    repeat
        randomPoint = math.random(1, #Config.Points)
    until randomPoint ~= lastDelivery
    lastDelivery = randomPoint
    deliveryCoords = Config.Points[randomPoint]
    deliveryBlip = AddBlipForCoord(deliveryCoords.x, deliveryCoords.y, deliveryCoords.z)

    SetBlipRoute(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Punkt dostawy')
    EndTextCommandSetBlipName(deliveryBlip)
end  

RegisterNetEvent('c21:startwashmoney')
AddEventHandler('c21:startwashmoney', function() 
    if isWashing then
        ESX.ShowNotification('Najpierw zakończ poprzednie zlecenie')
        return
    end
    local moneyCount = exports.ox_inventory:GetItemCount(Config.BlackMoney)
    if moneyCount < Config.MinWash then
        ESX.ShowNotification('Potrzebujesz minimum ' .. Config.MinWash .. '$')
        return
    end
    local vehicleModel = Config.VehModel
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(500)
    end
    isWashing = true
    local vehCoords = Config.VehLocation.vehLoc
    vehicle = CreateVehicle(GetHashKey(vehicleModel), vehCoords.x ,vehCoords.y, vehCoords.z, Config.VehLocation.heading, true, false)
    randomPoint()
    ESX.ShowNotification('Zaczales prac pieniadze, na mapie masz zaznaczony punkt pod, który musisz sie udac!')
end)

RegisterNetEvent('c21:finishwashmoney')
AddEventHandler('c21:finishwashmoney', function()
    if vehicle == nil then
        ESX.ShowNotification('Nie moge znalezc twojego pojazdu!')
    end
    ESX.Game.DeleteVehicle(vehicle)
    isWashing = false
    RemoveBlip(deliveryBlip)
    ESX.ShowNotification('Skonczyles prac pieniadze!')
end)



Citizen.CreateThread(function()
    SpawnPed()
end)