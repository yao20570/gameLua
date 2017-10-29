-- 世界地图上的建筑类
UIWorldNodeRebels = class("UIWorldNodeRebels", UIWorldNodeBase)
UIWorldNodeRebels.__index = UIWorldNodeRebels

UIWorldNodeRebels.FONT_SIZE = 16

function UIWorldNodeRebels:ctor(tileType)
    UIWorldNodeRebels.super.ctor(self, tileType)

    self._rebelDesignData = nil
end


function UIWorldNodeRebels:finalize()
    if self._rebelsAnima ~= nil then
        self._rebelsAnima:finalize()
        self._rebelsAnima = nil
    end
end

function UIWorldNodeRebels:setPosition(pos)
    UIWorldNodeRebels.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        self._rebelsPanel:setPositionX(pos.x)
        self._rebelsPanel:setPositionY(pos.y + GlobalConfig.WorldPlayerTitlePos.y )
    end
end

function UIWorldNodeRebels:renderTile(worldTileInfo, mapPanel)

    UIWorldNodeRebels.super.renderTile(self, worldTileInfo, mapPanel)

    local n = worldTileInfo.x
    local m = worldTileInfo.y


    local rebelInfo = self._worldTileInfo.rebelInfo

    -- 叛军生成配置表
    if self._rebelDesignData and self._rebelDesignData.monsterType == rebelInfo.rebelArmyType then
        return
    end
    self._rebelDesignData = ConfigDataManager:getInfoFindByOneKey(ConfigData.ArmyGoDesignConfig, "monsterType", rebelInfo.rebelArmyType)

    -- 叛军动画父节点
    if self._ccbParent == nil then
        self._ccbParent = cc.Node:create()
        self:addChild(self._ccbParent)
    end
    -- 叛军动画
    if self._rebelsAnima ~= nil then
        self._rebelsAnima:finalize()
        self._rebelsAnima = nil
    end
    if self._rebelsAnima == nil then
        if self._rebelDesignData~= nil then
        self._rebelsAnima = UICCBLayer.new("rgb-diyin0" .. self._rebelDesignData.monsterType, self._ccbParent)
        end
    end

    local nameParent = self._nameParent or self

    -- 叛军信息容器
    if self._rebelsPanel == nil then
        self._rebelsPanel = cc.Node:create()
        self._rebelsPanel:setPositionY(GlobalConfig.WorldPlayerTitlePos.y)
        nameParent:addChild(self._rebelsPanel)
    end

    -- 名称背景
    if self._rebelsNameBg == nil then
        local url = "images/map/Bg_resLvBg.png"
        local rect_table = cc.rect(14,8,48,10)
        self._rebelsNameBg = TextureManager:createScale9Sprite(url, rect_table)
        self._rebelsPanel:addChild(self._rebelsNameBg)
    end

    -- 名称
    if self._rebelsNameTxt == nil then
        self._rebelsNameTxt = ccui.Text:create()
        self._rebelsNameTxt:setFontName(GlobalConfig.fontName)
        self._rebelsNameTxt:setFontSize(UIWorldNodeRebels.FONT_SIZE)
        self._rebelsNameTxt:setColor(ColorUtils.MAP_NAME_COLOR_C3B_ENEMY)
        self._rebelsPanel:addChild(self._rebelsNameTxt)
    end
    self._rebelsNameTxt:setString(string.format(TextWords:getTextWord(401300), rebelInfo.level, self._rebelDesignData.monsterName))

    -- 设置名称背景大小
    local nameSize = self._rebelsNameTxt:getContentSize()

    local buildingTextWidth  = self._rebelsNameTxt:getContentSize().width + 25
    local buildingTextHeight = UIWorldNodeRebels.FONT_SIZE*1.7 
    self._rebelsNameBg:setContentSize(buildingTextWidth, buildingTextHeight)

    -- 战旗
    if self._rebelsFlagImg == nil then
        self._rebelsFlagImg = TextureManager:createImageView("images/map/banditFlag.png")
        self._rebelsFlagImg:setAnchorPoint(1, 0.5)
        self._rebelsFlagImg:setPositionX(- self._rebelsNameBg:getContentSize().width/2)
        self._rebelsPanel:addChild(self._rebelsFlagImg)
    end
end

-- 玩家基地标题缩放
function UIWorldNodeRebels:setBuildTxtScale(scale, fontScale) 


    if self._rebelsPanel ~= nil then 
        self._rebelsNameTxt:setFontSize(UIWorldNodeRebels.FONT_SIZE * fontScale)

        local buildingTextWidth  = self._rebelsNameTxt:getContentSize().width + 25
        local buildingTextHeight = UIWorldNodeRebels.FONT_SIZE*1.7
        self._rebelsNameBg:setContentSize(buildingTextWidth, buildingTextHeight)

        self._rebelsFlagImg:setPositionX(- self._rebelsNameBg:getContentSize().width/2)
    end

    --self._ccbParent:setScale(scale)

end


function UIWorldNodeRebels:onClickEvent()
    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        self._mapPanel:onRebelsTouch(self._worldTileInfo)
    end
end






