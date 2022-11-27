repeat
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").OutdoorAmbient = Color3.new(1, 1, 1)
	game:GetService("MaterialService").Use2022Materials = false
until game:GetService("Lighting").GlobalShadows == false

local hidingV = Instance.new("BoolValue")
hidingV.Parent = game.Players.LocalPlayer

local plr = game.Players.LocalPlayer

local hiding = false

task.spawn(function()
	while task.wait() do
		hidingV.Value = hiding
	end
end)

local roomsFolder = Instance.new("Folder")
roomsFolder.Parent = workspace
roomsFolder.Name = "NewRooms"
local miscFolder = Instance.new("Folder")
miscFolder.Parent = workspace
miscFolder.Name = "Misc"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoomsToBeGenerated = Instance.new("Folder")
RoomsToBeGenerated.Parent = ReplicatedStorage
RoomsToBeGenerated.Name = "UngeneratedRooms"

local currentRoomV = Instance.new("IntValue")
currentRoomV.Parent = workspace
currentRoomV.Name = "currentRoom"
currentRoomV.Value = 0

local currentRoomNr = currentRoomV.Value

task.spawn(function()
	while task.wait() do
		currentRoomV.Value = currentRoomNr
	end
end)

local projectorRoom = game:GetObjects("rbxassetid://11662039125")[1]
projectorRoom.Parent = RoomsToBeGenerated

local emptyRoom = game:GetObjects("rbxassetid://11668202443")[1]
emptyRoom.Parent = RoomsToBeGenerated

local tallRoom = game:GetObjects("rbxassetid://11668631354")[1]
tallRoom.Parent = RoomsToBeGenerated

local storageRoom = game:GetObjects("rbxassetid://11668811828")[1]
storageRoom.Parent = RoomsToBeGenerated

local completelyEmptyRoom = game:GetObjects("rbxassetid://11668855905")[1]
completelyEmptyRoom.Parent = RoomsToBeGenerated

local entitiesFolder = Instance.new("Folder")
entitiesFolder.Parent = game:GetService("ReplicatedStorage")
entitiesFolder.Name = "RoomsEntities"

local a60 = game:GetObjects("rbxassetid://11670406851")[1]
a60.Parent = entitiesFolder

local a200 = game:GetObjects("rbxassetid://11670452812")[1]
a200.Parent = entitiesFolder

local tweenService = game:GetService("TweenService")
local oldParts = workspace.CurrentRooms:GetDescendants()

local prevRoomNr

local plrCurrentRoomValue = Instance.new("IntValue")
plrCurrentRoomValue.Parent = workspace
plrCurrentRoomValue.Name = "PlrCurrentRoom"
local plrCurrentRoom = plrCurrentRoomValue.Value
task.spawn(function()
	while task.wait() do
		plrCurrentRoomValue = plrCurrentRoom
	end
end)

local ModuleScripts = {
	MainGame = require(game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game),
	ModuleEvents = require(game:GetService("ReplicatedStorage").ClientModules.Module_Events),
}

local a60Speed = 30000
local a200Speed = 15000

local root = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

local oldRooms = workspace.CurrentRooms:GetChildren()

local function kill(model)
	plr.Character.Humanoid.Health = 0
	local blur = Instance.new("BlurEffect")
	blur.Parent = game:GetService("Lighting")
	model:FindFirstChild("KillSound").Parent = workspace
	workspace.KillSound:Play()
	task.spawn(function()
		wait(0.5)
		tweenService:Create(workspace.KillSound, TweenInfo.new(1), {Volume = 0}):Play()
		wait(1)
		workspace.KillSound:Stop()
		workspace.KillSound.Parent = model
		model:FindFirstChild("KillSound").Volume = 10
	end)
end

