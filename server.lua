local playerWeapons = {}

-- Vérifie si une table ne contient que des nombres
local function isArrayOfNumbers(tbl)
    if type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do
        if type(v) ~= "number" then return false end
    end
    return true
end

-- Mise à jour des armes sur le dos et synchro immédiate
RegisterNetEvent("weaponsOnBack:update", function(weapons, current)
    local src = source
    if not isArrayOfNumbers(weapons) or (current and type(current) ~= "number") then
        return
    end

    -- On retire l'arme en main de la liste pour l'affichage dos
    local filtered = {}
    for _, hash in ipairs(weapons) do
        if hash ~= current then
            table.insert(filtered, hash)
        end
    end

    -- Limite anti-abus : max 10 armes sur le dos
    if #filtered > 10 then
        return
    end

    playerWeapons[src] = {weapons = filtered, current = current}

    -- Diffuse à tous les autres joueurs (pas à soi-même)
    for _, id in ipairs(GetPlayers()) do
        id = tonumber(id)
        if id and id ~= src then
            TriggerClientEvent("weaponsOnBack:sync", id, src, filtered)
        end
    end
end)

-- Synchronisation complète pour un nouveau joueur
RegisterNetEvent("weaponsOnBack:requestSync", function()
    local src = source
    -- Envoie à ce joueur l'état de tous les autres
    for id, data in pairs(playerWeapons) do
        id = tonumber(id)
        if id and id ~= src and data and type(data.weapons) == "table" then
            TriggerClientEvent("weaponsOnBack:sync", src, id, data.weapons)
        end
    end
    -- Envoie à tous les autres l'état de ce joueur (si il a déjà des armes)
    local data = playerWeapons[src]
    if data and type(data.weapons) == "table" then
        for _, id in ipairs(GetPlayers()) do
            id = tonumber(id)
            if id and id ~= src then
                TriggerClientEvent("weaponsOnBack:sync", id, src, data.weapons)
            end
        end
    end
end)

-- Nettoyage lors de la déconnexion
AddEventHandler("playerDropped", function()
    local src = source
    playerWeapons[src] = nil
    -- Notifie tous les joueurs que ce joueur n'a plus d'arme sur le dos
    for _, id in ipairs(GetPlayers()) do
        id = tonumber(id)
        if id and id ~= src then
            TriggerClientEvent("weaponsOnBack:sync", id, src, {})
        end
    end
end)

-- Nettoyage périodique des joueurs déconnectés (sécurité mémoire)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for src, _ in pairs(playerWeapons) do
            if not GetPlayerName(tonumber(src)) then
                playerWeapons[src] = nil
            end
        end
    end
end)

-- Synchronisation périodique pour éviter les désyncs (toutes les 30s)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        for src, data in pairs(playerWeapons) do
            src = tonumber(src)
            if data and type(data.weapons) == "table" then
                for _, id in ipairs(GetPlayers()) do
                    id = tonumber(id)
                    if id and id ~= src then
                        TriggerClientEvent("weaponsOnBack:sync", id, src, data.weapons)
                    end
                end
            end
        end
    end
end)

-- Debug : commande serveur pour voir l'état (aucun print)
RegisterCommand("weaponsback_list", function(src, args, raw)
    -- Ne rien faire, aucun print demandé
end, true)