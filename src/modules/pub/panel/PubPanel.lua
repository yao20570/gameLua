
PubPanel = class("PubPanel", BasicPanel)
PubPanel.NAME = "PubPanel"

function PubPanel:ctor(view, panelName)
    PubPanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function PubPanel:finalize()
    PubPanel.super.finalize(self)
end

function PubPanel:initPanel()
	PubPanel.super.initPanel(self)
	self._tabControl = UITabControl.new(self,self.isUnlockLottery)
    self._tabControl:addTabPanel(PubNorPanel.NAME, self:getTextWord(366007))
    self._tabControl:addTabPanel(PubSpePanel.NAME, self:getTextWord(366008))
    self._tabControl:addTabPanel(PubShopPanel.NAME, self:getTextWord(366009))
    self._tabControl:setTabSelectByName(PubNorPanel.NAME)
    
    self:setTitle(true, "pub", true)
end


function PubPanel:onShowHandler()
    -- 设置标签页红点
    self:updateTabItemCount()
end


-- 切换标签判定，是否已开放酒馆盛宴
-- newPanelName : 切换到标签页
-- oldPanelName : 切换前标签页
function PubPanel:isUnlockLottery(newPanelName,oldPanelName)

	if PubSpePanel.NAME == newPanelName then
	    local pubProxy = self:getProxy(GameProxys.Pub)
	    local isLock = pubProxy:isUnlockSpePub(true)
	    if isLock == false then
	    	local panel = self:getPanel(PubSpePanel.NAME)
	    	if panel:isVisible() then
	    		panel:hide()
	    	end
	    end
	    return isLock
	end

	return true
end


function PubPanel:onClosePanelHandler()
	
    local panel = self:getPanel(PubNorPanel.NAME)
    panel:onClosePanelHandler()
    panel = self:getPanel(PubSpePanel.NAME)
    panel:onClosePanelHandler()

	self.view:hideModuleHandler()

end



function PubPanel:setFirstPanelShow(panelName)
	-- panelName = panelName or PubNorPanel.NAME
	-- self._tabControl:setTabSelectByName(panelName)
end

function PubPanel:setOldSelectIndex(index)
	index = index or 1
	self._tabControl:setOldSelectIndex(index)
end

-- 设置标签页红点
function PubPanel:updateTabItemCount()
    local pubProxy = self:getProxy(GameProxys.Pub)
    local roleProxy = self:getProxy(GameProxys.Role) 
    local count01 = pubProxy:getNorItemCount()
    local count02 = pubProxy:getSpeItemCount()
    -- 免费次数，现在只有小宴有免费
    local freeNum = pubProxy:getPubFreeData(1)
    count01 = count01 + freeNum

    self._tabControl:setItemCount(1, true, count01)
    
    logger:info("===|||刷新酒馆标签页的红点")

    local isSpeUnlock = roleProxy:isFunctionUnLock(9, false) -- 神点兵是否开放
    if isSpeUnlock then
        self._tabControl:setItemCount(2, true, count02)
    end
end