local function isInList(name)
    local retval = false
    if Config.CurrentVehicles ~= nil and next(Config.CurrentVehicles) ~= nil then
        for k in pairs(Config.CurrentVehicles) do
            if Config.CurrentVehicles[k] == name then
                retval = true
            end
        end
    end
    return retval
end

local function generateVehicleList()
    Config.CurrentVehicles = {}
    for i = 1, 40, 1 do
        local randVehicle = Config.Vehicles[math.random(1, #Config.Vehicles)]
        if not isInList(randVehicle) then
            Config.CurrentVehicles[i] = randVehicle
        end
    end
    TriggerClientEvent("qb-scapyard:client:setNewVehicles", -1, Config.CurrentVehicles)
end

lib.callback.register('qb-scrapyard:server:checkOwnerVehicle', function(_, plate)
    local vehicle = MySQL.scalar.await("SELECT `plate` FROM `player_vehicles` WHERE `plate` = ?", {plate})
    if not vehicle then
        return true
    else
        return false
    end
end)

RegisterNetEvent('qb-scrapyard:server:LoadVehicleList', function()
    TriggerClientEvent("qb-scapyard:client:setNewVehicles", source, Config.CurrentVehicles)
end)

RegisterNetEvent('qb-scrapyard:server:ScrapVehicle', function(listKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Config.CurrentVehicles[listKey] then return end

    for _ = 1, math.random(2, 4), 1 do
        local item = Config.Items[math.random(1, #Config.Items)]
        Player.Functions.AddItem(item, math.random(25, 45))
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
        Wait(500)
    end

    local luck = math.random(1, 8)
    local odd = math.random(1, 8)
    if luck == odd then
        local random = math.random(10, 20)
        Player.Functions.AddItem("rubber", random)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["rubber"], 'add')
    end

    Config.CurrentVehicles[listKey] = nil
    TriggerClientEvent("qb-scapyard:client:setNewVehicles", -1, Config.CurrentVehicles)
end)

CreateThread(function()
    Wait(1000)
    while true do
        generateVehicleList()
        Wait(1000 * 60 * 60)
    end
end)
