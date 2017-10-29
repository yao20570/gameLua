-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description:
--  */
SeasonsWorldLevel = class("SeasonsWorldLevel", BasicPanel)
SeasonsWorldLevel.NAME = "SeasonsWorldLevel"

function SeasonsWorldLevel:ctor(view, panelName)
    SeasonsWorldLevel.super.ctor(self, view, panelName)

end


function SeasonsWorldLevel:finalize()
    SeasonsWorldLevel.super.finalize(self)
end

function SeasonsWorldLevel:doLayout()

end

function SeasonsWorldLevel:initPanel()
    SeasonsWorldLevel.super.initPanel(self)


    self.panel = self:getChildByName("Panel_3")

    self._pnl1 = self.panel:getChildByName("pnl1")

    self._pnl2 = self.panel:getChildByName("pnl2")

    self._pnl3 = self.panel:getChildByName("pnl3")

    -- 1
    self.labWorldLvVal1 = self._pnl1:getChildByName("labWorldLvVal1")

    self.labMyLvVal1 = self._pnl1:getChildByName("labMyLvVal1")
    self.labMyLvVal2 = self._pnl1:getChildByName("labMyLvVal2")

    self.labLvLimVal1 = self._pnl1:getChildByName("labLvLimVal1")
    self.labLvLimVal2 = self._pnl1:getChildByName("labLvLimVal2")

    -- 2
    self.pnlEff = { }
    for i = 1, 3 do
        self.pnlEff[i] = self._pnl2:getChildByName("pnlEff" .. i)
        self.pnlEff[i].labKey1 = self.pnlEff[i]:getChildByName("labKey1")
        self.pnlEff[i].labVal11 = self.pnlEff[i]:getChildByName("labVal11")
        self.pnlEff[i].labVal12 = self.pnlEff[i]:getChildByName("labVal12")
    end

    self.pnlClosed = self.panel:getChildByName("pnlClosed")
    self.labOpenMsg = self.pnlClosed:getChildByName("labTitle1")
    -- 3
    self:updateRegulationTxt()
end

function SeasonsWorldLevel:updateRegulationTxt()
    self._labRegulation = self._pnl3:getChildByName("labRegulation")
    local richLabel = self._labRegulation.richLabel
    if richLabel == nil then
        richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self._labRegulation:addChild(richLabel)
        self._labRegulation.richLabel = richLabel
    end
    self._labRegulation:setString("")

    
    local worldLevelOpenCfg = ConfigDataManager:getConfigById(ConfigData.WorldLevelOpen, 1)
    local num = worldLevelOpenCfg.levelNumLimited
    local infoStr = {
        {{string.format(self:getTextWord(500021), num), 20, ColorUtils.commonColor.MiaoShu}},
        {{self:getTextWord(500022), 20, ColorUtils.commonColor.MiaoShu}},
        {{self:getTextWord(500023), 20, ColorUtils.commonColor.MiaoShu}},
        {{self:getTextWord(500024), 20, ColorUtils.commonColor.MiaoShu}},
        }
    richLabel:setString(infoStr)

end

function SeasonsWorldLevel:registerEvents()
    SeasonsWorldLevel.super.registerEvents(self)
end

function SeasonsWorldLevel:onShowHandler()
    self:updateView()
end

function SeasonsWorldLevel:onHideHandler()
end

function SeasonsWorldLevel:update(dt)
    self.restTime = self._proxy:getRemainTimeOfOpenNextWorld()
    if self.restTime > 0 then
        self:setRemainTime(self.restTime)
    else
        self:setRemainTime(0)
    end
end

