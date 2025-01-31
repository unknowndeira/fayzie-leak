
local degHealth = {
    ["breaks"] = 0,-- has neg effect
    ["axle"] = 0,	-- has neg effect
    ["radiator"] = 0, -- has neg effect
    ["clutch"] = 0,	-- has neg effect
    ["transmission"] = 0, -- has neg effect
    ["electronics"] = 0, -- has neg effect
    ["fuel_injector"] = 0, -- has neg effect
    ["fuel_tank"] = 0 
}

local request = false
local garagesinuse = {}
local garage = {
    {Name = "Tow Garage 1", plate = 0, offsetx = 0, offsety = 0, offsetz = 0, CurrentHead = 0, x = 532.281, y = -176.548 , z = 53.505, xe = 532.281, ye = -176.548, ze = 53.505, he = 0.0, xd = 532.281 , yd = -176.548, zd = 53.505},
  {Name = "Tow Garage 2", plate = 0, offsetx = 0, offsety = 0, offsetz = 0, CurrentHead = 0, x = -1418.23, y = -446.42, z = 35.90, xe = -1418.23 ,ye = -446.42 , ze = 35.90, he = 0.0, xd = -1418.23 , yd = -446.42 , zd = 35.90}, -- Hayes
  {Name = "Tow Garage 3", plate = 0, offsetx = 0, offsety = 0, offsetz = 0, CurrentHead = 0, x = 1183.18, y = 2651.66, z = 37.81, xe = 1183.18 ,ye = 2651.66 , ze = 37.81, he = 0.0, xd =1183.18 , yd =  2651.66 , zd = 37.81}, 
  {Name = "Tow Garage 4", plate = 0, offsetx = 0, offsety = 0, offsetz = 0, CurrentHead = 0, x = 937.1, y = -963.01, z = 39.51, xe = 937.1, ye = -963.01, ze = 39.51, he = 0.0, xd = 937.1, yd = -963.01, zd = 39.51}, -- Tuner Shop
  {Name = "Tow Garage 5", plate = 0, offsetx = 0, offsety = 0, offsetz = 0, CurrentHead = 0, x = 2524.602, y = 4116.516, z = 38.584, xe = 2524.602, ye = 4116.516, ze = 38.584, he = 0.0, xd = 2524.602, yd = 4116.516, zd = 38.584}, -- Lost Garage
}




RegisterCommand('tow', function(source, args)
    local src = source
  local user = exports["fa-base"]:getModule("Player"):GetUser(src)

      TriggerClientEvent('pv:tow', src)

end)

RegisterServerEvent('towgarage:flatbed')
AddEventHandler('towgarage:flatbed', function(model)
	local src = source
	local user = exports["fa-base"]:getModule("Player"):GetUser(src)

	if not user then return end
	local job = user:getVar("job")

	if job == "towtruck" then
		TriggerClientEvent('towgarage:flatbed', src,model)
		TriggerClientEvent('towgarage:worked', src)
	else
		TriggerClientEvent('towgarage:notworked', src)
	end
end)

RegisterServerEvent('garage:Update')
AddEventHandler('garage:Update', function()
	local src = source
	TriggerClientEvent('towgarage:ClientUpdate',src,garage)
end)

RegisterServerEvent('towtruck:pay')
AddEventHandler('towtruck:pay', function()
	local src = source
	local user = exports["fa-base"]:getModule("Player"):GetUser(src)
	if accepted.src ~= nil then
		if accepted.src < os.time() then
			if not user then return end
			if not tonumber(amount) then return end
			user:addMoney(tonumber(amount))
			accepted.src = os.time() + 150
		end
	else
		if not user then return end
		if not tonumber(amount) then
		    user:addMoney(tonumber(amount))
            accepted.src = os.time() + 150
        end
	end
end) 


RegisterServerEvent('judge:pay')
AddEventHandler('judge:pay', function()
	local src = source
	local user = exports["fa-base"]:getModule("Player"):GetUser(src)
	if not user then return end
	if not tonumber(amount) then return end
	TriggerEvent('bank:judgePay',src,tonumber(amount))
	TriggerClientEvent("DoLongHudText",src,"You got paid by a judge, the sum of $" ..amount)
end)

RegisterServerEvent('towtruck:pay2')
AddEventHandler('towtruck:pay2', function()
	local src = source
	local user = exports["fa-base"]:getModule("Player"):GetUser(src)
	if accepted.src ~= nil then
		if accepted.src < os.time() then
			if not user then return end
			if not tonumber(amount) then return end
			user:addMoney(tonumber(amount))
			accepted.src = os.time() + 300
		end
	else
		if not user then return end
		if not tonumber(amount) then
		user:addMoney(tonumber(amount))
        accepted.src = os.time() + 300
        end
	end
end) 

