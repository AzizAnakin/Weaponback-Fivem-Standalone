-- cl_weapons-on-back.lua (configurable via NativeUILua)

local SETTINGS_BY_GROUP = {
    ASSAULT = {
        bone   = 24816,
        offset = vec3(0.075, -0.15, -0.02),
        rot    = vec3(0.0, 165.0, 0.0),
    },
    SHOTGUN = {
        bone   = 24816,
        offset = vec3(0.075, -0.15, -0.02),
        rot    = vec3(0.0, 165.0, 0.0),
    },
    LAUNCHER = {
        bone   = 24816,
        offset = vec3(0.0, -0.18, 0.05),
        rot    = vec3(0.0, 200.0, 0.0),
    }
}

local config = {
    enabled = true,
    excludedGroups = {},
    excludedWeapons = {},
}

local menuPool = NativeUI.CreatePool()
local menu = nil

local function saveConfig() end
local function loadConfig() end

local VALID_GROUPS = {
    [GetWeapontypeGroup(GetHashKey("WEAPON_CARBINERIFLE"))]     = "ASSAULT",
    [GetWeapontypeGroup(GetHashKey("WEAPON_SMG"))]              = "ASSAULT",
    [GetWeapontypeGroup(GetHashKey("WEAPON_MG"))]               = "ASSAULT",
    [GetWeapontypeGroup(GetHashKey("WEAPON_SNIPERRIFLE"))]      = "ASSAULT",
    [GetWeapontypeGroup(GetHashKey("WEAPON_PUMPSHOTGUN"))]      = "SHOTGUN",
    [GetWeapontypeGroup(GetHashKey("WEAPON_GRENADELAUNCHER"))]  = "LAUNCHER",
    [GetWeapontypeGroup(GetHashKey("WEAPON_RPG"))]              = "LAUNCHER",
    [GetWeapontypeGroup(GetHashKey("WEAPON_FIREWORK"))]         = "LAUNCHER",
    [GetWeapontypeGroup(GetHashKey("WEAPON_RAILGUN"))]          = "LAUNCHER",
}

local function getGroupType(hash)
    local group = GetWeapontypeGroup(hash)
    if group == GetWeapontypeGroup(GetHashKey("WEAPON_PUMPSHOTGUN")) then
        return "SHOTGUN"
    elseif group == GetWeapontypeGroup(GetHashKey("WEAPON_GRENADELAUNCHER")) or
           group == GetWeapontypeGroup(GetHashKey("WEAPON_RPG")) or
           group == GetWeapontypeGroup(GetHashKey("WEAPON_FIREWORK")) or
           group == GetWeapontypeGroup(GetHashKey("WEAPON_RAILGUN")) then
        return "LAUNCHER"
    else
        return "ASSAULT"
    end
end

local attached = {}
local knownWeapons = {}
local lastSelected = nil
local otherPlayersWeapons = {}
local attachedOther = {}

local function safeDeleteObject(obj)
    if obj and DoesEntityExist(obj) then
        DeleteObject(obj)
    end
end

local function attachWeapon(ped, hash)
    if attached[hash] then return end
    local groupType = getGroupType(hash)
    if config.excludedGroups[groupType] then return end
    if config.excludedWeapons[hash] then return end
    local configPose = SETTINGS_BY_GROUP[groupType]
    if not configPose then return end

    local obj = CreateWeaponObject(hash, 1, 0.0, 0.0, 0.0, true, 1.0, 0.0, 0.0, 0.0)
    local bone = GetPedBoneIndex(ped, configPose.bone)
    AttachEntityToEntity(obj, ped, bone,
        configPose.offset.x, configPose.offset.y, configPose.offset.z,
        configPose.rot.x, configPose.rot.y, configPose.rot.z,
        true, true, false, true, 1, true
    )
    attached[hash] = obj
end

local function detachWeapon(hash)
    if not attached[hash] then return end
    safeDeleteObject(attached[hash])
    attached[hash] = nil
end

local function attachWeaponOther(ped, playerId, hash)
    if not attachedOther[playerId] then attachedOther[playerId] = {} end
    if attachedOther[playerId][hash] and DoesEntityExist(attachedOther[playerId][hash]) then return end
    local groupType = getGroupType(hash)
    if config.excludedGroups[groupType] then return end
    if config.excludedWeapons[hash] then return end
    local configPose = SETTINGS_BY_GROUP[groupType]
    if not configPose then return end

    local obj = CreateWeaponObject(hash, 1, 0.0, 0.0, 0.0, true, 1.0, 0.0, 0.0, 0.0)
    local bone = GetPedBoneIndex(ped, configPose.bone)
    AttachEntityToEntity(obj, ped, bone,
        configPose.offset.x, configPose.offset.y, configPose.offset.z,
        configPose.rot.x, configPose.rot.y, configPose.rot.z,
        true, true, false, true, 1, true
    )
    attachedOther[playerId][hash] = obj
end

local function detachWeaponOther(playerId, hash)
    if attachedOther[playerId] and attachedOther[playerId][hash] then
        safeDeleteObject(attachedOther[playerId][hash])
        attachedOther[playerId][hash] = nil
    end
end

