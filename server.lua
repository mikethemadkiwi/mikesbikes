--Player Bike Table
local MikesBikes = {}
---- MikesBikes[source] = {bikeModel, posVector, degreeHading, despawnTimer}
local PaymentHandler = function(cost) print('Bike Rental Charge: ['..cost..']') return true end
RegisterServerEvent('mikesb:canhazbike')
AddEventHandler('mikesb:canhazbike', function(data)
        local newBike = {data[1].modelName, data[2], data[3], 0}
        --------
        if data[1].cost then
            local canipay = PaymentHandler(data[1].cost)
            if not canipay then 
                print('user unable to pay.')
                TriggerClientEvent('mikesb:nocannothazbike', source, newBike)
            else
                print('user paid.')
                TriggerClientEvent('mikesb:yescanhazbike', source, newBike)
            end
        end
        --------
end)
RegisterServerEvent('mikesb:bikeinfo')
AddEventHandler('mikesb:bikeinfo', function(data)
    MikesBikes[source] = data
    print('Bike will expire at '..data[6])
   TriggerClientEvent('mikesb:bikelist', -1, MikesBikes)
end)