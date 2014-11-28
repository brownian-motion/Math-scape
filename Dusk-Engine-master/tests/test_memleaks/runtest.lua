--------------------------------------------------------------------------------
--[[
The Runtest file for the memory leak tests.
--]]
--------------------------------------------------------------------------------

local dusk = require("Dusk.Dusk")

-- Get memory usage
local function getMem()
	collectgarbage("collect")
	local memUsed = (collectgarbage("count")) / 1000
	local texUsed = (system.getInfo("textureMemoryUsed")) / 1000000
	return string.format("%.03f", memUsed), string.format("%.03f", texUsed)
end

-- Runtest
local function runtest(name)
	local dusk = require("Dusk.Dusk")

	-- Build and destroy a map
	local function iterate()
		local map = dusk.buildMap("tests/test_memleaks/map.json")
		map.destroy()
		map = nil
	end

	-- Memory texts
	local sys, tex
	local sysText = display.newText("00", 512, 364, "Menlo", 32)
	local texText = display.newText("00", 512, 404, "Menlo", 32)

	timer.performWithDelay(1, function()
		iterate()
		sys, tex = getMem()
		sysText.text = sys
		texText.text = tex
	end, 0)
end

return runtest