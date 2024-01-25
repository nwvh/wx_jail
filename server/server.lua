ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("wx_jail:sendToJail")
AddEventHandler("wx_jail:sendToJail", function(targetSrc, jailTime, jailReason)
	if targetSrc == -1 then
		wx.BAN(source,"Jail Exploit - [Jail Everyone]")
		return
	end
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(targetSrc)
	if targetSrc == source and not wx.Debug then
		TriggerClientEvent('ox_lib:notify', src, {
			title = 'Věznice',
			description = ("You cannot jail yourself!"),
			type='error',
			position = 'top'
		})
		return
	end
	
	if wx.Jobs[xPlayer.job.name] then
		exports.ox_inventory:ConfiscateInventory(targetSrc)
		TriggerClientEvent("wx_jail:jailPlayer", targetSrc, jailTime)

		TriggerClientEvent('ox_lib:notify', targetSrc, {
			title = 'Věznice',
			description = ("You have been jailed for %s year(s), reason: %s"):format(jailTime,jailReason),
			type='error',
			position = 'top'
		})
		if wx.ChatMessages then
			TriggerClientEvent('chat:addMessage', -1, {
				template = '<div style="padding: 0.4vw; margin: 0.4vw; background-color: rgba(30, 30, 46, 0.75); border-radius: 3px;"><font style="padding: 0.22vw; margin: 0.22vw; background-color: #4361ee; border-radius: 2px; font-size: 15px;"> <i class="fa-solid fa-handcuffs"></i> <b>BOLINGBROKE PRISON</b></font><font style="background-color:rgba(20, 20, 20, 0); font-size: 17px; margin-left: 0px; padding-bottom: 2.5px; padding-left: 3.5px; padding-top: 2.5px; padding-right: 3.5px;border-radius: 0px;"></font>   <font style=" font-weight: 800; font-size: 15px; margin-left: 5px; padding-bottom: 3px; border-radius: 0px;"><b></b></font><font style=" font-weight: 200; font-size: 14px; border-radius: 0px;"><strong>{0}</strong> has been jailed for <strong>{1}</strong> let.</font></div>',
				args = {xTarget.getName(),jailTime}
			})
		end
		local data = {
			color = 16737095,
			title = "Jail",
			fields = {
				{
					["name"]= "Player",
					["value"]= GetPlayerName(targetSrc),
					["inline"] = true
				},
				{
					["name"]= "Policeman",
					["value"]= GetPlayerName(source),
					["inline"] = true
				},
				{
					["name"]= "Jail Reason",
					["value"]= jailReason,
					["inline"] = true
				},
				{
					["name"]= "Jail Time",
					["value"]= jailTime..' minutes',
					["inline"] = true
				},
			},
		}

		local officerSteam = GetPlayerIdentifierByType(source, 'steam')
		local officerLicense = GetPlayerIdentifierByType(source, 'license')
		local officerDiscord = GetPlayerIdentifierByType(source, 'discord')
		local officerIP = GetPlayerIdentifierByType(source, 'ip')
		for k, v in pairs(GetPlayerIdentifiers(source)) do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
			  officerSteam = v
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
			  officerLicense = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			  officerDiscord = v
			elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			  officerIP = v
			end
		end

		local plySteam = GetPlayerIdentifierByType(targetSrc, 'steam')
		local plyLicense = GetPlayerIdentifierByType(targetSrc, 'license')
		local plyDiscord = GetPlayerIdentifierByType(targetSrc, 'discord')
		local plyIP = GetPlayerIdentifierByType(targetSrc, 'ip')
		for k, v in pairs(GetPlayerIdentifiers(targetSrc)) do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
			  plySteam = v
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
			  plyLicense = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			  plyDiscord = v
			elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			  plyIP = v
			end
		end

		local ids = {
			title = "Identifiers",
			color = 16737095,
			description = ("> Player (%s)\nSteam ID %s:\nLicense: %s\nDiscord: %s\nIP Address: %s\n\n> Officer (%s)\nSteam ID: %s\nLicense: %s\nDiscord: %s\nIP Address: %s"):format(GetPlayerName(targetSrc),plySteam,plyLicense,plyDiscord,plyIP,GetPlayerName(source), officerSteam,officerLicense,officerDiscord,officerIP)
		}
		exports['wx_logs']:SendLog("jail",data)
		exports['wx_logs']:SendLog("jail",ids)

	else
		wx.BAN(source,"Jail Exploit - [Missing job]")
	end
end)

