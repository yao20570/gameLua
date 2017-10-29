-- 世界地图上的建筑类
UIWorldNodeBuilding = class("UIWorldNodeBuilding", UIWorldNodeBase)
UIWorldNodeBuilding.__index = UIWorldNodeBuilding

UIWorldNodeBuilding.FONT_SIZE = 16

function UIWorldNodeBuilding:ctor(tileType)
    UIWorldNodeBuilding.super.ctor(self, tileType)

    self._countSkillCcbName = {}
    self._countSkillCcbName[1] = "rgb-jn-pofang"
    self._countSkillCcbName[2] = "rgb-jn-fangzhu"
    self._countSkillCcbName[3] = "rgb-jn-jinwu"
    self._countSkillCcbName[4] = "rgb-jn-jinyan"
end


function UIWorldNodeBuilding:finalize()
    if self._protectUI ~= nil then
        self._protectUI:finalize()
        self._protectUI = nil
    end

    if self._buildEffect ~= nil then
        self._buildEffect:finalize()
        self._buildEffect = nil
    end

    if self._skillBuffEffect ~= nil then
        self._skillBuffEffect:finalize()
        self._skillBuffEffect = nil
    end
end


function UIWorldNodeBuilding:setPosition(pos)
    UIWorldNodeBuilding.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        local dy = GlobalConfig.WorldPlayerTitlePos.y
        self._buildTxtBg:setPositionX(pos.x - 5 )
        self._buildTxtBg:setPositionY(pos.y + dy )

        self._buildNameTxt:setPositionX(pos.x - 5 )
        self._buildNameTxt:setPositionY(pos.y + dy + 1 )
    end
end

function UIWorldNodeBuilding:renderTile(worldTileInfo, mapPanel)
    UIWorldNodeBuilding.super.renderTile(self, worldTileInfo, mapPanel)

    local n = worldTileInfo.x
    local m = worldTileInfo.y

    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local x, y = roleProxy:getWorldTilePos()
    if x == n and y == m then
        self._mapPanel["selfBuilding"] = self --自己的建筑
    end
    
    -- 图片
    local buildIcon = worldTileInfo.buildingInfo.buildIcon
    local pretendIcon = rawget(worldTileInfo.buildingInfo,"pretendIcon")
    local url = string.format("images/map/building%d.png", buildIcon)
    if pretendIcon and pretendIcon ~= 0 then --显示伪装外观
        local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.BuildingSurfaceConfig,"type",pretendIcon)
        if config then
            url = string.format("images/map/res%d.png", config.pretendIcon)
        end
        --logger:info("伪装外观 ",pretendIcon,url)
    end
    --logger:info("基地 URL：%s",url)

    if self._sprite == nil then
        self._sprite = TextureManager:createSprite(url)
        self:addChild(self._sprite)
    else
        TextureManager:updateSprite(self._sprite, url)
    end

    -- 动画
    if buildIcon == 51 then
        if self._buildEffect == nil then
            self._buildEffect = UICCBLayer.new("rgb-feixu", self._sprite)
            local size = self._sprite:getContentSize()
            self._buildEffect:setPosition(size.width / 2, size.height / 2)
        else
            self._buildEffect:setVisible(true)
        end
    else
        if self._buildEffect ~= nil then
            self._buildEffect:setVisible(false)
        end
    end


    self:addBuildingTxt(worldTileInfo)
    if pretendIcon and pretendIcon ~= 0 then --显示伪装外观,不显示标题
        if self._buildTxtBg ~= nil then
            self._buildTxtBg:setVisible(false)
        end
        if self._buildNameTxt ~= nil then
            self._buildNameTxt:setVisible(false)
        end
    else
        if self._buildTxtBg ~= nil then
            self._buildTxtBg:setVisible(true)
        end
        if self._buildNameTxt ~= nil then
            self._buildNameTxt:setVisible(true)
        end
    end

end

--玩家基地标题缩放
-- @fontScale   标题缩放参数
function UIWorldNodeBuilding:setBuildTxtScale(scale, fontScale)
    -- 改变的是字体大小，之后背景随着改变
    if self._buildTxtBg ~= nil and self._buildNameTxt ~= nil then
        self._buildNameTxt:setFontSize( UIWorldNodeBuilding.FONT_SIZE * fontScale)
        
        local nameLen = StringUtils:separate(self._buildNameTxt:getString() or " ")
        
        local buildingTextWidth  = self._buildNameTxt:getContentSize().width + 25
        local buildingTextHeight = UIWorldNodeBuilding.FONT_SIZE*1.7
        self._buildTxtBg:setContentSize(buildingTextWidth, buildingTextHeight)
    end


    -- local dy = GlobalConfig.WorldPlayerTitlePos.y
    -- if self._buildLegionBg ~= nil then
        -- self._buildLegionBg:setPosition( - self._buildTxtBg:getContentSize().width/2-34*scale,dy)
    -- end

    if self._sprite~=nil then
        self._sprite:setScale(scale)  
    end
end

