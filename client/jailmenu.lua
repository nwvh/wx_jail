-- I won't translate this lol

ESX = exports["es_extended"]:getSharedObject()
lib.registerContext({
    id = 'jailmenu',
    title = "Prison",
    options = {
        {
            title = "Imprison",
            disabled = wx.ManualJail,
            icon = "handcuffs",
            onSelect = function ()
                local jail = lib.inputDialog('Jail', {
                    {type = 'number', label = 'Player ID', disabled = false, placeholder = "123", icon = 'list-ol',},
                    {type = 'number', label = 'Time', description = 'Time in minutes (1 minute = '..wx.MinuteToYears..' years)', icon = 'clock', placeholder = "10"},
                    {type = 'input', label = 'Reason', description = 'Reason for imprisoning the player', icon = 'font', placeholder = "Driving without a license"},
                })
                if jail then
                    if jail[2] <= wx.MaxTime then
                        ESX.TriggerServerCallback('wx_jail:checkJailUser', function(jailed)
                            for k, v in pairs(jailed) do
                                local serverId = GetPlayerServerIdFromIdentifier(v.identifier)
                                if serverId == jail[1] then
                                    lib.notify({
                                        title = Locale["Error"],
                                        description = ('L\'utente è già in carcere!'),
                                        type = 'error',
                                        position = 'top'
                                    })
                                    break
                                else
                                    TriggerServerEvent('wx_jail:sendToJail', jail[1], jail[2], jail[3])
                                    lib.notify({
                                        title = "Success",
                                        description = 'Player has been imprisoned for ' ..
                                            jail[2] .. ' minutes due to ' .. jail[3],
                                        type = 'info',
                                        position = 'top'
                                    })
                                end
                            end
                        end)
                    else
                        lib.notify({
                            title = "Error",
                            description = ('The maximum time for imprisonment is %s minutes!'):format(wx.MaxTime),
                            type = 'error',
                            position = 'top'
                        })
                    end
                else
                    lib.notify({
                        title = 'Action Cancelled',
                        type = 'info',
                        position = 'top'
                    })
                end
            end
        },
        {
            title = "Release from Prison",
            icon = 'user-large-slash',
            onSelect = function ()
                local jailedPly = {
                    {
                        title = "Back",
                        icon = 'angle-left',
                        menu = 'jailmenu',
                        arrow = false
                    }
                }
                ESX.TriggerServerCallback("wx_jail:retrieveJailedPlayers", function(jailed)
                    if json.encode(jailed) == '[]' then
                        table.insert(jailedPly,{
                            title = "No one is in prison",
                            icon = 'exclamation-triangle'
                        })
                    end
                    for k,v in pairs(jailed) do
                        table.insert(jailedPly,{
                            title = v.name,
                            metadata = {
                                {label = 'Remaining Time', value = v.jailTime*wx.MinuteToYears..' minutes'},
                                {label = 'Identifier', value = v.identifier},
                            },
                            onSelect = function ()
                                local alert = lib.alertDialog({
                                    header = 'Release prisoner **'..v.name..'**',
                                    content = 'Are you sure you want to release the selected prisoner?',
                                    centered = true,
                                    cancel = true,
                                    labels = {
                                        cancel = "Do Not Release",
                                        confirm = "Yes, Release"
                                    }
                                })
                                if alert == 'confirm' then
                                    TriggerServerEvent("wx_jail:unJailPlayer", v.identifier)
                                    lib.notify({
                                        title = 'Prisoner '..v.name..' has been released!',
                                        type = 'success',
                                        position = 'top'
                                    })
                                else
                                    lib.notify({
                                        title = 'Action Cancelled',
                                        type = 'info',
                                        position = 'top'
                                    })
                                end
                            end
                        })
                    end
                    lib.registerContext({
                        id='jailedPlayers',
                        title = "List of Prisoners",
                        options=jailedPly
                    })
                    lib.showContext('jailedPlayers')
                end)
            end
            -- menu = 'jailedPlayers'
        },
        {
            title = "Change Time",
            icon = "clock",
            onSelect = function ()
                local editJailTime = {
                    {
                        title = "Back",
                        icon = 'angle-left',
                        menu = 'jailmenu',
                        arrow = false
                    }
                }
                ESX.TriggerServerCallback("wx_jail:retrieveJailedPlayers", function(jailed)
                    if json.encode(jailed) == '[]' then
                        table.insert(editJailTime,{
                            title = "No one is in prison",
                            icon = 'exclamation-triangle'
                        })
                    end
                    for k,v in pairs(jailed) do
                        table.insert(editJailTime,{
                            title = v.name,
                            metadata = {
                                {label = 'Remaining Time', value = v.jailTime*wx.MinuteToYears..' minutes'},
                                {label = 'Identifier', value = v.identifier},
                            },
                            onSelect = function ()
                                local jailtime = lib.inputDialog('Change Imprisonment Time', {
                                    {type = 'number', label = 'New Time', description = 'Time in minutes, how long the player should stay in prison', icon = 'clock', placeholder = "10"},
                                })
                                if jailtime then
                                    TriggerServerEvent("wx_jail:newTime", v.identifier,jailtime[1])
                                    lib.notify({
                                        title = "Success",
                                        description = ('Prisoner %s is now in prison for %s'):format(v.name,jailtime[1]),
                                        type = 'success',
                                        position = 'top'
                                    })
                                else
                                    lib.notify({
                                        title = "Cancelled",
                                        type = 'info',
                                        position = 'top'
                                    })
                                end
                            end
                        })
                    end
                    lib.registerContext({
                        id='editJailTime',
                        title = "List of Prisoners",
                        options=editJailTime
                    })
                    lib.showContext('editJailTime')
            end)
        end
        },

    }
})

