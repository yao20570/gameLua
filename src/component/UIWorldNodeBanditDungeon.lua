-- 世界地图上的建筑类
UIWorldNodeBanditDungeon = class("UIWorldNodeBanditDungeon", UIWorldNodeBase)
UIWorldNodeBanditDungeon.__index = UIWorldNodeBanditDungeon

UIWorldNodeBanditDungeon.FONT_SIZE = 16

function UIWorldNodeBanditDungeon:ctor(tileType)
    UIWorldNodeBanditDungeon.super.ctor(self, tileType)
end


function UIWorldNodeBanditDungeon:finalize()
    if self._banditBg ~= nil then
        self._banditBg:finalize()
        self._banditBg = nil
    end
end

function UIWorldNodeBanditDungeon:setPosition(pos)
    UIWorldNodeBanditDungeon.super.setPosition(self, pos)

    if self._nameParent ~= nil then
        local dy = GlobalConfig.WorldPlayerTitlePos.y

         -- 名称
        if self._banditPanel ~= nil then
            self._banditPanel:setPositionX(pos.x)
            self._banditPanel:setPositionY(pos.y + dy )
        end
    end
end

function UIWorldNodeBanditDungeon:onExit()
    if self._banditDungeon ~= nil then
        TimerManager:remove(self.updateDungeonRestTime, self)
    end
    self._countDownTxt = nil
    self._banditDungeon = nil
end

function UIWorldNodeBanditDungeon:getBanditDungeonInfo()
    return self._banditDungeon
end

function UIWorldNodeBanditDungeon:renderTile(worldTileInfo, mapPanel, banditDungeon)

    UIWorldNodeBanditDungeon.super.renderTile(self, worldTileInfo, mapPanel)

    local n = worldTileInfo.x
    local m = worldTileInfo.y


    self._banditDungeon = banditDungeon
    self:addBanditDungeon(banditDungeon)


    local banditDungeonProxy = self._mapPanel:getProxy(GameProxys.BanditDungeon)
    local x, y = banditDungeonProxy:getOneBanditPosition()
    if x == n and y == m then
        self._mapPanel["banditDungeon"] = self
    end
end

-- 添加剿匪副本
function UIWorldNodeBanditDungeon:addBanditDungeon(banditDungeon)

    local eventId = banditDungeon.eventId
    local panditMonster = ConfigDataManager:getConfigById(ConfigData.PanditMonsterConfig, eventId)

    if not panditMonster then
        logger:error("please check banditDungeon.eventId %d",banditDungeon.eventId)
    end

    if self._banditBg == nil then
        local sp = cc.Sprite:create()
        self._banditBg = UICCBLayer.new("rgb-diyin-qibing", sp)
        self:addChild(sp)
        self._ccbSp = sp
    end

    local nameParent = self._nameParent or self

    if self._banditPanel == nil then
        self._banditPanel = cc.Node:create()
        local dy = GlobalConfig.WorldPlayerTitlePos.y
        self._banditPanel:setPositionY(dy)
        nameParent:addChild(self._banditPanel)
    end

    if self._nameBg == nil then
        local url = "images/map/Bg_resLvBg.png"
        local rect_table = cc.rect(14,8,48,10)
        self._nameBg = TextureManager:createScale9Sprite(url, rect_table)
        self._banditPanel:addChild(self._nameBg)
    end

    

    local name = panditMonster.name
    local level = panditMonster.lv
    local txt = string.format(TextWords:getTextWord(318), level, name)
    if self._nameTxt == nil then
        self._nameTxt = ccui.Text:create()
        self._nameTxt:setFontName(GlobalConfig.fontName)
        self._nameTxt:setFontSize(UIWorldNodeBanditDungeon.FONT_SIZE)
        self._nameTxt:setColor(ColorUtils.MAP_NAME_COLOR_C3B_ENEMY)
        self._banditPanel:addChild(self._nameTxt)
    end
    self._nameTxt:setString(txt)
    local nameSize = self._nameTxt:getContentSize()

    -- 设置背景大小
    local buildingTextWidth  = self._nameTxt:getContentSize().width + 25
    local buildingTextHeight = UIWorldNodeBanditDungeon.FONT_SIZE*1.7
    self._nameBg:setContentSize(buildingTextWidth, buildingTextHeight)


    --旗子
    if self._flagImg == nil then
        self._flagImg = TextureManager:createImageView("images/map/banditFlag.png")
        local flagImg = self._flagImg
        self._banditPanel:addChild(flagImg)
        flagImg:setAnchorPoint(1, 0.5)
    end
    self._flagImg:setPositionX(- self._nameBg:getContentSize().width / 2)
    --self._flagImg:setScale(2)

    -- 休整倒计时??
    if self._countNode == nil then
        self._countNode = cc.Node:create()
        
        self._banditPanel:addChild(self._countNode)
    end
    self._countNode:setPositionY(- nameSize.height + 13)
    --self._countNode:setVisible(false)

    if self._countBg == nil then
        local url = "images/map/bg_bandit.png"
        local rect_table = cc.rect(38,13, 1, 1)
        self._countBg = TextureManager:createScale9Sprite(url, rect_table)
        self._countBg:setContentSize(110, 26)
        self._countNode:addChild(self._countBg)

    end

    if self._countDownTxt == nil then
        self._countDownTxt = ccui.Text:create()
        self._countDownTxt:setFontName(GlobalConfig.fontName)
        self._countDownTxt:setFontSize(16)
        self._countDownTxt:setColor(ColorUtils.wordRedColor)
        self._countNode:addChild(self._countDownTxt)
    end
    
    self:updateDungeonRestTime()
    