-- 玩家建筑信息
function UIWorldNodeBuilding:addBuildingTxt(worldTileInfo)
    
    local nameParent = self._nameParent or self
        

    local dy = GlobalConfig.WorldPlayerTitlePos.y
    if self._buildTxtBg == nil then
        local url = "images/map/Bg_resLvBg.png"
        local rect_table = cc.rect(14,8,48,10)
        self._buildTxtBg = TextureManager:createScale9Sprite(url, rect_table)
        self._buildTxtBg:setPositionY(dy)
        self._buildTxtBg:setPositionX(-5)
        nameParent:addChild(self._buildTxtBg, 1)
    end

    local buildingInfo = worldTileInfo.buildingInfo
    local name = buildingInfo.name
    local level = buildingInfo.level

    if self._buildNameTxt == nil then
        self._buildNameTxt = ccui.Text:create()
        self._buildNameTxt:setFontName(GlobalConfig.fontName) 
        self._buildNameTxt:setFontSize(UIWorldNodeBuilding.FONT_SIZE)
        self._buildNameTxt:setPosition(-5, dy+1)
        nameParent:addChild(self._buildNameTxt, 3)
    end
    self._buildNameTxt:setString(name.."  "..level.."级") -- size

    -- 设置背景大小
    local buildingTextWidth  = self._buildNameTxt:getContentSize().width + 25
    local buildingTextHeight = UIWorldNodeBuilding.FONT_SIZE*1.7
    self._buildTxtBg:setContentSize(buildingTextWidth, buildingTextHeight)


    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)
    local selfLegionName = roleProxy:getLegionName()

    local myName = roleProxy:getRoleName()
    self._buildNameTxt:setColor(ColorUtils.MAP_NAME_COLOR_C3B_OTHER)--103(191, 73, 73)

    -- 有军团 屏蔽同盟标识的显示
     if worldTileInfo.legionName ~= "" and selfLegionName == worldTileInfo.legionName then
--         if self._buildLegionBg == nil then
--             local url = "images/common/legion.png"
--             self._buildLegionBg = TextureManager:createSprite(url)
--             local legionBg = self._buildLegionBg
--             self:addChild(legionBg)
--         else
--             self._buildLegionBg:setVisible(true)
--         end
         self._buildNameTxt:setColor(ColorUtils.MAP_NAME_COLOR_C3B_LEGION)--43, 165, 50
     elseif self._buildLegionBg ~= nil then
        -- self._buildLegionBg:setVisible(false)
        -- self._buildLegionBg = nil
     end

    if name == myName then
        self._buildNameTxt:setColor(ColorUtils.MAP_NAME_COLOR_C3B_SELF) -- 自己名称变白
    end

    -- 免战保护小朋友
    if buildingInfo.protect == 1 then
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

    -- 技能图标
    -- if name == myName then  --查看自己
    --     local lordCityProxy = self._mapPanel:getProxy(GameProxys.LordCity)
    --     local isHaveSkillBuff = lordCityProxy:isHaveCitySkillBuff()
    --     if isHaveSkillBuff == true then
    --         if self._skillBuffEffect == nil then
    --             self._skillBuffEffect = UICCBLayer.new("rgb-jn-kouya", self)
    --         else
    --             self._skillBuffEffect:setVisible(true)
    --         end
    --         self._skillBuffEffect:setPosition(-40, dy+28)
    --     else
    --         if self._skillBuffEffect ~= nil then
    --             self._skillBuffEffect:setVisible(false)
    --         end            
    --     end
    -- else
    --     if self._skillBuffEffect ~= nil then
    --         self._skillBuffEffect:setVisible(false)
    --     end
    -- end

    -- 0为没有限制迁城，1为被限制迁城
    if rawget(buildingInfo, "banMove") then
        if buildingInfo.banMove == 1 then
            --logger:info("-- 1为被限制迁城")
            if self._skillBuffEffect == nil then
                self._skillBuffEffect = UICCBLayer.new("rgb-jn-kouya", self)
            else
                self._skillBuffEffect:setVisible(true)
            end
            self._skillBuffEffect:setPosition(-55, dy+29)
        else
            --logger:info("-- 0为没有限制迁城")
            if self._skillBuffEffect ~= nil then
                self._skillBuffEffect:setVisible(false)
            end            
        end
    end

    -- 国家技能效果图标显示
    self:setCountrySkills(buildingInfo)
end

-- 国家技能效果图标显示
function UIWorldNodeBuilding:setCountrySkills(buildingInfo)

    local function getIndex(skillId)
        local index = 0 
        for i, id in pairs(buildingInfo.skills) do
            if id == skillId then
                index = i
                break
            end
        end
        return index
    end

    local skillConfig = ConfigDataManager:getConfigData(ConfigData.CountrySkillConfig) 
    for i = 1, #skillConfig do
        local id = skillConfig[i].ID
        local index = getIndex(id)
        if index ~= 0 then
            if self["countrySkillCcb"..id] == nil then
                self["countrySkillCcb"..id] = UICCBLayer.new(self._countSkillCcbName[id], self)
            else
                self["countrySkillCcb"..id]:setVisible(true)
            end

            local diffX = 32* index
            if self._skillBuffEffect == nil or self._skillBuffEffect:isVisible() == false then
                diffX = 32* (index - 1)
            end
            self["countrySkillCcb"..id]:setPosition(-55 + diffX, GlobalConfig.WorldPlayerTitlePos.y + 29)
        elseif index == 0 then
            if self["countrySkillCcb"..id] ~= nil then
                self["countrySkillCcb"..id]:setVisible(false)
            end  
        end
    end
end

function UIWorldNodeBuilding:onClickEvent()
    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onWatchPlayerInfoTouch(self._worldTileInfo)
    end

end








