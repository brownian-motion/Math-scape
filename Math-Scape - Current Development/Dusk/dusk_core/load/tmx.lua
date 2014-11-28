--------------------------------------------------------------------------------
--[[
Dusk Engine Component: TMX

Parses TMX map data.
--]]
--------------------------------------------------------------------------------

local lib_tmx = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local tprint = require("Dusk.dusk_core.misc.tprint")

local tprint_add = tprint.add
local tprint_error = tprint.error
local tprint_remove = tprint.remove

--------------------------------------------------------------------------------
-- Parse TMX String
--------------------------------------------------------------------------------
function lib_tmx.parse(str)
	tprint_add("Parse TMX")

	-- TMX parsing goes here

	-- For now, though, we can't parse it, so throw an error
	tprint_error("TMX map support is still in development.")

	tprint_remove()
end

return lib_tmx