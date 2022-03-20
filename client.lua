local POLYDEBUG = true
local isReady = false
local BikeStyles = {
	{
		modelName = 'BMX',		
	},
	{
		modelName = 'FIXTER',		
	},
	{
		modelName = 'CRUISER',		
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
bikeComboZone = nil
-- Object Name:	prop_bikerack_2
-- Object Hash:	-1314273436
-- Object Hash (uInt32):	2980693860
--------------INIT--------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)		
        local pCoords = GetEntityCoords(PlayerPedId())
		if NetworkIsPlayerActive(PlayerId()) then
			for j=1, #BikeStand do
				local distanceToStand = #(pCoords -  BikeStand[j].pos)
				if distanceToStand < 49 then
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

				end
			end
			----
			bikeComboZone = ComboZone:Create(activePzones, {name="BikeRentalList", debugPoly=POLYDEBUG})
			bikeComboZone:onPlayerInOut(function(isPointInside, point, zone)
				if zone then
					if isPointInside then

						SendNUIMessage({
							zone = zone,
							bikes = BikeStyles
						})

					  else
						
						SendNUIMessage({
							close = true
						})

					  end
				end
			end)
			----
			isReady = true
			break
		end
	end
end)



--
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

-----------------------------------------
RegisterNUICallback('nuifocus', function(nuistate, cb)    
    SetNuiFocus(nuistate.state, nuistate.state)
    cb(true)
end)
-----------------------------------------
RegisterNUICallback('bikeSelected', function(bike, cb)
	print('bike selected by nui')
    for j=1, #bike do
		print(bike[j])  
	end
    cb(true)
end)