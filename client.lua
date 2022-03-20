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
------------FUNCTIONS-----------
local spawnBikeAtVehNode = function(bModel, cPos, cHead)
	local model = (type(bikemodel) == 'number' and bikemodel or GetHashKey(bikemodel))
	Citizen.CreateThread(function()
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end
		abike = CreateVehicle(model, outPosition.x, outPosition.y, outPosition.z, outHeading, true, false)
		abikeNetId      = NetworkGetNetworkIdFromEntity(abike)
		SetNetworkIdCanMigrate(abikeNetId, true)
		SetEntityAsMissionEntity(abike, true, false)
		SetVehicleHasBeenOwnedByPlayer(abike, false)
		SetDisableVehicleWindowCollisions(abike, false)
		SetEntityInvincible(abike, true)
		SetVehicleNeedsToBeHotwired(abike, false)
		SetModelAsNoLongerNeeded(model)
		RequestCollisionAtCoord(outPosition.x, outPosition.y, outPosition.z)
		while not HasCollisionLoadedAroundEntity(abike) do
			RequestCollisionAtCoord(outPosition.x, outPosition.y, outPosition.z)
			Citizen.Wait(0)
		end
		SetVehRadioStation(abike, 'OFF')
		print('bike spawn:'.. abike .. ' netid: '.. abikeNetId ..'')
		if cb ~= nil then
			cb(abike)
		end
	end)
end
--
local putPlayerPedOnBike = function(abike)

end
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
RegisterNUICallback('bikeSelected', function(data, cb)
		local bikemodel = data.bike.modelName
		local retval, outPosition, outHeading = GetClosestVehicleNodeWithHeading(data.zone.pos.x,data.zone.pos.y,data.zone.pos.z,1,100,2.5)
		print(outPosition.x..'/'..outPosition.y..'/'..outPosition.z..' h:'..outHeading)
		local bSpawn = spawnBikeAtVehNode(bikemodel, outPosition, outHeading)		
		local pedonbike = putPlayerPedOnBike(bSpawn)
    cb(true)
end)

-- int nodeTypeAsphaltRoad = 0;
-- int nodeTypeSimplePathOrAsphaltRoad = 1;
-- int nodeTypeWater = 3;
-- PATHFIND::GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(coordX, coordY, coordZ, &closestAsphaltRoad, &roadHeadingAsphaltRoad, nodeTypeAsphaltRoad, 3, 0);
-- PATHFIND::GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(coordX, coordY, coordZ, &closestWater, &roadHeadingWater, nodeTypeWater, 3, 0);



-- public enum Nodetype { AnyRoad, Road, Offroad, Water }    
-- public static Vector3 GenerateSpawnPos(Vector3 desiredPos, Nodetype roadtype, bool sidewalk){        
-- 	Vector3 finalpos = Vector3.Zero;
-- 	bool ForceOffroad = false;
-- 	OutputArgument outArgA = new OutputArgument();
-- 	int NodeNumber = 1;
-- 	int type = 0;
-- 	if (roadtype == Nodetype.AnyRoad) type = 1;
-- 	if (roadtype == Nodetype.Road) type = 0;
-- 	if (roadtype == Nodetype.Offroad) { type = 1; ForceOffroad = true; }
-- 	if (roadtype == Nodetype.Water) type = 3;
-- 	int NodeID = Function.Call<int>(Hash.GET_NTH_CLOSEST_VEHICLE_NODE_ID, desiredPos.X, desiredPos.Y, desiredPos.Z, NodeNumber, type, 300f, 300f);
-- 	if (ForceOffroad)
-- 	{
-- 		while (!Function.Call<bool>(Hash._GET_IS_SLOW_ROAD_FLAG, NodeID) && NodeNumber < 500)
-- 		{
-- 			NodeNumber++;
-- 			NodeID = Function.Call<int>(Hash.GET_NTH_CLOSEST_VEHICLE_NODE_ID, desiredPos.X, desiredPos.Y, desiredPos.Z, NodeNumber, type, 300f, 300f);             }        }        Function.Call(Hash.GET_VEHICLE_NODE_POSITION, NodeID, outArgA);        finalpos = outArgA.GetResult<Vector3>();        if (sidewalk) finalpos = World.GetNextPositionOnSidewalk(finalpos);        return finalpos;    }