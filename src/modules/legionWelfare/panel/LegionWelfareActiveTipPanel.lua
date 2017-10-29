
LegionWelfareActiveTipPanel = class("LegionWelfareActiveTipPanel", BasicPanel)
LegionWelfareActiveTipPanel.NAME = "LegionWelfareActiveTipPanel"

function LegionWelfareActiveTipPanel:ctor(view, panelName)
    LegionWelfareActiveTipPanel.super.ctor(self, view, panelName, 700)
    
    self:setUseNewPanelBg(true)
end

function LegionWelfareActiveTipPanel:finalize()
    LegionWelfareActiveTipPanel.super.finalize(self)
end

function LegionWelfareActiveTipPanel:initPanel()
	LegionWelfareActiveTipPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3415))
end

function LegionWelfareActiveTipPanel:registerEvents()
	LegionWelfareActiveTipPanel.super.registerEvents(self)
	
    -- local closeBtn = self:getChildByName("mainPanel/Panel_listView/Button_close")
    -- self:addTouchEventListener(closeBtn,self.onCloseBtnTouch)
end
function LegionWelfareActiveTipPanel:onShowHandler(data)
    if self:isModuleRunAction() then
        return
    end

    LegionWelfareActiveTipPanel.super.onShowHandler(self)
    if self._listView ~= nil then
        -- self._listView:jumpToTop()
    end 
    --请求福利院信息
    self.view:dispatchEvent(LegionWelfareEvent.WELFARE_INFO_REQ,nil)
end 

function LegionWelfareActiveTipPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionWelfareActiveTipPanel:updateMenberActivity(data)
    local menberInfos = data
    if menberInfos == nil then menberInfos = {} end 
    table.sort(menberInfos,function(a,b) return a.activityrank < b.activityrank end )
    self:updateData(menberInfos)
end 
function LegionWelfareActiveTipPanel:updateData(data)
    local LabelTip = self:getChildByName("mainPanel/Panel_listView/Label_tip")
    LabelTip:setString(self:getTextWord(3409))
    local listView = self._listView
    if listView == nil then
        listView = self:getChildByName("mainPanel/Panel_listView/ListView")
        self._listView = listView
    end 
    self:renderListView(listView,data,self,self.renderItemPanel)
    listView:setItemsMargin(0)
end 
function LegionWelfareActiveTipPanel:renderItemPanel(itemPanel,info,index)
    local label1 = itemPanel:getChildByName("Label_1")   -- 排名
    local label2 = itemPanel:getChildByName("Label_2")   -- 角色名
    local label3 = itemPanel:getChildByName("Label_3")   -- 职务
    local label4 = itemPanel:getChildByName("Label_4")   -- 日活跃
    local itemBgImg1 = itemPanel:getChildByName("itemBgImg1") -- 卡片底图
    itemBgImg1:setVisible(index%2 == 0)
    local itemBgImg2 = itemPanel:getChildByName("itemBgImg2") -- 卡片底图
    itemBgImg2:setVisible(index%2 == 1)
    local rank   = info.activityrank
    local name   = info.name
    local job    = info.job
    local active = info.activityvalue 
    local jobNames = {}
    jobNames[7] = self:getTextWord(3410)
    jobNames[6] = self:getTextWord(3411)
    jobNames[5] = self:getTextWord(3412)
    local jobName = jobNames[job]
    if jobName == nil then jobName = jobNames[5] end
    
    label1:setString(rank)
    label2:setString(name)
    label3:setString(jobName)
    label4:setString(StringUtils:formatNumberByK3(active))
    
end 
-------回调函数-----

--关闭界面
function LegionWelfareActiveTipPanel:onCloseBtnTouch(sender)
    self:onClosePanelHandler()
end
function LegionWelfareActiveTipPanel:onClosePanelHandler()
    LegionWelfareActiveTipPanel.super.onClosePanelHandler(self)
    self:hide()
end