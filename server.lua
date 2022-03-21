--Player Bike Table
local MikesBikes = {}
---- MikesBikes[source] = {bikeModel, posVector, degreeHading, despawnTimer}
local PaymentHandler = function(cost) Print('i can charge: ['..cost..']') end
RegisterServerEvent('mikesb:canhazbike')
AddEventHandler('mikesb:canhazbike', function(data)
    local gSrc = source
    print('['.. gSrc ..']')
    MikesBikes[source] = {data[1].modelName, data[2], data[3], 0}
    --------
    if data[1].cost then
        PaymentHandler(data[1].cost)
    end
    --------
    TriggerClientEvent('mikesb:yescanhazbike', gSrc, MikesBikes[source])
    TriggerClientEvent('mikesb:bikelist', -1, MikesBikes)
end)