-- Boucle principale pour le joueur local
Citizen.CreateThread(function()
    local ped = PlayerPedId()
    lastSelected = GetSelectedPedWeapon(ped)
    while true do
        Wait(200)
        if not config.enabled then
            for hash in pairs(attached) do
                detachWeapon(hash)
            end
            Citizen.Wait(1000)
        else
            ped = PlayerPedId()
            local current = GetSelectedPedWeapon(ped)
            if not knownWeapons[current] and current ~= GetHashKey("WEAPON_UNARMED") then
                knownWeapons[current] = true
            end
            if current ~= lastSelected then
                detachWeapon(lastSelected)
                lastSelected = current
            end
            for hash in pairs(knownWeapons) do
                local hasWeapon = HasPedGotWeapon(ped, hash, false)
                if not hasWeapon then
                    detachWeapon(hash)
                    knownWeapons[hash] = nil
                elseif hash == current then
                    detachWeapon(hash)
                else
                    local group = GetWeapontypeGroup(hash)
                    if VALID_GROUPS[group] and not config.excludedGroups[getGroupType(hash)] and not config.excludedWeapons[hash] then
                        attachWeapon(ped, hash)
                    else
                        detachWeapon(hash)
                    end
                end
            end
        end
    end
end)

function updateWeaponsOnBack()
    local ped = PlayerPedId()
    local weapons = {}
    for hash in pairs(knownWeapons) do
        if HasPedGotWeapon(ped, hash, false) then
            table.insert(weapons, hash)
        end
    end
    local current = GetSelectedPedWeapon(ped)
    TriggerServerEvent("weaponsOnBack:update", weapons, current)
end

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        updateWeaponsOnBack()
    end
end)

RegisterNetEvent("weaponsOnBack:sync")
AddEventHandler("weaponsOnBack:sync", function(playerId, weapons)
    otherPlayersWeapons[playerId] = weapons
end)

Citizen.CreateThread(function()
    TriggerServerEvent("weaponsOnBack:requestSync")
    while true do
        Wait(500)
        for playerId, weapons in pairs(otherPlayersWeapons) do
            local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
            if ped ~= PlayerPedId() and ped ~= 0 then
                if attachedOther[playerId] then
                    for hash, obj in pairs(attachedOther[playerId]) do
                        local stillHas = false
                        for _, w in ipairs(weapons) do
                            if w == hash then stillHas = true break end
                        end
                        if not stillHas then
                            detachWeaponOther(playerId, hash)
                        end
                    end
                end
                for _, hash in ipairs(weapons) do
                    attachWeaponOther(ped, playerId, hash)
                end
            end
        end
    end
end)

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    if attachedOther[playerId] then
        for hash, obj in pairs(attachedOther[playerId]) do
            safeDeleteObject(obj)
        end
        attachedOther[playerId] = nil
    end
    otherPlayersWeapons[playerId] = nil
end)

-- Menu NativeUILua avec titres et descriptions en rouge, sans motif
local mainMenu, groupMenus, menuPool = nil, {}, nil

function getPlayerWeapons()
    local ped = PlayerPedId()
    local weapons = {}
    for hash in pairs(knownWeapons) do
        if HasPedGotWeapon(ped, hash, false) then
            table.insert(weapons, hash)
        end
    end
    return weapons
end

function CreateWeaponsBackMenu()
    if menuPool then menuPool:RefreshIndex() else menuPool = NativeUI.CreatePool() end
    if mainMenu then return end

    mainMenu = NativeUI.CreateMenu("~r~Armes sur le dos", "~r~Options du script", 0, 0)
    mainMenu:SetMenuWidthOffset(100)
    menuPool:Add(mainMenu)

    -- Activation globale
    local enabledItem = NativeUI.CreateCheckboxItem("Activer les armes dans dos", config.enabled, "~r~Active/désactive l'affichage des armes sur le dos.")
    mainMenu:AddItem(enabledItem)

    -- Sous-menu groupes d'armes
    local groupMenu = menuPool:AddSubMenu(mainMenu, "~r~Groupes d'armes", "~r~Afficher/masquer chaque groupe")
    local groupItems = {}
    for groupName, _ in pairs(SETTINGS_BY_GROUP) do
        local checked = not config.excludedGroups[groupName]
        local item = NativeUI.CreateCheckboxItem("Afficher " .. groupName, checked, "~r~Afficher les armes du groupe " .. groupName)
        groupMenu:AddItem(item)
        groupItems[item] = groupName
    end
    groupMenu.OnCheckboxChange = function(sender, item, checked_)
        for groupItem, groupName in pairs(groupItems) do
            if item == groupItem then
                config.excludedGroups[groupName] = not checked_
                saveConfig()
            end
        end
    end

    mainMenu.OnCheckboxChange = function(sender, item, checked_)
        if item == enabledItem then
            config.enabled = checked_
            saveConfig()
        end
    end

    local allMenus = {mainMenu, groupMenu}
    local function closeOtherMenus(openMenu)
        for _, menu in ipairs(allMenus) do
            if menu ~= openMenu and menu:Visible() then
                menu:Visible(false)
            end
        end
    end
    for _, menu in ipairs(allMenus) do
        menu.OnMenuOpen = function()
            closeOtherMenus(menu)
        end
    end
end

RegisterCommand("weaponback", function()
    if not mainMenu then CreateWeaponsBackMenu() end
    mainMenu:Visible(true)
end, false)

RegisterKeyMapping('weaponback', 'Menu armes sur le dos', 'keyboard', 'K')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if menuPool then menuPool:ProcessMenus() end
    end
end)