local function spawnEntity(name)
	local spawnLocation = roomsFolder:GetChildren()[1].Enter.CFrame
	local a200SpawnLocation = roomsFolder:FindFirstChild(plrCurrentRoom).Exit.CFrame * CFrame.Angles(0, math.rad(-180), 0)
	local diff
	if name == "60" and entitiesFolder:FindFirstChild("monster") then
		task.spawn(function()
			while task.wait() do
				diff = (a60.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if diff < 200 then
					ModuleScripts.MainGame.camShaker.ShakeOnce(ModuleScripts.MainGame.camShaker, table.unpack({5, 50, 0.3, 0.7}))
				end
			end
		end)
		a60.Parent = workspace
		a60.CFrame = spawnLocation
		a60.Static:Play()
		tweenService:Create(a60, TweenInfo.new(120, Enum.EasingStyle.Linear), {CFrame = a60.CFrame * CFrame.new(0,0,-a60Speed)}):Play()
		task.spawn(function()
			task.wait(120)
			a60.Parent = entitiesFolder
			a60.Static:Stop()
		end)
		a60.Touched:Connect(function(hit)
			if hit.Name == "UpperTorso" and hiding == false then
				kill(a60)
			end
		end)
	elseif name == "200" and entitiesFolder:FindFirstChild("monster2") then
		task.spawn(function()
			while task.wait() do
				diff = (a200.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				if diff < 200 then
					ModuleScripts.MainGame.camShaker.ShakeOnce(ModuleScripts.MainGame.camShaker, table.unpack({5, 5, 0.3, 1}))
				end
			end
		end)
		a200.Parent = workspace
		a200.CFrame = a200SpawnLocation * CFrame.new(0,0,500)
		a200:FindFirstChild("200spawn").Parent = workspace
		workspace:FindFirstChild("200spawn"):Play()
		tweenService:Create(a200, TweenInfo.new(120, Enum.EasingStyle.Linear), {CFrame = a200.CFrame * CFrame.new(0,0,-a200Speed)}):Play()
		task.spawn(function()
			task.wait(20)
			a200:FindFirstChild("200leave").Parent = workspace
			workspace:FindFirstChild("200leave"):Play()
			workspace:FindFirstChild("200spawn").Parent = a200
			task.wait(0.6)
			workspace:FindFirstChild("200leave").Parent = a200
			a200.Parent = entitiesFolder
		end)
		a200.Touched:Connect(function(hit)
			if hit.Name == "UpperTorso" and hiding == false then
				kill(a200)
			end
		end)
	end
end

for i,v in pairs(oldRooms) do
	if v.Name ~= "0" then
		v:Destroy()
	end
end

local function generate(spot)
	local randomRoom = RoomsToBeGenerated:GetChildren()[math.random(1, #RoomsToBeGenerated:GetChildren())]:Clone()
	randomRoom.Parent = roomsFolder
	randomRoom.Name = currentRoomNr
	randomRoom:PivotTo(spot.CFrame)
end

local function openMain(doorHinge)
	tweenService:Create(doorHinge, TweenInfo.new(1), {CFrame = doorHinge.CFrame * CFrame.Angles(0,math.rad(-90),0)}):Play()
	plrCurrentRoom = plrCurrentRoom + 1
	print(plrCurrentRoom)
	if plrCurrentRoom > 60 then
		local rNumber = math.random(1,10)
		if rNumber == 1 then
			print("spawned a60")
			spawnEntity("60")
		end
	end
	if plrCurrentRoom > 200 then
		local rNumber = math.random(1,10)
		if rNumber == 1 then
			print("spawned a200")
			spawnEntity("200")
		end
	end
end

local function copydoorMain(pivot, room)
	local opened = false
	local woodDoor = game:GetObjects("rbxassetid://11661447545")[1]
	woodDoor.Parent = room
	woodDoor.PrimaryPart = woodDoor.WoodDoor
	woodDoor:SetPrimaryPartCFrame(pivot.CFrame * CFrame.Angles(0,math.rad(0),0))
	woodDoor.Hinge.BrickColor = BrickColor.new("White")
	woodDoor.Hinge.CanCollide = false
	woodDoor.Hinge.Anchored = true
	local weld = Instance.new("WeldConstraint")
	weld.Parent = woodDoor.WoodDoor
	weld.Part0 = woodDoor.WoodDoor
	weld.Part1 = woodDoor.Hinge
	task.spawn(function()
		while task.wait() do
			if opened == false and woodDoor ~= nil then
				local diff = woodDoor.PrimaryPart.Position - root.Position
				if diff.Magnitude < 7 then
					opened = true
					openMain(woodDoor.Hinge)
				end
			end
		end
	end)
	if room:FindFirstChild("Type") then
		if room.Type.Value == "Empty" then
			woodDoor.WoodDoor.Transparency = 1
			woodDoor.WoodDoor.CanCollide = false
		end
	end
end

local function open(doorHinge)
	if doorHinge.Parent ~= nil then
		local currentRoom
		tweenService:Create(doorHinge, TweenInfo.new(1), {CFrame = doorHinge.CFrame * CFrame.Angles(0,math.rad(-90),0)}):Play()
		for i=1,300 do
			currentRoomNr = currentRoomNr + 1
			prevRoomNr = currentRoomNr - 1
			local prevRoom = roomsFolder:FindFirstChild(prevRoomNr)
			if prevRoom then
				generate(prevRoom:FindFirstChild("Exit"))
				copydoorMain(prevRoom:FindFirstChild("Exit"), currentRoom)
			else
				for i,part in pairs(oldParts) do
					if part.Name == "Door" and part:IsA("Model") and part:FindFirstChild("Door") then
						generate(part.Door)
					end
				end
			end
			currentRoom = roomsFolder:FindFirstChild(currentRoomNr)
			if currentRoomNr < 9 then
				currentRoom.label.sg.text.Text = "A-00"..currentRoomNr + 1
			elseif currentRoomNr >= 9 then
				currentRoom.label.sg.text.Text = "A-0"..currentRoomNr + 1
			elseif currentRoomNr >= 99 then
				currentRoom.label.sg.text.Text = "A-"..currentRoomNr + 1
			end
		end
	end
	for i,v in pairs(roomsFolder:GetDescendants()) do
		if v.Name == "locker" then
			local locker = v
			locker.Seat.Touched:Connect(function(hit)
				if hit.Name == "UpperTorso" then
					hiding = true
					print("hiding!")
				end
			end)
			locker.Seat.TouchEnded:Connect(function(hit)
				if hit.Name == "UpperTorso" then
					hiding = false
					print("no longer hiding")
				end
			end)
		end
	end
	plrCurrentRoom = plrCurrentRoom + 1
	--local randomRoom = RoomsToBeGenerated:GetChildren()[math.random(1, #RoomsToBeGenerated:GetChildren())]
	--randomRoom.Parent = roomsFolder
	--randomRoom.Name = currentRoomNr
	--for i,v in pairs(roomsFolder:GetChildren()) do
	--	if v.Name == prevRoomNr then
	--		local prevRoom = v
	--		randomRoom:PivotTo(prevRoom:FindFirstChild("Exit").CFrame)
	--	end
	--end
	--tweenService:Create(doorHinge, TweenInfo.new(1), {CFrame = doorHinge.CFrame * CFrame.Angles(0,math.rad(-90),0)}):Play()
	--end
end





local function CopyDoor(model, doorPart)
	local opened = false
	local woodDoor = game:GetObjects("rbxassetid://11661447545")[1]
	woodDoor.Parent = miscFolder
	woodDoor.PrimaryPart = woodDoor.WoodDoor
	woodDoor:SetPrimaryPartCFrame(doorPart.CFrame)
	woodDoor.Hinge.BrickColor = BrickColor.new("White")
	woodDoor.Hinge.CanCollide = false
	woodDoor.Hinge.Anchored = true
	local weld = Instance.new("WeldConstraint")
	weld.Parent = woodDoor.WoodDoor
	weld.Part0 = woodDoor.WoodDoor
	weld.Part1 = woodDoor.Hinge
	model.Parent = game:GetService("ReplicatedStorage")
	task.spawn(function()
		while task.wait() do
			if opened == false then
				local diff = woodDoor.PrimaryPart.Position - root.Position
				if diff.Magnitude < 7 then
					opened = true
					open(woodDoor.Hinge)
				end
			end
		end
	end)
end

for i,part in pairs(oldParts) do
	if part.Name == "Door" and part:IsA("Model") and part:FindFirstChild("Door") then
		CopyDoor(part, part:FindFirstChild("Door"))
	end
end
