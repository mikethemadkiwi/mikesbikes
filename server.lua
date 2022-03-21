--Player Bike Table
local MikesBikes = {}
---- MikesBikes[source] = {bikeModel, posVector, degreeHading, despawnTimer}
local PaymentHandler = function(cost) print('Bike Rental Charge: ['..cost..']') end
RegisterServerEvent('mikesb:canhazbike')
AddEventHandler('mikesb:canhazbike', function(data)
        local newBike = {data[1].modelName, data[2], data[3], 0}
        --------
        if data[1].cost then
            PaymentHandler(data[1].cost)
        end
        --------
        TriggerClientEvent('mikesb:yescanhazbike', source, newBike)
end)

RegisterServerEvent('mikesb:bikeinfo')
AddEventHandler('mikesb:bikeinfo', function(data)
    MikesBikes[source] = data
    print(data[6])
   -- update everyone else.
   TriggerClientEvent('mikesb:bikelist', -1, MikesBikes)
end)