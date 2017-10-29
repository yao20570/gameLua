
PartsStrengthenPanel = class("PartsStrengthenPanel", BasicPanel)
PartsStrengthenPanel.NAME = "PartsStrengthenPanel"

function PartsStrengthenPanel:ctor(view, panelName)
    ----
    PartsStrengthenPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function PartsStrengthenPanel:finalize()
    PartsStrengthenPanel.super.finalize(self)
end

function PartsStrengthenPanel:initPanel()
	PartsStrengthenPanel.super.initPanel(self)
	
	----
	self:addTabControl()
    self:setTitle(true,"parts",true) -- 设置标题
end

-----
function PartsStrengthenPanel:addTabControl()
    local function onTabItemClicked(self,name)
        return self:onTabItemClicked(name)
    end 
    self._tabControl = UITabControl.new(self,onTabItemClicked)
    self._tabControl:addTabPanel(PartsIntensifyPanel.NAME, self:getTextWord(8301)) -- 强化
    self._tabControl:addTabPanel(PartsRemouldPanel.NAME, self:getTextWord(8302)) -- 改造
    self._tabControl:addTabPanel(PartsEvolvePanel.NAME, self:getTextWord(8303)) -- 进阶
    self._tabControl:setTabSelectByName(PartsIntensifyPanel.NAME)

end

function PartsStrengthenPanel:onTabItemClicked(name)
    if self._data == nil then return true end 
    local configData = self._data.configData
    local parts = self._data.parts
    if name == PartsEvolvePanel.NAME then
        if  configData.isadvance == 0 then
            self:showSysMessage(self:getTextWord(8229))
            return false
        else
            if parts.remoulv < 4 or parts.quality ~= 4 then
                self:showSysMessage(self:getTextWord(8229))
                return false
            end
        end 
    end 
   
    return true
    
end 
--发送关闭系统消息
function PartsStrengthenPanel:onClosePanelHandler()
    EffectQueueManager:removeEffectByType(EffectQueueType.GET_REWARD)
    self.view:dispatchEvent(PartsStrengthenEvent.HIDE_SELF_EVENT)
end

--更新panel信息
function PartsStrengthenPanel:updatePanelInfo(extraMsg)
    self._data = extraMsg.data
    local index = extraMsg.index
    local itemName = PartsIntensifyPanel.NAME
    if index == 2 then
        itemName = PartsRemouldPanel.NAME
    elseif index == 3 then
        itemName = PartsEvolvePanel.NAME
    end 
    self:changeTabSelectByName(itemName)
end

function PartsStrengthenPanel:updateData(data)
    self._data = data
end

function PartsStrengthenPanel:getData()
    return self._data
end 