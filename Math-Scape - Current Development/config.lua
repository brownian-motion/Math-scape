application = {
	content = {
        -- if width and height aren't specified, they will default to the size of the screen

        width = 1080,
		height = 1920, 
		scale = "letterBox",
		fps = 30,

		
		--[[
        imageSuffix = {
		    ["@2x"] = 2,
		}
		--]]
	},

    --[[
    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }
    --]]    
}
