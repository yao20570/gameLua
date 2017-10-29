-- 世界地图上的建筑类
UIWorldNodeEmpty = class("UIWorldNodeEmpty", UIWorldNodeBase)
UIWorldNodeEmpty.__index = UIWorldNodeEmpty

function UIWorldNodeEmpty:ctor(tileType)
    UIWorldNodeEmpty.super.ctor(self, tileType)
end


function UIWorldNodeEmpty:finalize()

end

function UIWorldNodeEmpty:renderTile(worldTileInfo, mapPanel, isUpdateSeason)

    UIWorldNodeEmpty.super.renderTile(self, worldTileInfo, mapPanel)

    local n = worldTileInfo.x
    local m = worldTileInfo.y

    local seasonIndex = 1
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPHONE == targetPlatform 
        or cc.PLATFORM_OS_IPAD == targetPlatform 
        or cc.PLATFORM_OS_WINDOWS == targetPlatform then

        -- ios,win等需要显示4季，android不需要
        local seasonProxy = mapPanel:getProxy(GameProxys.Seasons)
        seasonIndex = seasonProxy:getCurSeason()        
    end

    local worldProxy = mapPanel:getProxy(GameProxys.World)
    local seasonList = worldProxy:getSeasonBlankResList(seasonIndex)


    local div = GlobalConfig.EmptyDiv
    local tmp = GlobalConfig.EmptyMod

    if isUpdateSeason ~= true then
        self._random = math.random(1, #seasonList)
        self._resId = math.fmod(n * 99 + m * 77 + self._random, div) + 1
        if n < 0 or n > 599 or m < 0 or m > 599 then
            self._resId = 99 --世界尽头
        end
    end

    if self._resId < div then
        local url
        if self._resId < tmp then
            --url = string.format("images/map/empty%d.png", self._random)  --装饰图
            url = string.format("images/map/empty%d.png", seasonList[self._random].icon)  --装饰图
        else
            url = "images/map/empty0.png"  --透明图，有的空地不显示装饰图了
        end
        if self._sprite == nil then
            self._sprite = TextureManager:createSprite(url)
            self:addChild(self._sprite)
        else
            TextureManager:updateSprite(self._sprite, url)
            self._sprite:setVisible(true)
        end
    else
        if self._sprite ~= nil then
            self._sprite:setVisible(false)
        end
    end

end


function UIWorldNodeEmpty:onClickEvent()
    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onEmptyTileTouch(self._worldTileInfo)
    end
end