RegisterServerEvent("wx_jail:adminJail")
AddEventHandler("wx_jail:adminJail", function(targetSrc, jailTime, jailReason,log)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not wx.Groups[xPlayer.getGroup()] then
		wx.BAN(source,"Jail Exploit - [Unauthorized admin jail]")
		return
	end
	if targetSrc == -1 then
		wx.BAN(source,"Jail Exploit - [Admin Jail Everyone]")
		return
	end
	
	if wx.Groups[xPlayer.getGroup()] then
		exports.ox_inventory:ConfiscateInventory(targetSrc)
		TriggerClientEvent("wx_jail:jailPlayer", targetSrc, jailTime)
		TriggerClientEvent('ox_lib:notify', source, {
			title = 'Admin Jail',
			description = ("You've jailed %s for %s with the reason: %s"):format(GetPlayerName(targetSrc),jailTime,jailReason),
			type='success',
			position = 'top'
		})
		TriggerClientEvent('ox_lib:notify', targetSrc, {
			title = 'Věznice',
			description = ("You have been jailed for %s year(s). Reason: %s"):format(jailTime,jailReason),
			type='error',
			position = 'top'
		})
		if log then
			-- SERVER SIDE
			local data = {
    			color = 16737095,
    			title = "Admin Jail",
    			fields = {
        			{
        			    ["name"]= "Target",
        			    ["value"]= GetPlayerName(targetSrc),
        			    ["inline"] = true
        			},
        			{
        			    ["name"]= "Admin",
        			    ["value"]= GetPlayerName(source),
        			    ["inline"] = true
        			},
        			{
        			    ["name"]= "Jail Reason",
        			    ["value"]= jailReason,
        			    ["inline"] = true
        			},
        			{
        			    ["name"]= "Jail Time",
        			    ["value"]= jailTime..' minutes',
        			    ["inline"] = true
        			},
				},
			}
			local officerSteam = "Not Found"
			local officerLicense = "Not Found"
			local officerDiscord = "Not Found"
			local officerIP = "Not Found"
			for k, v in pairs(GetPlayerIdentifiers(source)) do
				if string.sub(v, 1, string.len("steam:")) == "steam:" then
				  officerSteam = v
				elseif string.sub(v, 1, string.len("license:")) == "license:" then
				  officerLicense = v
				elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				  officerDiscord = v
				elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				  officerIP = v
				end
			end
	
			local plySteam = "Not Found"
			local plyLicense = "Not Found"
			local plyDiscord = "Not Found"
			local plyIP = "Not Found"
			for k, v in pairs(GetPlayerIdentifiers(targetSrc)) do
				if string.sub(v, 1, string.len("steam:")) == "steam:" then
				  plySteam = v
				elseif string.sub(v, 1, string.len("license:")) == "license:" then
				  plyLicense = v
				elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				  plyDiscord = v
				elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				  plyIP = v
				end
			end
	
			local ids = {
				title = "Identifiers",
				color = 16737095,
				description = ("> Player (%s)\nSteam ID %s:\nLicense: %s\nDiscord: %s\nIP Address: %s\n\n> Admin (%s)\nSteam ID: %s\nLicense: %s\nDiscord: %s\nIP Address: %s"):format(GetPlayerName(targetSrc),plySteam,plyLicense,plyDiscord,plyIP,GetPlayerName(source), officerSteam,officerLicense,officerDiscord,officerIP)
			}
			exports['wx_logs']:SendLog("adminjail",data)
			exports['wx_logs']:SendLog("adminjail",ids)
		end
	end
end)

RegisterServerEvent("wx_jail:unJailPlayer")
AddEventHandler("wx_jail:unJailPlayer", function(id)
	local src = source
	local xPlayer = ESX.GetPlayerFromIdentifier(id)
	local cop = ESX.GetPlayerFromId(source)

	if wx.Jobs[cop.job.name] then
		exports.ox_inventory:ReturnInventory(id)
		TriggerClientEvent("wx_jail:unJailPlayer", xPlayer.source)
		local Identifier = xPlayer.identifier
		MySQL.Async.execute(
		   "UPDATE users SET jail = @newJailTime WHERE identifier = @identifier",
			{
				['@identifier'] = Identifier,
				['@newJailTime'] = 0
			}
		)
	else
		wx.BAN(source,"Jail Exploit - [Missing job for unjail]")
	end
end)

