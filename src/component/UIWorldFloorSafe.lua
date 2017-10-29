-- 世界地图上的安全区域效果
UIWorldFloorSafe = class("UIWorldFloorSafe", function()
    return UIMapNodeExtend.extend(cc.Node:create())
end )

UIWorldFloorSafe.__index = UIWorldFloorSafe

UIWorldFloorSafe._safeNodeUrl = { }
UIWorldFloorSafe._safeNodeUrl[1] = "images/mapIcon/safe1.png"
UIWorldFloorSafe._safeNodeUrl[2] = "images/mapIcon/safe2.png"
UIWorldFloorSafe._safeNodeUrl[3] = "images/mapIcon/safe3.png"
UIWorldFloorSafe._safeNodeUrl[4] = "images/mapIcon/safe4.png"
UIWorldFloorSafe._safeNodeUrl[5] = "images/mapIcon/safe5.png"
UIWorldFloorSafe._safeNodeUrl[6] = "images/mapIcon/safe6.png"
UIWorldFloorSafe._safeNodeUrl[7] = "images/mapIcon/safe7.png"
UIWorldFloorSafe._safeNodeUrl[8] = "images/mapIcon/safe8.png"
UIWorldFloorSafe._safeNodeUrl[9] = "images/mapIcon/safe9.png"

function UIWorldFloorSafe:ctor()
    self._tileX = 0
    self._tileY = 0
    self:setScale(GlobalConfig.worldMapScale)
end

function UIWorldFloorSafe:finalize()

end

function UIWorldFloorSafe:getTilePos()
    return self._tileX, self._tileY
end

function UIWorldFloorSafe:getKey()
    return self._tileX * 10000 + self._tileY
end

function UIWorldFloorSafe:renderTile(tileX, tileY, safeNodeType)

    self._tileX = tileX
    self._tiley = tileY
    self._safeNodeType = safeNodeType

    local url = UIWorldFloorSafe._safeNodeUrl[safeNodeType]
    -- 装饰图
    if self._sprite == nil then
        self._sprite = TextureManager:createSprite(url)
        self:addChild(self._sprite)
    else
        TextureManager:updateSprite(self._sprite, url)
    end
end



