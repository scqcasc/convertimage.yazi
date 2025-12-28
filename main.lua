--- @since 25.5.31
 
local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

local function getOSType()
	local spilt = package.config:sub(1,1)
	return spilt == "\\" and "win32" or "unix"
end

local function splitName( filename )
	local file_name, extension = filename:match("^.+/(.+)%.(.+)$")
	return file_name, extension
end
	
local function fail(s, ...)
	ya.notify {
		title = "Convert Image",
		content = string.format(s, ...),
		level = "error",
		timeout = 5,
	}
end

local function get_mode()
	local modes = {"pdf", "png", "jpeg"}

   local cand = ya.which {
            cands = {
                { on = "1", desc = "To PDF" },
                { on = "2", desc = "To PNG" },
                { on = "3", desc = "To JPG" },
            },
            silent = false,
        }
    return modes[cand]
end
    
local function convertImage(type, old_file, new_file)
	if type == "img" then
		local output, err_code = Command("magick"):arg(old_file):arg(new_file):stderr(Command.PIPED):output()
	if err_code ~= nil then
								local msg = string.format("Failed to convert %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Error",
                    content = "Status: " .. err_code,
                    level = "error",
                    timeout = 5,
                })
            else
								local msg = string.format("Successful conversion from %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Success",
                    content = msg,
                    level = "info",
                    timeout = 5,
                })
            end
	end

	if type == "doc" then
		local output, err_code = Command("pandoc"):arg("-o"):arg(new_file):arg(old_file):stderr(Command.PIPED):output()
	if err_code ~= nil then
								local msg = string.format("Failed to convert %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Error",
                    content = "Status: " .. err_code,
                    level = "error",
                    timeout = 5,
                })
            else
								local msg = string.format("Successful conversion from %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Success",
                    content = msg,
                    level = "info",
                    timeout = 5,
                })
            end
	end

end

local function getParentPath(str)
  sep='/'
  return str:match("(.*"..sep..")")
end

local function getType(ext)
	local images = {"jpeg", "jpg", "heic", "png", "tiff"}
	for _, img in pairs(images) do
		if ext == img then
			return "img"
		end
	end
		return "doc"
end

return {
	entry = function()
		ya.emit("escape", { visual = true })

		local urls = selected_or_hovered()
		if #urls == 0 then
			return ya.notify { title = "Convert Image", content = "No file selected", level = "warn", timeout = 5 }
		end

    local mode = get_mode()
    for key, value in pairs(urls)
    do
    		local base_name, extension = splitName(value)
    		local parent_path = getParentPath(value)
    		local type = getType(extension)
    		local new_file = string.format("%s%s.%s", parent_path, base_name, mode)
		    ya.notify {
		        title = "mode",
		        content = string.format("converting %s to %s on %s new name %s type %s",extension, mode, base_name, new_file, type),
		        level = "info",
		        timeout = 3,
		    }
		    convertImage(type, value, new_file)

		end

	end,
}
