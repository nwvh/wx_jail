wx = {}

wx.Debug = true -- Debug, you can jail yourself

wx.Target = false -- Jailing player via target
wx.ChatMessages = false -- Send chat message when player is jailed
wx.Command = 'jailmenu' -- Command for manual jailmenu
wx.Confiscate = true -- Confiscate items when you're set to jail
wx.ChangeClothes = false -- Change clothes when you're set to jail
wx.JailMenu = true -- Allow /jailmenu for your officers
wx.AdminJail = true -- Allow /adminjail command for your admins
wx.ManualJail = false -- Add "reception" straight to jail for officers. They won't be able to use jail option in /jailmenu
wx.MaxTime = 100 -- Maximum jail time
wx.MinuteToYears = 2 -- How many minutes should equal to 1 year?
wx.AntiLeave = true -- Teleports player back when he leaves the jail area 
wx.BanOnLeave = false -- Ban player when he leaves the jail area?
wx.PhotoNPC = `s_m_y_cop_01` -- NPC for photographing player before jail
wx.NoShooting = true -- Disable shooting, punching and other forms of attacking in jail area (Bypass for officers)

wx.Groups = { -- Admin Groups
	['admin'] = true,
	['dev'] = true,
	['owner'] = true,
	['trial'] = true,
	['mod'] = true,
}

wx.Jobs = { -- Police jobs (Jail Access)
	['police'] = true,
	['sheriff'] = true,
	['trooper'] = true,
}

wx.Radius = 200.0 -- Radius for checking escapees, shooting zone etc.

wx.Locations = {
	JailEnter = {
		vector4(1763.9077, 2499.9092, 45.7407, 215.4355-1),
		vector4(1774.6932, 2481.1250, 45.7407, 30.6468-1),
		vector4(1764.9320, 2476.0874, 49.6930, 28.0088-1),
		vector4(1761.6296, 2474.2410, 49.6931, 28.9665-1),
	}, -- Where to teleport jailed players? (Location is randomly selected)
	JailExit = vector4(1837.6560, 2585.7500, 46.0144, 270.1598), -- When player's jail time ends
	JailCenter = vector3(1689.7543, 2595.6868, 45.5648), -- Center of the jail, used to check distance from it (teleporting, shooting)

}

wx.BAN = function (id,reason) -- Your server side ban event/export
	exports['wx_anticheat']:Ban(id,reason)

	-- DropPlayer(id,reason)
end
