ESX = exports["es_extended"]:getSharedObject()
PlayerData = {}
local jailTime = 0

-- ## Check player's job ## --
Citizen.CreateThread(function()
	while ESX.GetPlayerData() == nil do
		Citizen.Wait(150)
	end
	PlayerData = ESX.GetPlayerData()
end)

-- ## Check if player is in jail when he selects character ## --
-- ## Fix on correct jailtime display
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
	Citizen.Wait(15000)
	ESX.TriggerServerCallback("wx_jail:retrieveJailTime", function(inJail, time)
		if inJail then
			jailTime = time --Time display quickfix :D
			SetEntityCoords(PlayerPedId(), wx.Locations.JailEnter[math.random(#wx.Locations.JailEnter)])

			lib.notify({
				title = Locale["JailTitle"],
				description = Locale["Disconnected"],
				type = 'error',
				position = 'top'
			})
			TimeLeft()
		end
	end)
end)

RegisterNetEvent("wx_jail:jailPlayer")
AddEventHandler("wx_jail:jailPlayer", function(newJailTime)
	jailTime = newJailTime
	Cutscene()
end)

RegisterNetEvent("wx_jail:unJailPlayer")
AddEventHandler("wx_jail:unJailPlayer", function()
	jailTime = 0
	UnJail()
end)


local options = {
	{
		name = 'wx_jail:send',
		distance = 2,
		icon = 'fa-solid fa-handcuffs',
		label = Locale["SendToJail"],
		canInteract = function ()
			if wx.Jobs[PlayerData["job"].name] then return true end
			if IsPedDeadOrDying(PlayerPedId(),false) or IsPedFatallyInjured(PlayerPedId()) then return false end
			return false
		end,
		onSelect = function (data)
			local id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
			local jail = lib.inputDialog('Vězení', {
				{type = 'input', label = Locale["pID"], disabled = true, placeholder = id, icon = 'list-ol',},
				{type = 'number', label = Locale["pTime"], description = Locale["pTimeDesc"]:format(wx.MinuteToYears), icon = 'clock', placeholder = "10"},
				{type = 'input', label = Locale["pReason"], description = Locale["pReasonDesc"], icon = 'font', placeholder = "Jízda bez ŘP"},
			})
			if jail then
				if jail[2] <= 100 then
					TriggerServerEvent('wx_jail:sendToJail',id,jail[2],jail[3])
					lib.notify({
						title = Locale["Success"],
						description =  Locale["Jailed"]:format(jail[2],jail[3]),
						type = 'info',
						position = 'top'
					})
				else
					lib.notify({
						title = Locale["Error"],
						description = Locale["MaxTime"]:format(wx.MaxTime),
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
}

if wx.Target then
	exports.ox_target:addGlobalPlayer(options)
end
if wx.ManualJail then
	exports.ox_target:addSphereZone({
		coords = vec3(1840.4167, 2577.7600, 46.0144),
		radius = 1.0,
		options = {
			{
				label = Locale["JailTarget"],
				icon = "fa-solid fa-handcuffs",
				distance = 1.5,
				canInteract = function ()
					if wx.Jobs[PlayerData["job"].name] then return true end
					return false
				end,
				onSelect = function ()
					local pl = {}
					local nearby = lib.getNearbyPlayers(GetEntityCoords(PlayerPedId()), 25.0, true)
					if json.encode(nearby) == '[]' then
						table.insert(pl,{
							title = Locale["Nearby"],
							icon = 'triangle-exclamation'
						})
					else
						for k,v in pairs(nearby) do
							local name = lib.callback.await('wx_jail:getCharName',GetPlayerServerId(v.id))
							print(GetPlayerServerId(v.id))
							table.insert(pl,{
								title = ("[%s] %s"):format(GetPlayerServerId(v.id),GetPlayerName(v.id)),
								icon = 'user',
								onSelect = function ()
									local jail = lib.inputDialog(Locale["JailTitle"], {
										{type = 'input', label = Locale["pID"], disabled = true, placeholder = GetPlayerServerId(v.id), icon = 'list-ol',},
										{type = 'number', label = Locale["pTime"], description = Locale["pTimeDesc"]:format(wx.MinuteToYears), icon = 'clock', placeholder = "10"},
										{type = 'input', label = Locale["pReason"], description = Locale["pReasonDesc"], icon = 'font', placeholder = "Jízda bez ŘP"},
									})
									if jail then
										if jail[2] <= wx.MaxTime then
												local alert = lib.alertDialog({
													header = Locale["Confirmation"],
													content = Locale["ConfirmationDesc"]:format(name,jail[2]*wx.MinuteToYears..' roky',jail[3]),
													centered = true,
													cancel = true,
													labels = {
														confirm = Locale["Confirm"],
														cancel = Locale["Cancel"]
													}
												})
												if alert == 'confirm' then
													TriggerServerEvent('wx_jail:sendToJail',GetPlayerServerId(v.id),jail[2],jail[3])
													lib.notify({
														title = Locale["Success"],
														description = Locale["Jailed"]:format(jail[2],jail[3]),
														type = 'info',
														position = 'top'
													})
												end
											else
												lib.notify({
													title = Locale["Error"],
													description = Locale["MaxTime"]:format(wx.MaxTime),
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
							})
							lib.registerContext({
								id = 'nearby',
								title = Locale["Select"],
								options = pl
							})
						end
					end

					lib.showContext('nearby')
				end
			}
		}
	})
end



function UnJail()
	TimeLeft()

	ESX.Game.Teleport(PlayerPedId(), wx.Locations.JailExit)

	lib.notify({
		title = 'Věznice',
		description = Locale["JailDone"],
		type = 'success',
		position = 'top'
	})
end

function DrawTxt(x,y, width, height, scale, text, r, g, b, a, outline)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0,255)
	SetTextDropShadow()
	if outline then
        SetTextOutline()
    end
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width / 2, y - height / 2 + 0.005)
end

function CheckTeleport()
	if GetDistanceBetweenCoords(wx.Locations.JailCenter,GetEntityCoords(PlayerPedId())) > wx.Radius+0.0 then
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),vector3(402.9156, -996.7591, -99.0002)) > 10.0 then
			SetEntityCoords(PlayerPedId(), wx.Locations.JailEnter[ math.random( #wx.Locations.JailEnter ) ])
			if wx.BanOnLeave then
				TriggerServerEvent('wx_jail:ban')
			end

			lib.notify({
				title = 'Věznice',
				description = Locale["TooFar"],
				type = 'error',
				position = 'top'
			})
			return
		end
	end
end

if wx.NoShooting then
	Citizen.CreateThread(function ()
		while true do
			Wait(0)
			local pcoords = GetEntityCoords(PlayerPedId())
			if GetDistanceBetweenCoords(pcoords,wx.Locations.JailCenter) < wx.Radius+0.0 and not wx.Jobs[PlayerData.job.name] then
				DisablePlayerFiring(PlayerPedId(),true)
				DisableControlAction(0,140,true)
				DisableControlAction(0,141,true)
			else
				EnableControlAction(0,140,true)
				EnableControlAction(0,141,true)
			end
		end
	end)
end

function TimeLeft()

	Citizen.CreateThread(function()

		while jailTime > 0 do
			jailTime = jailTime - 1
			if jailTime == 0 then
				UnJail()
				TriggerServerEvent("wx_jail:updateJailTime", 0)
			end
			TriggerServerEvent("wx_jail:updateJailTime", jailTime)
			Citizen.Wait(60000*wx.MinuteToYears)
		end

	end)
	Citizen.CreateThread(function ()
		while jailTime > 0 do Wait(0)
			if wx.AntiLeave then CheckTeleport() end
			if jailTime == 1 then
				DrawTxt(1.0, 1.45, 1.0, 1.0, 0.4, ("<font face = 'BBN'><font color = '#FFFFFF'>"..Locale["YearR"].." <font color = '#FFCD00'>"):format(jailTime), 255, 255, 255, 255)
			elseif jailTime > 5 then
				DrawTxt(1.0, 1.45, 1.0, 1.0, 0.4, ("<font face = 'BBN'><font color = '#FFFFFF'>"..Locale["YearsR"].." <font color = '#FFCD00'>"):format(jailTime), 255, 255, 255, 255)
			end

		end
	end)

end

--same usage as playerLoaded
AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	Citizen.Wait(2000)
	ESX.TriggerServerCallback("wx_jail:retrieveJailTime", function(inJail, time)
		if inJail then
			jailTime = time --Time display quickfix :D
			SetEntityCoords(PlayerPedId(), wx.Locations.JailEnter[math.random(#wx.Locations.JailEnter)])

			lib.notify({
				title = Locale["JailTitle"],
				description = Locale["Disconnected"],
				type = 'error',
				position = 'top'
			})
			TimeLeft()
		end
	end)
end)