function GetPlayerServerIdFromIdentifier(identifier)
    local playerServerId = nil

    for _, player in ipairs(GetActivePlayers()) do
        local playerId = GetPlayerServerId(player)

        if playerId and playerId > 0 then
            local playerIdentifier = ESX.GetPlayerData(player).identifier

            -- here we slip the identifiers so they are individual
            local identifiers = splitIdentifiers(identifier)

            -- here we check each identifier coz why not
            for _, id in ipairs(identifiers) do
                if playerIdentifier == id then
                    playerServerId = playerId
                    break
                end
            end
            --lol not working, quick fix made at line 240 no worries 👍
            if playerServerId then
                break
            end
        end
    end

    return playerServerId
end

function splitIdentifiers(identifierrec)
    local identifiers = {}
    for identifier in string.gmatch(identifierrec, "[^,]+") do
        table.insert(identifiers, identifier)
    end
    return identifiers
end

RegisterCommand(wx.Command,function ()
	if not wx.Jobs[PlayerData["job"].name] then return end
    lib.showContext('jailmenu')
end,false)

RegisterCommand('adminjail',function ()
    lib.registerContext({
        id = 'adminjail',
        title = 'Admin Jail',
        options = {
            {
                title = "Send to jail",
                icon = 'handcuffs',
                onSelect = function ()
                    local jail = lib.inputDialog('ADMIN JAIL', {
                        {type = 'number', label = 'Player ID', description = "ID of the player you want to jail", icon = 'list-ol',},
                            {type = 'number', label = 'Time', description = 'Time in minutes', icon = 'clock', placeholder = "10"},
                            {type = 'input', label = 'Reason', description = 'Jail reason', icon = 'font', placeholder = "Jízda bez ŘP"},
                        {type = 'checkbox', label = 'Send to logs (Recommended)', checked=true},
                    })
                    if jail then
                        if jail[2] <= wx.MaxTime then
                            ESX.TriggerServerCallback('wx_jail:checkJailUser', function(jailed)
                                for k, v in pairs(jailed) do
                                    local serverId = GetPlayerServerIdFromIdentifier(v.identifier)
                                    if serverId == jail[1] then
                                        lib.notify({
                                            title = Locale["Error"],
                                            description = ('L\'utente è già in carcere!'),
                                            type = 'error',
                                            position = 'top'
                                        })
                                        break
                                    else
                                        TriggerServerEvent('wx_jail:adminJail', jail[1], jail[2], jail[3], jail[4])
                                        lib.notify({
                                            title = Locale["Success"],
                                            description = 'Il giocatore è stato incarcerato per ' ..
                                                jail[2] .. ' minuti. Motivo: ' .. jail
                                                [3],
                                            type = 'info',
                                            position = 'top'
                                        })
                                    end
                                end
                            end)
                        else
                            lib.notify({
                                title = Locale["Error"],
                                description = ('Maximum jail time is %s minutes!'):format(wx.MaxTime),
                                type = 'error',
                                position = 'top'
                            })
                        end
                    else
                        lib.notify({
                            title = Locale["Cancelled"],
                            type = 'info',
                            position = 'top'
                        })
                    end
                end
            },
            {
                title = "Remove from jail",
                icon = 'handcuffs',
                onSelect = function ()
                    local unjail = lib.inputDialog('Remove player from jail', {
                        {type = 'number', label = 'ID Hráče', description = "Player ID", icon = 'list-ol',},
                        {type = 'checkbox', label = 'Send to logs (Recommended)', checked=true},
                    })
                    if unjail then
                        TriggerServerEvent('wx_jail:adminUnjail',unjail[1],unjail[2])
                    else
                        lib.notify({
                            title = Locale["Cancelled"],
                            type = 'info',
                            position = 'top'
                        })
                    end
                end
            },
            {
                title = "Prisoner List",
                icon = 'users',
                onSelect = function ()
                    local jailedPly = {
                        {
                            title = "Back",
                            icon = 'angle-left',
                            menu = 'adminjail',
                            arrow = false
                        }
                    }
                    ESX.TriggerServerCallback("wx_jail:retrieveJailedPlayers", function(jailed)
                        if json.encode(jailed) == '[]' then
                            table.insert(jailedPly,{
                                title = "No one's in jail",
                                icon = 'exclamation-triangle'
                            })
                        end
                        for k,v in pairs(jailed) do
                            table.insert(jailedPly,{
                                title = v.name,
                                metadata = {
                                    {label = 'Remaining time', value = v.jailTime*wx.MinuteToYears..' minutes'},
                                    {label = 'Identifier', value = v.identifier},
                                },
                            })
                        end
                        lib.registerContext({
                            id='jailedPlayers',
                            title = "Prisoner list",
                            options=jailedPly
                        })
                        lib.showContext('jailedPlayers')
                    end)
                end
                -- menu = 'jailedPlayers'
            },
            {
                title = "Change time",
                icon = "clock",
                onSelect = function ()
                    local editJailTime = {
                        {
                            title = "Back",
                            icon = 'angle-left',
                            menu = 'adminjail',
                            arrow = false
                        }
                    }
                    ESX.TriggerServerCallback("wx_jail:retrieveJailedPlayers", function(jailed)
                        if json.encode(jailed) == '[]' then
                            table.insert(editJailTime,{
                                title = "No one's in jail",
                                icon = 'exclamation-triangle'
                            })
                        end
                        for k,v in pairs(jailed) do
                            table.insert(editJailTime,{
                                title = v.name,
                                metadata = {
                                    {label = 'Remaining time', value = v.jailTime*wx.MinuteToYears..' minutes'},
                                    {label = 'Identifier', value = v.identifier},
                                },
                                onSelect = function ()
                                    local jailtime = lib.inputDialog('Edit jail time', {
                                        {type = 'number', label = 'New Time', description = 'New jail time', icon = 'clock', placeholder = "10"},
                                    })
                                    if jailtime then
                                        TriggerServerEvent("wx_jail:newTime", v.identifier,jailtime[1])
                                        lib.notify({
                                            title = Locale["Success"],
                                            description = ('Prisoner %s will now be in jail for %s'):format(v.name,jailtime[1]),
                                            type = 'success',
                                            position = 'top'
                                        })
                                    else
                                        lib.notify({
                                            title = Locale["Cancelled"],
                                            type = 'info',
                                            position = 'top'
                                        })
                                    end
                                end
                            })
                        end
                        lib.registerContext({
                            id='editJailTime',
                            title = "Prisoner List",
                            options=editJailTime
                        })
                        lib.showContext('editJailTime')
                end)
            end
            },
        }
    })
    local group = lib.callback.await('wx_jail:getGroup')
    if wx.Groups[group] then
        lib.showContext('adminjail')
    else
        lib.notify({
            title = Locale["Error"],
            description = 'No permissions!',
            type = 'error',
            position = 'top'
        })
    end
end,false)
