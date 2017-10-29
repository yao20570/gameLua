
local GameMain = {}

function GameMain:init()

    local function loadGame()
        self:loadGame()
    end

    loadGame()

end


function GameMain:loadGame()
    self:initFramework()
    self:initGame()
    self:startGame()
end

function GameMain:initFramework()
    require("framework.__init")

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
        logger:setLevel("ERROR")
    end
end

function GameMain:initGame()
    require("game.__init")
end

function GameMain:startGame()
    local game = Game.new()
    game:startGame()
    self._game = game
end

--~~~!!!注意。lua脚本的热更需要包含在以下目录下！！
--不然加载后，更新不了
function GameMain:reLoadGame()

    for key, isLoad in pairs(package.loaded) do
        local keyAry = self:splitString(key,'.')
        if keyAry[1] == 'battle' or keyAry[1] == 'component' 
            or keyAry[1] == 'game' or keyAry[1] == 'modules' 
            or keyAry[1] == 'test' or keyAry[1] == 'framework'  
            or keyAry[1] == 'excelConfig' or keyAry[1] == 'guideData' 
            or keyAry[1] == 'ui' or keyAry[1] == 'model' or keyAry[1] == 'aiData'
            or keyAry[1] == 'effect' or keyAry[1] == 'map' or keyAry[1] == 'particle'
            or keyAry[1] == 'proto' or keyAry[1] == 'sounds' or keyAry[1] == 'buffData'
            or keyAry[1] == 'skillData' or keyAry[1] == 'server' then

            package.loaded[key] = nil
        end
    end

    self._game:finalize()

    cc.Director:getInstance():getTextureCache():removeAllTextures()
    cc.SpriteFrameCache:destroyInstance()

    self:initFramework()
    self:initGame()
    self:startGame()
end

function GameMain:splitString(strSrc, sep)
    local strArray = {}
    if strSrc == nil then
        return nil
    end
    local str = strSrc
    local len = string.len(str)
    --    local keyLen = string.len(sep)
    local tempStr = ""
    local index = 1
    for i = 1, len do
        local subStr = string.sub(str, i, i)
        if subStr == sep then
            strArray[index] = tempStr
            index = index + 1
            tempStr = ""
        else
            tempStr = tempStr..subStr
        end

        if i == len then
            strArray[index] = tempStr
        end
    end
    return strArray
end


GameMain:init()

return GameMain