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
	local modes = {"PDF", "PNG", "JPG"}

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
		    ya.notify {
		        title = "mode",
		        content = string.format("converting %s to %s on %s",extension, mode, base_name),
		        level = "info",
		        timeout = 5,
		    }
		end

		local output, err = Command("touch"):arg(urls):stderr(Command.PIPED):output()
		if not output then
			fail("Failed to run chmod: %s", err)
		elseif not output.status.success then
			fail("Chmod failed with stderr:\n%s", output.stderr:gsub("^chmod:%s*", ""))
		end
	end,
}