function SeasonsWorldLevel:updateView()
    
    self._proxy = self:getProxy(GameProxys.Seasons)

    if self._proxy:isWorldLevelOpen() then

        self._roleProxy = self:getProxy(GameProxys.Role)
        -- self:getRoleAttrValue(PlayerPowerDefine.POWER_level)

        self.labWorldLvVal1:setString(self._proxy:getWorldLevel())

        local playerLevel = self._roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
        self.labMyLvVal1:setString(tostring(playerLevel))

        -- 我与世界的经验差
        local diff = playerLevel - self._proxy:getWorldLevel()
        local seasonConf = ConfigDataManager:getInfoFindByFunc(ConfigData.WorldExpConfig, function(conf)
            local ary = StringUtils:jsonDecode(conf.levelValue)
            return  ary[1] <= diff and diff <= ary[2]
        end )

        if seasonConf then
            local ary = StringUtils:jsonDecode(seasonConf.expAdd)            
            local power = ary[1] 
            local itemID = ary[2] 
            local number = ary[3] 
            -- 与世界的等级差,经验加成
            local item = ConfigDataManager:getConfigByPowerAndID(power, itemID)
            self.labMyLvVal2:setString(string.format(self:getTextWord(500010), item.name, number))
            NodeUtils:alignNodeL2R(self.labMyLvVal1, self.labMyLvVal2, 5)
        else
            logger:error("找不到配置表,世界与我的等级差:" .. diff)
        end

        -- 世界等级上限
        self.labLvLimVal1:setString(self._proxy:getWorldPlayerLevelLimit())

        -- 更新时间
        self:update()

        -------------------------世界等级效果--------------------------------

        local conf = ConfigDataManager:getInfoFindByFunc(ConfigData.WorldLevelConfig, function(conf)
            local ary = StringUtils:jsonDecode(conf.worldLevel)
            local curWorldLevel = self._proxy:getWorldLevel()
            return ary[1] <= curWorldLevel and curWorldLevel <= ary[2]
        end)

        local nextConf = ConfigDataManager:getInfoFindByFunc(ConfigData.WorldLevelConfig, function(conf)
            local ary = StringUtils:jsonDecode(conf.worldLevel)
            local nextWorldLevel = self._proxy:getWorldLevel() + 1
            return ary[1] <= nextWorldLevel and nextWorldLevel <= ary[2]
        end)
        -- 乱军行军
        self.pnlEff[1].labVal11:setString(conf.goSpeed / 100 .. "%")
        self.pnlEff[1].labVal12:setString(string.format(self:getTextWord(500011), nextConf.goSpeed / 100))
        NodeUtils:alignNodeL2R(self.pnlEff[1].labKey1, self.pnlEff[1].labVal11, self.pnlEff[1].labVal12)
        -- 繁荣恢复 TODO 配置表是世界战损?????? 用战损
        -- 用战损
        self.pnlEff[2].labVal11:setString(conf.worldLose / 100 .. "%")
        self.pnlEff[2].labVal12:setString(string.format(self:getTextWord(500011), nextConf.worldLose / 100))
        NodeUtils:alignNodeL2R(self.pnlEff[2].labKey1, self.pnlEff[2].labVal11, self.pnlEff[2].labVal12)
        
        -- 资源优惠
        local curCoupon = conf.resCoupon / 1000
        local nextCoupon = nextConf.resCoupon / 1000
        local str1 = curCoupon .. self:getTextWord(500016)
        local str2 = string.format(self:getTextWord(500017), nextCoupon)
        if curCoupon >= 10 then
            str1 = self:getTextWord(500018)
        end
        if nextCoupon >= 10 then
            str2 = self:getTextWord(500019)
        end

        self.pnlEff[3].labKey1:setString(self:getTextWord(500015))
        self.pnlEff[3].labVal11:setString(str1)
        self.pnlEff[3].labVal12:setString(str2)
        NodeUtils:alignNodeL2R(self.pnlEff[3].labKey1, self.pnlEff[3].labVal11, self.pnlEff[3].labVal12)

        self.labMyLvVal2:setVisible(true)
        self._pnl2:setVisible(true)

        self.pnlClosed:setVisible(false)
    else
        -- 未开放
        self.labWorldLvVal1:setString("?")
        self.labMyLvVal1:setString("?")
        self.labMyLvVal2:setVisible(false)
        self.labLvLimVal1:setString("?")
        ------------------------------------------------
        self._pnl2:setVisible(false)

        self.pnlClosed:setVisible(true)
        -- 读配置表 第一个就是了
        local WorldLevelOpenConfig = ConfigDataManager:getConfigById(ConfigData.WorldLevelOpen, 1)
        --local day = TimeUtils:getStandardFormatTimeString3(WorldLevelOpenConfig.serverOpenDay)
        self.labOpenMsg:setString(string.format(self:getTextWord(500014), WorldLevelOpenConfig.serverOpenDay))
    end
end

function SeasonsWorldLevel:setRemainTime(time)
    if time == 0 then
        self.labLvLimVal2:setVisible(false)
    else
        self.labLvLimVal2:setVisible(true)

        local nextPlayerLevelLimit = self._proxy:getNextWorldPlayerLevelLimit()
        local str = string.format(self:getTextWord(500012), TimeUtils:getStandardFormatTimeString(time), nextPlayerLevelLimit)
        self.labLvLimVal2:setString(str)

        NodeUtils:alignNodeL2R(self.labLvLimVal1, self.labLvLimVal2, 5)
    end
end
