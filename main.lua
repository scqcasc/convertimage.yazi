--- @since 25.5.31
 
local function display(list, message)
	for _, item in pairs(list) do
	  ya.dbg(message)
	  ya.dbg(item)
	end
end

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


local function splitName( filename )
	local file_name, extension = filename:match("^.+/(.+)%.(.+)$")
	return file_name, extension
end
	
local function getList(extension, collection)
	-- ya.dbg("Getting the list")
	-- ya.dbg("testing extension " .. extension)
	display(collection, "This is the list handled by getList ...")
    for _, item in pairs(collection) do
	-- ya.dbg("Entering outer loop")
      for i, ext in pairs(item) do
			  ya.dbg("Entering inner loop")
      	ya.dbg("Does " .. ext .. " match " .. extension)
        if ext == extension then
            table.remove(item, i)
            local my_type = item[1]
            table.remove(item, 1)
            return item, my_type
        end
    end
  end
  return nil, nil
end

local function createMenu(collection, my_extension)
	ya.dbg("Creating menu")
	local candy = {}
	display(collection, "Collection in createMenu ...")
		ya.dbg("Entering getList")
    local active_list, my_type = getList(my_extension, collection)
    ya.dbg("Back from getList")
    display(active_list, "Here is the active list ...")
    -- this creates the menu
    if ( not(active_list == nil)) then
       for i, ext in pairs(active_list) do
       	  local c = { on =  tostring(i), desc = "To " .. ext }
       	  ya.dbg(c)
          table.insert(candy, c)
       end
       return candy, active_list
    end
end

local function getMode(ext, collection)
	ya.dbg("Getting the mode")

	display(collection, "displaying collection from get_mode ...")
	local candy, modes = createMenu(collection, ext)
	display(candy, "Here is your candy ...")
   local cand = ya.which {
            cands = candy,
            silent = false,
        }
    return modes[cand]
end
    
Timeout = 3

local function convertImage(type, old_file, new_file)
	if type == "img" then
		local output, err_code = Command("magick"):arg(old_file):arg(new_file):stderr(Command.PIPED):output()
	if err_code ~= nil then
								local msg = string.format("Failed to convert %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Error",
                    content = "Status: " .. err_code,
                    level = "error",
                    timeout = Timeout,
                })
            else
								local msg = string.format("Successful conversion from %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Success",
                    content = msg,
                    level = "info",
                    timeout = Timeout,
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
                    timeout = Timeout,
                })
            else
								local msg = string.format("Successful conversion from %s to %s", old_file, new_file)
                ya.notify({
                    title = "Convert Success",
                    content = msg,
                    level = "info",
                    timeout = Timeout,
                })
            end
	end

end

local function getParentPath(str)
  local sep='/'
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

local function findExtension(urls)
	local extensions = {}
	for _, url in pairs(urls) do
		local _, ext = splitName(url)
		ya.dbg(ext)
		table.insert(extensions, ext)
	end
	return extensions
end


return {
	entry = function()
		ya.emit("escape", { visual = true })

		local urls = selected_or_hovered()
		if #urls == 0 then
			return ya.notify { title = "Convert Image", content = "No file selected", level = "warn", timeout = 5 }
		end

		-- need the extension of selected files here
    local images = {"images","cancel", "jpg", "jpeg", "png", "tiff", "heic", "webp"}
    local docs = {"docs","cancel", "md", "pdf", "docx"}
		local collection = {images, docs}
		-- display(collection, "displaying collection from main ...")
		local exts = findExtension(urls)
		-- display(exts, "Here are the extensions ...")
    local mode = getMode(exts[1], collection)
    if (not (mode == "cancel")) then
    	for _, value in pairs(urls)
    	do
    			local base_name, extension = splitName(value)
    			local parent_path = getParentPath(value)
    			local type = getType(extension)
    			local new_file = string.format("%s%s.%s", parent_path, base_name, mode)
		    	convertImage(type, value, new_file)
		    		
			end
		end

	end,
}
