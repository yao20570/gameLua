-- 军团活跃
LegionWelfareActivePanel = class("LegionWelfareActivePanel", BasicPanel)
LegionWelfareActivePanel.NAME = "LegionWelfareActivePanel"

function LegionWelfareActivePanel:ctor(view, panelName)
    LegionWelfareActivePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionWelfareActivePanel:finalize()
    LegionWelfareActivePanel.super.finalize(self)
end

function LegionWelfareActivePanel:initPanel()
	LegionWelfareActivePanel.super.initPanel(self)
end

function LegionWelfareActivePanel:doLayout()
    local mainPanel = self:getChildByName("mainPanel")
    local ListView = self:getChildByName("ListView")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(mainPanel, ListView, GlobalConfig.downHeight, tabsPanel,GlobalConfig.downHeight)
end

function LegionWelfareActivePanel:registerEvents()
	LegionWelfareActivePanel.super.registerEvents(self)
	
	local tipBtn = self:getChildByName("mainPanel/Panel_top/Button_tip")
    tipBtn:setVisible(false)
	local rankBtn = self:getChildByName("mainPanel/Panel_next/Panel_2/Button_rank")
    local getResBtn = self:getChildByName("mainPanel/Panel_next/Panel_2/Button_getRes")
    local rewardResBtn = self:getChildByName("mainPanel/Panel_next/Panel_2/Button_rewardRes")
    
    self._getResBtn = getResBtn
    self._rewardResBtn = rewardResBtn
    self._getResBtn:setVisible(true)
    self._rewardResBtn:setVisible(false)

    -- self:addTouchEventListener(tipBtn,self.onTipBtnTouch)
    self:addTouchEventListener(rankBtn,self.onRankBtnTouch)
    self:addTouchEventListener(getResBtn,self.onGetResBtnTouch)
    self:addTouchEventListener(rewardResBtn,self.onRewardResBtnTouch)
end
function LegionWelfareActivePanel:onShowHandler(data)
    if self:isModuleRunAction() then
        return
    end

    LegionWelfareActivePanel.super.onShowHandler(self)
    --请求福利院信息
    self.view:dispatchEvent(LegionWelfareEvent.WELFARE_INFO_REQ,nil)
end

function LegionWelfareActivePanel:onAfterActionHandler()
    self:onShowHandler()
end

--更新数据
function LegionWelfareActivePanel:updateData(data)
    if data.activityLv ~= nil then
        print("更新数据 data.activityLv="..data.activityLv)
    end

    self._data = data
    self:updateTopPanel()
    -- self:updateDescPanel()
    self:updateResPanel()
    self:updateListView()
    
end

--领取资源成功
function LegionWelfareActivePanel:onResourceGetResp()
    --可领取置0、更改已领取
    self._data.hasgetfood  = self._data.hasgetfood  + self._data.cangetfood
    self._data.hasgetiron  = self._data.hasgetiron  + self._data.cangetiron
    self._data.hasgetstone = self._data.hasgetstone + self._data.cangetstone
    self._data.hasgetwood  = self._data.hasgetwood  + self._data.cangetwood
    self._data.hasgettael  = self._data.hasgettael  + self._data.cangettael
    
    self._data.cangetfood  = 0
    self._data.cangetiron  = 0
    self._data.cangetstone = 0
    self._data.cangetwood  = 0
    self._data.cangettael  = 0
    
    self:updateResPanel()
end

--更新等级，进度
function LegionWelfareActivePanel:updateTopPanel()
    local labelLv  = self:getChildByName("mainPanel/Panel_top/Label_level")
    local labelExp = self:getChildByName("mainPanel/Panel_top/Label_exp")
    local proBar   = self:getChildByName("mainPanel/Panel_top/ProgressBar")
    local data = self._data
    
    local level = data.activityLv
    local configData = self:getActiveConfigDataByLv(level)
    local lvStr = "Lv."..level
    local curExp = data.activityValue
    local needExp = configData.activeneed
    local expStr = curExp .."/".. needExp
    local percent = curExp/needExp*100
    labelLv:setString(lvStr)
    labelExp:setString(expStr)
    proBar:setPercent(percent)

