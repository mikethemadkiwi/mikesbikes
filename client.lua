local POLYDEBUG = true
local isReady = false
local BikeStyles = {
	{
		modelName = 'BMX',	
		cost = 1			
	},
	{
		modelName = 'FIXTER',
		cost = 1				
	},
	{
		modelName = 'CRUISER',
		cost = 1		
	},
}
local BikeStand = {
	{	
		uid = 'observatory1',		
		pos=vector3(-425.397, 1207.813, 324.76),
		h= 255.0,
		spawnrider={}

	},	
	{
		uid = 'townhall1',		
		pos=vector3(-609.717, -167.174, 36.95),
		h= 16.77,
		spawnrider={}

	},	
}
activeStands = {}
activePzones = {}
Blip = {}
BikeList = {}
bikeComboZone = nil
-- Object Name:	prop_bikerack_2
-- Object Hash:	-1314273436
-- Object Hash (uInt32):	2980693860
------------FUNCTIONS-----------
local spawnBikeAtVehNode = function(bModel, cPos, cHead)
	local model = (type(bModel) == 'number' and bModel or GetHashKey(bModel))
	Citizen.CreateThread(function()
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end
		abike = CreateVehicle(model, cPos.x, cPos.y, cPos.z, cHead, true, false)
		abikeNetId      = NetworkGetNetworkIdFromEntity(abike)
		SetNetworkIdCanMigrate(abikeNetId, true)
		SetEntityAsMissionEntity(abike, true, false)
		SetVehicleHasBeenOwnedByPlayer(abike, false)
		SetDisableVehicleWindowCollisions(abike, false)
		SetEntityInvincible(abike, true)
		SetVehicleNeedsToBeHotwired(abike, false)
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(cPos.x, cPos.y, cPos.z)
		while not HasCollisionLoadedAroundEntity(abike) do
			RequestCollisionAtCoord(cPos.x, cPos.y, cPos.z)
			Citizen.Wait(0)
		end
		SetVehRadioStation(abike, 'OFF')
		--
		print('bike spawn:'.. abike .. ' netid: '.. abikeNetId ..'')
		TaskWarpPedIntoVehicle(PlayerPedId(), abike, -1)
		print(os.time())
		TriggerServerEvent('mikesb:bikeinfo', {abike, abikeNetId, model, cPos, cHead, 0})		
		--
		if cb ~= nil then
			cb(abike)
		end
	end)
end
--------------INIT--------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)	
		if NetworkIsPlayerActive(PlayerId()) then
			for j=1, #BikeStand do
					activeStands[j] = CreateObject(-1314273436, BikeStand[j].pos.x, BikeStand[j].pos.y, BikeStand[j].pos.z, false, false, false)
					SetEntityHeading(activeStands[j], BikeStand[j].h)
					FreezeEntityPosition(activeStands[j], true)
					--
					table.insert(activePzones, CircleZone:Create(vector3(BikeStand[j].pos.x, BikeStand[j].pos.y, BikeStand[j].pos.z), 2.0, {
						name=BikeStand[j].uid,
						useZ=false,
						data=BikeStand[j],
						debugPoly=POLYDEBUG
					}))	
					bikeComboZone = ComboZone:Create(activePzones, {name="BikeRentalList", debugPoly=POLYDEBUG})
					bikeComboZone:onPlayerInOut(function(isPointInside, point, zone)
						if zone then
							if isPointInside then		
								SendNUIMessage({
									zone = zone.data,
									bikes = BikeStyles
								})	
							else							
								SendNUIMessage({
									close = true
								})	
							end
						end
					end)
			end			
			break
		end
	end
end)
--------------BIKE RACK LOOP--------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)		
        local pCoords = GetEntityCoords(PlayerPedId())
		if NetworkIsPlayerActive(PlayerId()) then
			for j=1, #BikeStand do
				local distanceToStand = #(pCoords -  BikeStand[j].pos)
				if distanceToStand < 15 then
		
				end
			end
		end
	end
end)
--------------BLIP LOOP--------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        if isReady == true then
            for i=1, #BikeStand do
                if not DoesBlipExist(Blip[BikeStand[i].uid]) then                    
                    Blip[BikeStand[i].uid] = AddBlipForCoord(BikeStand[i].pos.x, BikeStand[i].pos.y, BikeStand[i].pos.z)
                    SetBlipSprite(Blip[BikeStand[i].uid], 226)
                    SetBlipDisplay(Blip[BikeStand[i].uid], 4)
                    SetBlipScale(Blip[BikeStand[i].uid], 1.0)
                    SetBlipColour(Blip[BikeStand[i].uid], 28)
                    SetBlipAsShortRange(Blip[BikeStand[i].uid], true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Mike's Bike Rental")
                    EndTextCommandSetBlipName(Blip[BikeStand[i].uid])
                end
            end
        end
    end
end)

-- NET HANDLERS
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for j=1, #activeStands do
            DeleteObject(activeStands[j])        
        end
    end
end)
--
RegisterNetEvent('mikesb:bikelist')
AddEventHandler('mikesb:bikelist', function(bObj)    
   BikeList = bObj
end)
--
RegisterNetEvent('mikesb:yescanhazbike')
AddEventHandler('mikesb:yescanhazbike', function(bObj)
	-- for j=1, #bObj do print(bObj[j]) end
	local bSpawn = spawnBikeAtVehNode(bObj[1], bObj[2], bObj[3])
end)
--
RegisterNetEvent('mikesb:destroybike')
AddEventHandler('mikesb:destroybike', function(bObj)    
   
end)

-----------------------------------------
RegisterNUICallback('nuifocus', function(nuistate, cb)    
    SetNuiFocus(nuistate.state, nuistate.state)
    cb(true)
end)
-----------------------------------------
RegisterNUICallback('bikeSelected', function(data, cb)
		local bikemodel = data.bike.modelName
		local retval, outPosition, outHeading = GetClosestVehicleNodeWithHeading(data.zone.pos.x,data.zone.pos.y,data.zone.pos.z,1,100,2.5)
		print(outPosition.x..'/'..outPosition.y..'/'..outPosition.z..' h:'..outHeading)
		TriggerServerEvent('mikesb:canhazbike', {data.bike, outPosition, outHeading})		
    cb(true)
end)