RegisterServerEvent('towtruck:dropEnd')
AddEventHandler('towtruck:dropEnd', function()
	request = false
	
	exports.oxmysql:execute("SELECT value FROM general_variables WHERE name=@garage", function(result)
		if result then 
			amount[1] = result[1].value + amount[1]
			if shopID == 1 then
				exports.oxmysql:execute("UPDATE general_variables SET value=@value")
			end
		end
	end)
end)

RegisterServerEvent('towgarage:checkJobBounce')
AddEventHandler('towgarage:checkJobBounce', function(button)
    local src = source
    local user = exports["fa-base"]:getModule("Player"):GetUser(src)

    if not user then TriggerClientEvent("towgarage:notworked", src) return end
    local job = user:getVar("job")

    if job == "towtruck" then
        TriggerClientEvent('towgarage:checkDegMenu',src,true,button)
	else
		
    	if button == false then
    	            TriggerClientEvent('towgarage:checkDegMenu',src,false,button)
    	end
    end
end)

-- RegisterServerEvent("mech:remove:materials")
-- AddEventHandler("mech:remove:materials", function(materials, amount, garage)
--     local src = source
--     local addMaterials = 0
--     exports.oxmysql:execute("SELECT * FROM mech_materials WHERE garage = @garage",{['@garage']  = garage}, function(result)
--         local set = ""
--         local values = {}
--         if materials == "Aluminum" or materials == "aluminum" then
--              addMaterials = result[1]['Aluminum'] - amount
--              set = "Aluminum = @Aluminum"
--              values = {['Aluminum'] = addMaterials}
--              exports.oxmysql:execute("UPDATE mech_materials SET Aluminum = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         elseif materials == "Rubber" or materials == "rubber" then
--             addMaterials = result[1]['Rubber'] - amount
--             set = "Rubber = @Rubber"
--             values = {['Rubber'] = addMaterials}
--             exports.oxmysql:execute("UPDATE mech_materials SET Rubber = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         elseif materials == "Scrap" or materials == "scrap" then
--             addMaterials = result[1]['Scrap'] - amount
--             set = "Scrap = @Scrap"
--             values = {['Scrap'] = addMaterials}
--             exports.oxmysql:execute("UPDATE mech_materials SET Scrap = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         elseif materials == "Plastic" or materials == "plastic" then
--             addMaterials = result[1]['Plastic'] - amount
--             set = "Plastic = @Plastic"
--             values = {['Plastic'] = addMaterials}
--             exports.oxmysql:execute("UPDATE mech_materials SET Plastic = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         elseif materials == "Copper" or materials == "copper" then
--             addMaterials = result[1]['Copper'] - amount
--             set = "Copper = @Copper"
--             values = {['Copper'] = addMaterials}
--             exports.oxmysql:execute("UPDATE mech_materials SET Copper = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         elseif materials == "Steel" or materials == "steel" then
--             addMaterials = result[1]['Steel'] - amount
--             set = "Steel = @Steel"
--             values = {['Steel'] = addMaterials}
--             exports.oxmysql:execute("UPDATE mech_materials SET Steel = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         elseif materials == "Glass" or materials == "glass" then
--             addMaterials = result[1]['Glass'] - amount
--             set = "Glass = @Glass"
--             values = {['Glass'] = addMaterials}
--             exports.oxmysql:execute("UPDATE mech_materials SET Glass = @material WHERE garage = @name", {['name'] = garage, ['material'] = addMaterials})
--         end

--         exports.oxmysql:execute("UPDATE mech_materials SET ".. set .." WHERE garage = @name", {['name'] = garage, values})
--         print('Adding materials', firstToUpper(materials),addMaterials, set)
--         AddMaterials(firstToUpper(materials),addMaterials,set,values)

--     --     local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
--     --     MySQL.Async.execute("UPDATE character_current SET "..set.." WHERE identifier = @identifier", values)
--     -- exports.oxmysql:execute("UPDATE mech_materials SET ()")


--     end)
    
-- end)

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end



RegisterNetEvent('scrap:towTake')
AddEventHandler('scrap:towTake', function(degname,itemname,plate, amount, removepart)
    local _src = source
    local amount = amount*10

    exports.oxmysql:execute('SELECT * FROM characters_cars WHERE license_plate = @license_plate', {['@license_plate'] = plate}, function (result) 
        local deg = result[1].degredation
        degMe = result[1].degredation
        local temp = deg:split(",")
        if(temp[1] ~= nil) then	
            for i,v in ipairs(temp) do
                if i == 1 then
                    degHealth.breaks = tonumber(v)
                    if degHealth.breaks == nil then
                        degHealth.breaks = 0
                    end
                elseif i == 2 then
                    degHealth.axle = tonumber(v)
                elseif i == 3 then
                    degHealth.radiator = tonumber(v)
                elseif i == 4 then
                    degHealth.clutch = tonumber(v)
                elseif i == 5 then
                    degHealth.transmission = tonumber(v)
                elseif i == 6 then
                    degHealth.electronics = tonumber(v)
                elseif i == 7 then
                    degHealth.fuel_injector = tonumber(v)
                elseif i == 8 then	
                    degHealth.fuel_tank = tonumber(v)
                end
            end
        end
        local updateDB = ""  
        if degname == "breaks" then 
        degHealth["breaks"] = degHealth["breaks"] + amount
        if degHealth["breaks"] > 100 then
            degHealth["breaks"] = 100
        end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "axle" then
            degHealth["axle"] = degHealth["axle"] + amount
            if degHealth["axle"] > 100 then
                degHealth["axle"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "radiator" then
            degHealth["radiator"] = degHealth["radiator"] + amount
            if degHealth["radiator"] > 100 then
                degHealth["radiator"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "clutch" then
            degHealth["clutch"] = degHealth["clutch"] + amount
            if degHealth["clutch"] > 100 then
                degHealth["clutch"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "transmission" then
            degHealth["transmission"] = degHealth["transmission"] + amount
            if degHealth["transmission"] > 100 then
                degHealth["transmission"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "electronics" then
            degHealth["electronics"] = degHealth["electronics"] + amount
            if degHealth["electronics"] > 100 then
                degHealth["electronics"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "fuel_injector" then
            degHealth["fuel_injector"] = degHealth["fuel_injector"] + amount
            if degHealth["fuel_injector"] > 100 then
                degHealth["fuel_injector"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        elseif degname == "fuel_tank" then
            degHealth["fuel_tank"] = degHealth["fuel_tank"] + amount
            if degHealth["fuel_tank"] > 100 then
                degHealth["fuel_tank"] = 100
            end
        updateDB = degHealth["breaks"]..","..degHealth["axle"]..","..degHealth["radiator"]..","..degHealth["clutch"]..","..degHealth["transmission"]..","..degHealth["electronics"]..","..degHealth["fuel_injector"]..","..degHealth["fuel_tank"]
        end 
        TriggerClientEvent('mech:tools:cl', _src, itemname, removepart, updateDB, plate)
        TriggerClientEvent('veh:requestUpdate', _src)

        exports.oxmysql:execute("UPDATE characters_cars SET degredation = @degredation WHERE license_plate = @plate", {
            ['@degredation'] = updateDB,
            ['plate'] = plate
        })
    end)
end)

RegisterServerEvent('requestmechanicmaterials')
AddEventHandler('requestmechanicmaterials', function(garage)
    local src = source

    exports.oxmysql:execute("SELECT * FROM mech_materials WHERE garage = @name",{['name'] = garage}, function(result)
        if(result[1]) then
            print('returning materials')
            print(json.encode(result[1]))
            local strng = "\n Aluminum - " .. result[1]["Aluminium"] .. " \n Rubber - " .. result[1]["Rubber"] .. " \n Scrap - " .. result[1]["Scrap"] .. " \n Plastic - " .. result[1]["Plastic"] .. " \n Copper - " .. result[1]["Copper"] .. " \n Steel - " .. result[1]["Steel"] .. " \n Glass - " .. result[1]["Glass"]
            TriggerClientEvent('returnmechanicmaterials', src, strng)
        end
    end)
end)

RegisterServerEvent('scrap:processPayment')
AddEventHandler('scrap:processPayment', function(amount, garage, material)
-- adding material to garage's sql table ill make it ((sway))
    local src = source
    local koil
    if material == 26 then koil = "Scrap" 
        elseif material == 27 then koil = "Plastic"
        elseif material == 28 then koil = "Glass"
        elseif material == 30 then koil = "Steel"
        elseif material == 31 then koil = "Aluminium"
        elseif material == 33 then koil = "Rubber"
        elseif material == 34 then koil =  "Copper"
    end
    exports.oxmysql:execute("UPDATE mech_materials SET " .. koil .. "= " .. koil .. " + @count WHERE garage = @name", {['name'] = garage, ['count'] = amount})
    TriggerClientEvent('DoLongHudText', src, "Updated Material: " .. koil, 2)
end)

RegisterServerEvent("Towgarage:InUse")
AddEventHandler("Towgarage:InUse", function(using,num)
    local src = source

    table.insert(garagesinuse, { ['Garage'] = num, ['inuse'] = using})
end)

RegisterCommand("repair", function(source, args, rawCommand)
    if args[1] ~= nil and args[2] ~= nil then
        if type(args[1]) == 'string' and type(tonumber(args[2])) then
            if tonumber(args[2]) <= 10 and tonumber(args[2]) > 0 then
                --print(args[1], args[2])
                TriggerClientEvent("towgarage:TriggerRepairs", source, args[1], args[2])
            end
        end
    else

    end
end, false)