end 

--更新说明信息
-- function LegionWelfareActivePanel:updateDescPanel()
--     local labelDesc = self:getChildByName("mainPanel/Panel_next/Panel_1/Label_desc")
--     local data = self._data
--     local level = data.activityLv
--     -- local str1 = self:getTextWord(3405)
--     -- local titleStr  = string.format(str1,level)
--     local configData = self:getActiveConfigDataByLv(level)
--     local tempStr = configData.info
--     labelDesc:setString(tempStr)
-- end

--更新资源数据
function LegionWelfareActivePanel:updateResPanel()
    self:updateEnableGetRes()
    self:updateHaveGotRes()
end

function LegionWelfareActivePanel:updateEnableGetRes()
    local label1 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_21/Label_1")
    local label2 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_21/Label_2")
    local label3 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_21/Label_3")
    local label4 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_21/Label_4")
    local label5 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_21/Label_5")

    local data = self._data
    local num1 = data.cangettael --银两
    local num2 = data.cangetiron --石油-铁锭
    local num3 = data.cangetstone--石头
    local num4 = data.cangetwood --木材
    local num5 = data.cangetfood --食物

    local temp = num1 + num2 + num3 +num4 +num5

    if temp > 0 then
        -- 可领取
        self._rewardResBtn.tag = 1
        self._getResBtn:setVisible(false)
        self._rewardResBtn:setVisible(true)
    else
        -- 可采集
        self._getResBtn.tag = 1
        self._getResBtn:setVisible(true)
        self._rewardResBtn:setVisible(false)
    end 

    local numStr1 = StringUtils:formatNumberByK3(num1)
    local numStr2 = StringUtils:formatNumberByK3(num2)
    local numStr3 = StringUtils:formatNumberByK3(num3)
    local numStr4 = StringUtils:formatNumberByK3(num4)
    local numStr5 = StringUtils:formatNumberByK3(num5)
    label1:setString(numStr1)
    label2:setString(numStr2)
    label3:setString(numStr3)
    label4:setString(numStr4)
    label5:setString(numStr5)
end 

function LegionWelfareActivePanel:updateHaveGotRes()
    local label1 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_22/Label_1")
    local label2 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_22/Label_2")
    local label3 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_22/Label_3")
    local label4 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_22/Label_4")
    local label5 = self:getChildByName("mainPanel/Panel_next/Panel_2/Panel_22/Label_5")
    local data = self._data

    local num1 = data.hasgettael --银两
    local num2 = data.hasgetiron --石油-铁锭
    local num3 = data.hasgetstone--石头
    local num4 = data.hasgetwood --木材
    local num5 = data.hasgetfood --食物


    local numStr1 = StringUtils:formatNumberByK3(num1)
    local numStr2 = StringUtils:formatNumberByK3(num2)
    local numStr3 = StringUtils:formatNumberByK3(num3)
    local numStr4 = StringUtils:formatNumberByK3(num4)
    local numStr5 = StringUtils:formatNumberByK3(num5)
    label1:setString(numStr1)
    label2:setString(numStr2)
    label3:setString(numStr3)
    label4:setString(numStr4)
    label5:setString(numStr5)
end 

--更新listView
function LegionWelfareActivePanel:updateListView()
    self._listServerData = {}
    local data = self._data
    self._listServerData[1] = data.type1
    self._listServerData[2] = data.type2
    self._listServerData[3] = data.type3
    self._listServerData[4] = data.type4
    self._listServerData[5] = data.type5
    local listView = self._listView
    local configData = self._activeConfigData
    if listView == nil then
        listView = self:getChildByName("ListView")
        configData  = ConfigDataManager:getConfigData(ConfigData.LegActMissionConfig)
        self._listView = listView
        self._activeConfigData = configData
    end 
    local tmpData = {}
    for _,v in pairs(configData) do
        table.insert(tmpData,v)
    end
    self:renderListView(listView,tmpData,self,self.renderItemPanel,nil,nil,GlobalConfig.listViewRowSpace)
