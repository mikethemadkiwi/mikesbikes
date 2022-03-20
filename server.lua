--Player Bike Table
local MikesBikes = {}
---- MikesBikes[source] = {bikeModel, posVector, despawnTimer}
local PaymentHandler = function(cost) Print('i can charge: ['..cost..']') end
RegisterServerEvent('mikesb:canhazbike')
AddEventHandler('mikesb:canhazbike', function(bike, pos, head)
    local gSrc = source
    print('['.. gSrc ..']')
    -- make user a bike object
    MikesBikes[source] = {bike.modelName, pos, head, 0--despawnTimer}
    --------
    if bike.cost then
        PaymentHandler(bike.cost)
    end
    --------
    TriggerClientEvent('mikesb:yescanhazbike', gSrc, MikesBikes[source])
    TriggerClientEvent('mikesb:bikelist', -1, MikesBikes)
end)