end

function UIWorldNodeBanditDungeon:updateDungeonRestTime()
    
    --print("打完更新 黄巾贼 的状态--")
    TextureManager:updateImageView(self._flagImg, "images/map/Bg_horse.png")
    local banditDungeon = self._banditDungeon
    local banditDungeonProxy = self._mapPanel:getProxy(GameProxys.BanditDungeon)
    local time = banditDungeonProxy:getRemainRestTime(banditDungeon.id)
        
    if self._flagImg ~= nil then
        local url = time > 0 and "images/map/Bg_horse.png" or "images/map/banditFlag.png"
        TextureManager:updateImageView(self._flagImg, url)
    end

    if self._countDownTxt ~= nil then
        local txt = string.format(TextWords:getTextWord(319), TimeUtils:getStandardFormatTimeString4(time))
        --print("self._count 存在"..txt)
        self._countDownTxt:setString(txt)
        self._countDownTxt:setVisible(true)
    end

    
    --self._countNode:setVisible(false)

    if self._nameTxt and self._nameBg then
        self._nameTxt:setVisible(time <= 0)
        self._nameBg:setVisible(time <= 0)
    end

    if self._banditBg and self._flagImg then
        --self._banditBg:setVisible(time <= 0)
        self._flagImg:setVisible(time <= 0)
    end

    if time > 0 then
        --
        self._isBanditRest = true
        self._countNode:setVisible(true)
        TimerManager:addOnce(1000, self.updateDungeonRestTime, self)
    else
        self._isBanditRest = false
        self._countNode:setVisible(false)
    end
end

-- 叛军缩放
function UIWorldNodeBanditDungeon:setBuildTxtScale(scale, fontScale)
    if self._banditPanel ~= nil then
        self._nameTxt:setFontSize(UIWorldNodeBanditDungeon.FONT_SIZE * fontScale)

        local buildingTextWidth  = self._nameTxt:getContentSize().width + 25
        local buildingTextHeight = UIWorldNodeBanditDungeon.FONT_SIZE*1.7
        self._nameBg:setContentSize(buildingTextWidth, buildingTextHeight)

        self._flagImg:setPositionX(- self._nameBg:getContentSize().width / 2)
    end

    self._ccbSp:setScale(scale)
end


function UIWorldNodeBanditDungeon:onClickEvent()
    local x = self._worldTileInfo.x
    local y = self._worldTileInfo.y
    if self:isCanClick(x, y) then
        -- 有剿匪副本信息，执行剿匪逻辑
        if self._isBanditRest == true then
            self._mapPanel:showSysMessage(TextWords:getTextWord(351))
            return
        end
        self._mapPanel:onBanditDungeonBattleTouch(self._banditDungeon)
        return
    end
end

function UIWorldNodeBanditDungeon:getBg()
    return self._banditBg
end




