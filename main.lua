repeat task.wait() until game:IsLoaded()
if shared.taskware then shared.taskware:Uninject() end

if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local taskware
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and taskware then
		taskware:CreateNotification('Taskware', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/LeTask/Taskware/'..readfile('taskware/profiles/commit.txt')..'/'..select(1, path:gsub('taskware/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after taskware updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	taskware.Init = nil
	taskware:Load()
	task.spawn(function()
		repeat
			taskware:Save()
			task.wait(10)
		until not taskware.Loaded
	end)

	local teleportedServers
	taskware:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.TaskwareIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.taskwarereload = true
				if shared.TaskDeveloper then
					loadstring(readfile('taskware/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/LeTask/Taskware/'..readfile('taskware/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.TaskDeveloper then
				teleportScript = 'shared.TaskDeveloper = true\n'..teleportScript
			end
			if shared.TaskCustomProfile then
				teleportScript = 'shared.TaskCustomProfile = "'..shared.TaskCustomProfile..'"\n'..teleportScript
			end
			taskware:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.taskwarereload then
		if not taskware.Categories then return end
		if taskware.Categories.Main.Options['GUI bind indicator'].Enabled then
			taskware:CreateNotification('Finished Loading', taskware.TaskButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(taskware.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('taskware/profiles/gui.txt') then
	writefile('taskware/profiles/gui.txt', 'new')
end
local gui = readfile('taskware/profiles/gui.txt')

if not isfolder('taskware/assets/'..gui) then
	makefolder('taskware/assets/'..gui)
end
taskware = loadstring(downloadFile('taskware/guis/'..gui..'.lua'), 'gui')()
shared.taskware = taskware

if not shared.TaskwareIndependent then
	loadstring(downloadFile('taskware/games/universal.lua'), 'universal')()
	if isfile('taskware/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('taskware/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.TaskDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/LeTask/Taskware/'..readfile('taskware/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('taskware/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	taskware.Init = finishLoading
	return taskware
end