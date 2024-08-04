-- client.lua

local ESX = nil
local farming = false
local farmingZone = {x = 200.0, y = -1000.0, z = 29.0, radius = 5.0}
local requiredKeys = {'w', 's', 'd'}
local keyPressInterval = 5000  -- 5 seconds interval to press a key
local farmingTime = 20000  -- Total time to farm in milliseconds (20 seconds)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(farmingZone.x, farmingZone.y, farmingZone.z))

        if distance < farmingZone.radius then
            ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to start farming')
            if IsControlJustReleased(0, 38) then -- E key
                startFarming()
            end
        end
    end
end)

function startFarming()
    farming = true
    ESX.ShowNotification('Farming started...')
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + farmingTime
        while farming and GetGameTimer() < endTime do
            Citizen.Wait(keyPressInterval)
            local randomKey = requiredKeys[math.random(#requiredKeys)]
            ESX.ShowHelpNotification('Press ' .. string.upper(randomKey) .. ' to continue farming')

            local keyPressed = false
            Citizen.CreateThread(function()
                while not keyPressed and GetGameTimer() < endTime do
                    Citizen.Wait(0)
                    if IsControlJustReleased(0, Keys[randomKey]) then
                        keyPressed = true
                        ESX.ShowNotification('You pressed the right key!')
                    end
                end
            end)

            Citizen.Wait(keyPressInterval)
            if not keyPressed then
                farming = false
                ESX.ShowNotification('You failed to farm. Try again!')
            end
        end

        if farming then
            farming = false
            TriggerServerEvent('farming:giveCoke_poorch')
            ESX.ShowNotification('You successfully farmed cocaine!')
        end
    end)
end

-- Key mappings for 'w', 's', 'd'
local Keys = {
    ['w'] = 32, -- W key
    ['s'] = 33, -- S key
    ['d'] = 34  -- D key
}
