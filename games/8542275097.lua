local taskware = shared.taskware
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and taskware then 
		taskware:CreateNotification('Taskware', 'Failed to load : '..err, 30, 'alert') 
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function() 
		return readfile(file) 
	end)
	return suc and res ~= nil and res ~= ''
end
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

taskware.Place = 8768229691
if isfile('taskware/games/'..taskware.Place..'.lua') then
	loadstring(readfile('taskware/games/'..taskware.Place..'.lua'), 'skywars')()
else
	if not shared.TaskDeveloper then
		local suc, res = pcall(function() 
			return game:HttpGet('https://raw.githubusercontent.com/LeTask/Taskware/'..readfile('taskware/profiles/commit.txt')..'/games/'..taskware.Place..'.lua', true) 
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('taskware/games/'..taskware.Place..'.lua'), 'skywars')()
		end
	end
end