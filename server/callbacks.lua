ESX = exports["es_extended"]:getSharedObject()
lib.callback.register('wx_jail:getGroup', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer.getGroup()
end)

lib.callback.register('wx_jail:getCharName', function(id)
    local xx = ESX.GetPlayerFromId(id)
    local name =  xx.getName()
    return name
end)
lib.callback.register('wx_jail:getCharDOB', function(id)
    local xPlayer = ESX.GetPlayerFromId(id)
    return xPlayer.get('dateofbirth')
end)