end

function LegionWelfareActivePanel:renderItemPanel(itemPanel,info)
    if itemPanel == nil or info == nil then
        logger:error("军团活跃:renderItemPanel  >> itemPanel == nil or info == nil")
        return
    end
    
    local labelTitle = itemPanel:getChildByName("Label_title")
    local label1 = itemPanel:getChildByName("Label_num_1")
    local label2 = itemPanel:getChildByName("Label_num_2")
    local label3 = itemPanel:getChildByName("Label_num_3")


    
    local type = info.ID
    local title = info.name
    local addNum = info.reward
    local getNum = self._listServerData[type] 
    local maxNum = info.max
    local str1 = "+"..addNum
    -- local str2 = getNum .."/".. maxNum
    
    labelTitle:setString(title)
    label1:setString(str1)
    label2:setString(getNum)
    label3:setString("/".. maxNum)
    NodeUtils:alignNodeL2R(label2,label3)

    -- icon
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = info.icon
    iconInfo.num = 0

    local icon = itemPanel.icon
    if icon == nil then
        local Image_icon = itemPanel:getChildByName("Image_icon")
        icon = UIIcon.new(Image_icon,iconInfo,false)        
        itemPanel.icon = icon
    else
        icon:updateData(iconInfo)
    end
end 

--获取配置表数据
function LegionWelfareActivePanel:getActiveConfigDataByLv(level)
    local configData = self._configData
    if configData == nil then
        configData = ConfigDataManager:getConfigData(ConfigData.LegionActiveConfig)
        self._configData = configData
    end 
    for _,v in pairs(configData) do
        if v.level == level then
            return v
        end 
    end 
end 
-----------------回调函数定义--------------

--军团活跃提示信息
-- function LegionWelfareActivePanel:onTipBtnTouch(sender)
--     SDKManager:showWebHtmlView("html/legion_active.html")
-- end 
--活跃榜
function LegionWelfareActivePanel:onRankBtnTouch(sender)
    local panel = self:getPanel(LegionWelfareActiveTipPanel.NAME)
    panel:show()
end 

-- --采集
-- function LegionWelfareActivePanel:onGetResBtnTouch(sender)
--     print("tag ===",sender.tag)
--     local tag = sender.tag
--     if tag == 1 then --采集资源
--         local moduleName =  ModuleName.MapModule
--         self.view:dispatchEvent(LegionWelfareEvent.SHOW_OTHER_EVENT,moduleName)
--         self.view:dispatchEvent(LegionWelfareEvent.HIDE_SELF_EVENT,nil)
--     else --领取资源
--         self.view:dispatchEvent(LegionWelfareEvent.GET_RESOURCE_REQ,nil)
--     end 
-- end


--采集
function LegionWelfareActivePanel:onGetResBtnTouch(sender)
    print("采集 tag ===",sender.tag)
    local tag = sender.tag
    if tag == 1 then --采集资源
        local moduleName =  ModuleName.MapModule
        self.view:dispatchEvent(LegionWelfareEvent.SHOW_OTHER_EVENT,moduleName)
        self.view:dispatchEvent(LegionWelfareEvent.HIDE_SELF_EVENT,nil)
    end 
end

--领取
function LegionWelfareActivePanel:onRewardResBtnTouch(sender)
    print("领取 tag ===",sender.tag)
    local tag = sender.tag
    if tag == 1 then --领取资源
        self.view:dispatchEvent(LegionWelfareEvent.GET_RESOURCE_REQ,nil)
    end 
end 