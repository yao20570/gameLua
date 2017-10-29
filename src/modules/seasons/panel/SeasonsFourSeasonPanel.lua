-- /**
--  * @Author:
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 四季面板
--  */
SeasonsFourSeasonPanel = class("SeasonsFourSeasonPanel", BasicPanel)
SeasonsFourSeasonPanel.NAME = "SeasonsFourSeasonPanel"

function SeasonsFourSeasonPanel:ctor(view, panelName)
    SeasonsFourSeasonPanel.super.ctor(self, view, panelName)


    self._textWords = {
        self:getTextWord(500005),
        self:getTextWord(500006),
        self:getTextWord(500007),
        self:getTextWord(500008),
    }
end



function SeasonsFourSeasonPanel:finalize()
    SeasonsFourSeasonPanel.super.finalize(self)
end


function SeasonsFourSeasonPanel:doLayout()

end

function SeasonsFourSeasonPanel:initPanel()
    SeasonsFourSeasonPanel.super.initPanel(self)


    self._panel = self:getChildByName("Panel_1")

    self._imgBg = self._panel:getChildByName("imgBg")

    self._labSeasonKey = self._panel:getChildByName("labSeasonKey")
    self._labSeasonVal = self._panel:getChildByName("labSeasonVal")

    self._svBuff = self._panel:getChildByName("svBuff")
end

function SeasonsFourSeasonPanel:registerEvents()
    SeasonsFourSeasonPanel.super.registerEvents(self)
end


function SeasonsFourSeasonPanel:onShowHandler()
    self:updateView()
end

function SeasonsFourSeasonPanel:onHideHandler()
    SeasonsFourSeasonPanel.super.onHideHandler(self)
end

function SeasonsFourSeasonPanel:update(dt)
    self.restTime = self._proxy:getRemainTimeOfCurSeason()
    if self.restTime > 0 then
        self._labSeasonVal:setString(TimeUtils:getStandardFormatTimeString(self.restTime))
    else
        self._labSeasonVal:setString(TimeUtils:getStandardFormatTimeString(0))
        --self:requiredSeasonData()
    end
end

function SeasonsFourSeasonPanel:updateView()

    self._proxy = self:getProxy(GameProxys.Seasons)

    if self:isWorldSeasonOpen() then
        self._panel:setVisible(true)
        self:showScenery()

        self:update()
    end
end


function SeasonsFourSeasonPanel:showScenery()
    local BgPath = "res/bg/world/seasons/season_%d.pvr.ccz"
    TextureManager:updateImageViewFile(self._imgBg, string.format(BgPath, self._proxy:getCurSeason()))

    local seasonID = self._proxy:getNextSeason()
    local str = string.format(self:getTextWord(500009), self._textWords[seasonID])
    self._labSeasonKey:setString(str)


    -- 季节加成效果
    local season_conf = ConfigDataManager:getInfoFindByOneKey(ConfigData.WorldSeasonConfig, "type", self._proxy:getCurSeason())
    local des = string.gsub(season_conf.info, "\"", "'")
    des = StringUtils:toTable(des)
    self:renderScrollView(self._svBuff, "item", des, self, self.rendercall)
end

function SeasonsFourSeasonPanel:rendercall(item, data, index)
    local labKey = item:getChildByName("labKey1")
    local labVal = item:getChildByName("labVal1")

    labKey:setString(data[1])
    labVal:setString(data[2])
    NodeUtils:alignNodeL2R(labKey, labVal)
end

-- 判断四季是否开放
function SeasonsFourSeasonPanel:isWorldSeasonOpen()
    return self._proxy:isWorldSeasonOpen()
end


--function SeasonsFourSeasonPanel:requiredSeasonData()
--    -- 向服务器请求刷新季节数据
--    self._proxy:onTriggerNet480002Req()
--end