RegisterServerEvent("wx_jail:adminUnjail")
AddEventHandler("wx_jail:adminUnjail", function(id,log)
	local xPlayer = ESX.GetPlayerFromId(id)
	local admin = ESX.GetPlayerFromId(source)
	if wx.Groups[admin.getGroup()] then
		exports.ox_inventory:ReturnInventory(id)
		TriggerClientEvent("wx_jail:unJailPlayer", id)
		local Identifier = xPlayer.identifier
		MySQL.Async.execute(
		   "UPDATE users SET jail = @newJailTime WHERE identifier = @identifier",
			{
				['@identifier'] = Identifier,
				['@newJailTime'] = 0
			}
		)
		if log then
			-- SERVER SIDE
			local data = {
    			color = 16737095,
    			title = "Admin UnJail",
    			fields = {
        			{
        			    ["name"]= "Player",
        			    ["value"]= GetPlayerName(id),
        			    ["inline"] = true
        			},
        			{
        			    ["name"]= "Admin",
        			    ["value"]= GetPlayerName(source),
        			    ["inline"] = true
        			},
				},
			}
			local officerSteam = "Not Found"
			local officerLicense = "Not Found"
			local officerDiscord = "Not Found"
			local officerIP = "Not Found"
			for k, v in pairs(GetPlayerIdentifiers(source)) do
				if string.sub(v, 1, string.len("steam:")) == "steam:" then
				  officerSteam = v
				elseif string.sub(v, 1, string.len("license:")) == "license:" then
				  officerLicense = v
				elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				  officerDiscord = v
				elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				  officerIP = v
				end
			end
	
			local plySteam = "Not Found"
			local plyLicense = "Not Found"
			local plyDiscord = "Not Found"
			local plyIP = "Not Found"
			for k, v in pairs(GetPlayerIdentifiers(id)) do
				if string.sub(v, 1, string.len("steam:")) == "steam:" then
				  plySteam = v
				elseif string.sub(v, 1, string.len("license:")) == "license:" then
				  plyLicense = v
				elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				  plyDiscord = v
				elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				  plyIP = v
				end
			end
	
			local ids = {
				title = "Identifiery",
				color = 16737095,
				description = ("> Player (%s)\nSteam ID %s:\nLicense: %s\nDiscord: %s\nIP Address: %s\n\n> Admin (%s)\nSteam ID: %s\nLicense: %s\nDiscord: %s\nIP Address: %s"):format(GetPlayerName(id),plySteam,plyLicense,plyDiscord,plyIP,GetPlayerName(source), officerSteam,officerLicense,officerDiscord,officerIP)
			}
			exports['wx_logs']:SendLog("adminunjail",data)
			exports['wx_logs']:SendLog("adminunjail",ids)
		end
	else
		wx.BAN(source,"Jail Exploit - [Unauthorized admin unjail]")
	end
end)

RegisterServerEvent("wx_jail:updateJailTime")
AddEventHandler("wx_jail:updateJailTime", function(newJailTime)
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier

	MySQL.Async.execute(
       "UPDATE users SET jail = @newJailTime WHERE identifier = @identifier",
        {
			['@identifier'] = Identifier,
			['@newJailTime'] = tonumber(newJailTime)
		}
	)
end)

RegisterServerEvent("wx_jail:newTime")
AddEventHandler("wx_jail:newTime", function(id,time)
	MySQL.Async.execute(
		"UPDATE users SET jail = @newJailTime WHERE identifier = @identifier",
		 {
			 ['@identifier'] = id,
			 ['@newJailTime'] = time
		 }
	 )
end)

function GetRealPlayerName(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		if true then
			if false then
				return xPlayer.get('firstName')
			else
				return xPlayer.getName()
			end
		else
			return xPlayer.getName()
		end
	else
		return GetPlayerName(playerId)
	end
end

function GetRPName(playerId, data)
	local Identifier = ESX.GetPlayerFromId(playerId).identifier

	MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		data(result[1].firstname, result[1].lastname)

	end)
end

ESX.RegisterServerCallback("wx_jail:checkJailUser", function(source, cb)
	local jailedPersons = {}

	MySQL.Async.fetchAll("SELECT firstname, lastname, jail, identifier FROM users WHERE jail > @jail", { ["@jail"] = 0 },
		function(result)
			for i = 1, #result, 1 do
				table.insert(jailedPersons,
					{
						identifier = result[i].identifier
					})
			end
			cb(jailedPersons)
		end)
end)

ESX.RegisterServerCallback("wx_jail:retrieveJailedPlayers", function(source, cb)
	
	local jailedPersons = {}

	MySQL.Async.fetchAll("SELECT firstname, lastname, jail, identifier FROM users WHERE jail > @jail", { ["@jail"] = 0 }, function(result)

		for i = 1, #result, 1 do
			table.insert(jailedPersons, { name = result[i].firstname .. " " .. result[i].lastname, jailTime = result[i].jail, identifier = result[i].identifier })
		end

		cb(jailedPersons)
	end)
end)

ESX.RegisterServerCallback("wx_jail:retrieveJailTime", function(source, cb)

	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier


	MySQL.Async.fetchAll("SELECT jail FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		local JailTime = tonumber(result[1].jail)

		if JailTime > 0 then

			cb(true, JailTime)
		else
			cb(false, 0)
		end

	end)
end)


RegisterNetEvent('wx_jail:ban')
AddEventHandler('wx_jail:ban',function ()
	wx.BAN(source,"Jail Exploit - [Reached outside of the prison]")
end)
