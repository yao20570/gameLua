-- 世界地图上的建筑类
UIWorldNodeResource = class("UIWorldNodeResource", UIWorldNodeBase)
UIWorldNodeResource.__index = UIWorldNodeResource

UIWorldNodeResource.FONT_SIZE = 16

function UIWorldNodeResource:ctor(tileType)
    UIWorldNodeResource.super.ctor(self, tileType)
end


function UIWorldNodeResource:finalize()
    -- if self._moveClip ~= nil then
    --     self._moveClip:finalize()
    --     self._moveClip = nil
    -- end
    if self._protectUI ~= nil then
        self._protectUI:finalize()
        self._protectUI = nil
    end
end

function UIWorldNodeResource:setPosition(pos)
    UIWorldNodeResource.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        local dy = GlobalConfig.WorldPlayerTitlePos.y
        self._resTxtBg:setPositionX(pos.x)
        self._resTxtBg:setPositionY(pos.y + dy - 1)

        self._resTxt:setPositionX(pos.x)
        self._resTxt:setPositionY(pos.y + dy)
    end
end

function UIWorldNodeResource:renderTile(worldTileInfo, mapPanel)

    UIWorldNodeResource.super.renderTile(self, worldTileInfo, mapPanel)

    local n = worldTileInfo.x
    local m = worldTileInfo.y


    local resInfo = rawget(worldTileInfo, "resInfo")
    if resInfo == nil then
        logger:error("...资源点信息为空 tileType,x,y=%d %d %d", worldTileInfo.tileType, n, m)
        return
    end
    local resType = resInfo.restype
    local resLv = resInfo.level
    local resPointId = resInfo.resPointId
    local pointInfo = ConfigDataManager:getConfigById(ConfigData.ResourcePointConfig, resPointId)
    local url = nil
    if pointInfo then
        url = string.format("images/map/res%d.png", pointInfo.icon)
    else
        url = string.format("images/map/res%d.png", resType)
    end

    if self._sprite == nil then
        -- logger:info("create new 资源点 url = %s resType=%d reslv=%d n=%d,m=%d", url,resType,resLv,n,m)
        self._sprite = TextureManager:createSprite(url)
        self:addChild(self._sprite)
    else
        TextureManager:updateSprite(self._sprite, url)
        self._sprite:setVisible(true)
    end

    -- 屏蔽资源特效
    --[[
    local sprite = self._sprite
    if resType and resLv >= 30 then
        if self._moveClipType ~= resType then
            local conf = GlobalConfig.worldMapEffects[resType]
            if conf then
                if self._moveClip ~= nil then
                    self._moveClip:finalize()
                    self._moveClip = nil
                    self._moveClipType = nil
                end
                self._moveClip = UICCBLayer.new(conf.effectName, sprite)
                local size = sprite:getContentSize()
                self._moveClip:setPosition(size.width / 2, size.height / 2)
                self._moveClip:setVisible(true)
                self._moveClipType = resType
            end
        else
            self._moveClip:setVisible(true)
        end

    else
        if self._moveClip ~= nil then
            self._moveClip:setVisible(false)
        end
    end
    --]]

    self:addResourceTxt(resLv, 0, worldTileInfo)
    

end

-- 资源点建筑信息
function UIWorldNodeResource:addResourceTxt(lv, dx, worldTileInfo)

    local nameParent = self._nameParent or self

    local dy = GlobalConfig.WorldResTitlePos.y
    if self._resTxtBg == nil then
        local url = "images/map/mapBgColor01.png"
        self._resTxtBg = TextureManager:createSprite(url)
        self._resTxtBg:setPositionY(dy - 1)
        nameParent:addChild(self._resTxtBg)
        self._color = 1
    end
    self._resTxtBg:setLocalZOrder(4)
    

    if self._resTxt == nil then
        self._resTxt = ccui.Text:create()
        self._resTxt:setFontName(GlobalConfig.fontName)
        self._resTxt:setFontSize(UIWorldNodeResource.FONT_SIZE)
        self._resTxt:setPositionY(dy)
        nameParent:addChild(self._resTxt)
    end
    self._resTxt:setString(lv)
    self._resTxt:setColor(cc.c3b(255, 255, 255))
    self._resTxt:setLocalZOrder(5)

    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local selfLegionName = roleProxy:getLegionName()

    local worldProxy = self._mapPanel:getProxy(GameProxys.World)

    -- 有军团  屏蔽同盟标识的显示
    -- if worldTileInfo.legionName ~= "" and selfLegionName == worldTileInfo.legionName then
    --     if self._legionBg == nil then
    --         local bgSize = self._resTxtBg:getContentSize()
    --         local url = "images/common/legion.png"
    --         self._legionBg = TextureManager:createSprite(url)
    --         local legionBg = self._legionBg
    --         legionBg:setName("legionBg")
    --         legionBg:setPosition(- bgSize.width / 2 -20, dy)
    --         self:addChild(legionBg)
    --     else
    --         self._legionBg:setVisible(true)
    --     end
    -- else
        -- local legionBg = self:getChildByName("legionBg")
        -- if legionBg ~= nil then
        --     self._legionBg:setVisible(false)
        -- end
    -- end

    -- 有民忠值显示到最新
    local loyaltyCount = worldTileInfo.loyaltyCount
    if loyaltyCount ~= nil and loyaltyCount ~= 0 then
        -- 获取配置数据
        -- loyaltyCount = 50
        local loyaltyInfo = worldProxy:getLoyaltyConfigInfo(loyaltyCount)
        if loyaltyInfo ~= nil then
            local colorType =  loyaltyInfo.type -- 颜色品质数据
            if self._color ~= colorType then
                local url = string.format("images/map/mapBgColor0%d.png", colorType)
                TextureManager:updateSprite(self._resTxtBg, url)
                self._color = colorType
            end
        end

    else
        -- 没民忠或者民忠 == 0， 重新变为1
        if self._color ~= 1 then
            local url = "images/map/mapBgColor01.png"
            TextureManager:updateSprite(self._resTxtBg, url)
            self._color = 1
        end
    end

    -- 资源点保护罩
    if rawget(worldTileInfo,"resProtect") == 1 then
        if self._protectUI == nil then
            self._protectUI = UICCBLayer.new("rpg-nengliangzhao", self)
        else    
            self._protectUI:setVisible(true)
        end

    else
        if self._protectUI ~= nil then
            self._protectUI:setVisible(false)
        end
    end

end
-- 地图缩放回调
function UIWorldNodeResource:setScales(scale)
    self._sprite:setScale(scale) -- 建筑点

    self:setResTxtScale(scale)
end
-- 资源点标题缩放
function UIWorldNodeResource:setResTxtScale(scale)
    -- 缩放参数调整
    if self._resTxtBg ~= nil and self._resTxt ~= nil then
        self._resTxtBg:setScale(GlobalConfig.worldMapFontScale)
        self._resTxt:setFontSize(UIWorldNodeResource.FONT_SIZE * GlobalConfig.worldMapFontScale)
    end

end


function UIWorldNodeResource:onClickEvent()
    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onWatchResourceTouch(self._worldTileInfo)
    end
end






