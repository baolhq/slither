local sceneManager = {
    current = "title", -- "title", "main", "leaderboard"
}

local scenes = {
    title = require("src/scenes/title_scene"),
    main = require("src/scenes/main_scene"),
    leaderboard = require("src/scenes/lboard_scene")
}

function sceneManager:switch(sceneName, assets)
    if scenes[sceneName] then
        self.current = sceneName
        if scenes[self.current].load then
            -- Callback actions from child scene
            local actions = {
                switchScene = function(newScene)
                    self:switch(newScene, assets)
                end,
                quit = function()
                    love.event.quit()
                end
            }

            scenes[self.current]:load(assets, actions)
        end
    else
        error("Scene " .. sceneName .. " not found.")
    end
end

function sceneManager:keypressed(key)
    local scene = scenes[self.current]
    if scene.keypressed then
        scene:keypressed(key)
    end
end

function sceneManager:mousepressed(x, y, btn)
    local scene = scenes[self.current]
    if scene.mousepressed then
        scene:mousepressed(x, y, btn)
    end
end

function sceneManager:update(dt)
    local scene = scenes[self.current]
    if scene.update then
        scene:update(dt)
    end
end

function sceneManager:draw()
    local scene = scenes[self.current]
    if scene.draw then
        scene:draw()
    end
end

return sceneManager
