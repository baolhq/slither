local drawer = require("src/utils/drawer")

local titleScene = {
    assets = {}
}

function titleScene:load(assets)
    self.assets = assets
end

function titleScene:update(dt)

end

function titleScene:draw()
    drawer:drawCenteredText("SLITHER", self.assets.mainFont, -14)
    drawer:drawCenteredText("PRESS <ENTER> TO RESTART", self.assets.subFont, 14)
end

return titleScene
