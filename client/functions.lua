local CamOpt = {
	["CameraPos"] = { ["x"] = 402.88830566406, ["y"] = -1003.8851318359, ["z"] = -97.419647216797, ["rotationX"] = -15.433070763946, ["rotationY"] = 0.0, ["rotationZ"] = -0.31496068835258, ["cameraId"] = 0 }
}

CS = false


function LoadAnim(animDict)
	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
end

function LoadModel(model)
	RequestModel(model)

	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end
end

function Cutscene()
	SwitchOutPlayer(PlayerPedId(), 0, 1)
	Citizen.Wait(250)

	LoadModel(wx.PhotoNPC)
	local photoNPC = CreatePed(5, wx.PhotoNPC, 402.9170, -1000.6376, -99.0040, 356.8805, false)
	TaskStartScenarioInPlace(photoNPC, "WORLD_HUMAN_PAPARAZZI", 0, false)

	local PlayerPed = PlayerPedId()
	SetEntityCoords(PlayerPed, 428.3845, -980.2968, 30.7114 - 1)
	SetEntityHeading(PlayerPed, 186.2249)
	FreezeEntityPosition(PlayerPed, true)
	RemoveAllPedWeapons(PlayerPedId())
	
	Citizen.Wait(5500)
	SwitchInPlayer(PlayerPedId())
	DoScreenFadeIn(1500)
	SetEntityCoords(PlayerPed, 402.9156, -996.7591, -99.0002 - 1)
	Cam()
	Citizen.Wait(1000)
	DoScreenFadeIn(100)
	Citizen.Wait(10000)
	Citizen.Wait(1000)
	DoScreenFadeIn(250)

	RenderScriptCams(false,  false,  0,  true,  true)
	FreezeEntityPosition(PlayerPed, false)
	DestroyCam(CamOpt["CameraPos"]["cameraId"])
	SetEntityCoords(PlayerPed, wx.Locations.JailEnter[ math.random( #wx.Locations.JailEnter ) ])
	DeleteEntity(photoNPC)
	SetModelAsNoLongerNeeded(-1320879687)
	CS = true


	TimeLeft()
end

function Cam()
	local CamOptions = CamOpt["CameraPos"]

	CamOptions["cameraId"] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(CamOptions["cameraId"], CamOptions["x"], CamOptions["y"], CamOptions["z"])
	SetCamRot(CamOptions["cameraId"], CamOptions["rotationX"], CamOptions["rotationY"], CamOptions["rotationZ"])

	RenderScriptCams(true, false, 0, true, true)
end
