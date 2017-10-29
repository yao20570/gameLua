-- /**
--  * @Author:    luzhuojian
--  * @DateTime:    2017-01-06
--  * @Description: 限时活动 煮酒论英雄
--  */
CookingWinePanel = class("CookingWinePanel", BasicPanel)
CookingWinePanel.NAME = "CookingWinePanel"

function CookingWinePanel:ctor(view, panelName)
    CookingWinePanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function CookingWinePanel:finalize()
    CookingWinePanel.super.finalize(self)
end

function CookingWinePanel:initPanel()
	CookingWinePanel.super.initPanel(self)
	self:addTabControl()
end
function CookingWinePanel:addTabControl()
    local function callback(panel, panelName, oldPanelName) 
        if panelName == CookingWineRankPanel.NAME then
	        --特效播放中
            local panel = self:getPanel(CookingWineMainPanel.NAME)
	        if panel.toasting == true then
	        	self:showSysMessage(self:getTextWord(420016))
	        	return false
	        end

            self._tabControl:setChainVisbale(false)
            self:setBgType(ModulePanelBgType.NONE)
        else
            self._tabControl:setChainVisbale(true)
            self._tabControl:isShow4Chain(true)
            self._tabControl:setChainPosition(83, 257, 403, 577)
            self:setBgType(ModulePanelBgType.COOKINGWINE)
        end
        return true
    end
    
	local proxy = self:getProxy(GameProxys.Activity)
    local isRank = proxy.curActivityData.rankId
    --local activityId= proxy.curActivityData.activityId
    --logger:info("煮酒论英雄"..proxy.curActivityData.info)

    self._tabControl = UITabControl.new(self, callback)
    self._tabControl:addTabPanel(CookingWineMainPanel.NAME, self:getTextWord(420000))
    if isRank ~= 0 then
        self._tabControl:addTabPanel(CookingWineRankPanel.NAME, self:getTextWord(420001))
    end
    self._tabControl:setTabSelectByName(CookingWineMainPanel.NAME)
    self._tabControl:setChainVisbale(true)
    self:setTitle(true, "enfeoffs", true) 
    self:setBgType(ModulePanelBgType.COOKINGWINE)
end
function CookingWinePanel:onClosePanelHandler()
    self.view:dispatchEvent(CookingWineEvent.HIDE_SELF_EVENT)
end
function CookingWinePanel:registerEvents()
	CookingWinePanel.super.registerEvents(self)
end
