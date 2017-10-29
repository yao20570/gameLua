-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
-- LegionTaskRewarShowPanel = class("LegionTaskRewarShowPanel", BasicPanel)
-- LegionTaskRewarShowPanel.NAME = "LegionTaskRewarShowPanel"

-- function LegionTaskRewarShowPanel:ctor(view, panelName)
--     LegionTaskRewarShowPanel.super.ctor(self, view, panelName)

-- end

-- function LegionTaskRewarShowPanel:finalize()
--     LegionTaskRewarShowPanel.super.finalize(self)
-- end

-- function LegionTaskRewarShowPanel:initPanel()
-- 	LegionTaskRewarShowPanel.super.initPanel(self)
-- end

-- function LegionTaskRewarShowPanel:registerEvents()
-- 	LegionTaskRewarShowPanel.super.registerEvents(self)
-- end


-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-18
--  * @Description: 限时活动_同盟致富_任务奖励预览弹窗
--  */
LegionTaskRewarShowPanel = class("LegionTaskRewarShowPanel")

function LegionTaskRewarShowPanel:ctor(parent, panel)
    local uiSkin = UISkin.new("LegionTaskRewarShowPanel")
    local winSize = cc.Director:getInstance():getWinSize()
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    layout:setPosition(winSize.width/2, winSize.height/2)
    parent:addChild(layout)
    layout:setLocalZOrder(3)
    local secLvBg = UISecLvPanelBg.new(layout, self)
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setContentHeight(400)
    uiSkin:setParent(parent)
    uiSkin:setLocalZOrder(4)
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel
    self.secLvBg = secLvBg
    self:initUi()
    self:initEvent()
    self.secLvBg:hideCloseBtn(true)
end

function LegionTaskRewarShowPanel:initUi()
    self.secLvBg:setTitle(TextWords:getTextWord(394015))
    self.ListView_1 = self:getChildByName("mainPanel/ListView_1")
    self.bgImg = self:getChildByName("mainPanel/bgImg")
    self.sureBtn = self:getChildByName("mainPanel/sureBtn")
    self.mainPanel = self:getChildByName("mainPanel")
end

function LegionTaskRewarShowPanel:initEvent()
    local closebtn = self.secLvBg:getCloseBtn()
    closebtn:setVisible(false)
    ComponentUtils:addTouchEventListener(self.sureBtn, self.onSureBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(self.mainPanel, self.hide, nil, self)
end

function LegionTaskRewarShowPanel:onSureBtnTouch(sender)
	print("-----------------onSureBtnTouch")
    -- logger:info("sender.ID %d",sender.ID)
    if type(self.callfunc) == "function" then
        self.callfunc()
    end
    self:hide()   
end

function LegionTaskRewarShowPanel:hide()
    self._uiSkin:setVisible(false)
    self._parent:setVisible(false)
end

function LegionTaskRewarShowPanel:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function LegionTaskRewarShowPanel:updateInfos(state,id,callback)
	--state三种状态 1已完成并有可以领取的奖励,2已完成并已领取完奖励,3未完成任务
    self.callfunc = callback
    self._uiSkin:setVisible(true)
    self._parent:setVisible(true)   
    self:updateGoods(id)
    self.state = state
    if self.state == 1 then
    	self.sureBtn:setTitleText(TextWords:getTextWord(394007))
    	NodeUtils:setEnable(self.sureBtn, true)  
    elseif self.state == 2 then
    	self.sureBtn:setTitleText(TextWords:getTextWord(394008))
    	NodeUtils:setEnable(self.sureBtn, false)  
    elseif self.state == 3 then
    	self.sureBtn:setTitleText(TextWords:getTextWord(394007))
    	NodeUtils:setEnable(self.sureBtn, false)  
    end
end

function LegionTaskRewarShowPanel:updateGoods(id)

    local config = ConfigDataManager:getConfigById(ConfigData.LegionRichMissionConfig, id)

    local rewardItem = StringUtils:jsonDecode(config.reward)
    local datas = {}
    for i,v in ipairs(rewardItem) do
        local data = {}
        data.power = v[1]
        data.typeid = v[2]
        data.num = v[3]
        table.insert(datas,data)
    end

    ComponentUtils:renderAllGoods(self.ListView_1,self.bgImg, self.secLvBg, self.sureBtn,datas, self._panel)
end

function LegionTaskRewarShowPanel:updateInfos_Ex(rewardId,positionID,callback) --拓展到同盟任务
    self.callback = callback

    self.secLvBg:setTitle(TextWords:getTextWord(560203))
    self.sureBtn:setTitleText(TextWords:getTextWord(100))
    NodeUtils:setEnable(self.sureBtn, true)
    ComponentUtils:addTouchEventListener(self.sureBtn, self.onSureBtnTouch, nil, self)

    self:updateGoods_Ex(rewardId,positionID)
end

function LegionTaskRewarShowPanel:updateGoods_Ex(rewardID,positionID)
    local configInfo = ConfigDataManager:getInfoFindByTwoKey("LegionTaskSalaryConfig", "rewardID", rewardID, "positionID",positionID)
    if configInfo then 
        local rewardItem = StringUtils:jsonDecode(configInfo.reward)
        local salary = StringUtils:jsonDecode(configInfo.salary)
        local datas = {}

        if salary[1] then
        	local data = {}
            data.power = salary[1]
            data.typeid = salary[2]
            data.num = salary[3]
            table.insert(datas,data)
        end 

        for i,v in ipairs(rewardItem) do
            if v[1] then
            	local data = {}
	            data.power = v[1]
	            data.typeid = v[2]
	            data.num = v[3]
	            table.insert(datas,data)
	        end 
        end
        if #datas > 0 then
        	self._uiSkin:setVisible(true)
    		self._parent:setVisible(true) 
        	ComponentUtils:renderAllGoods(self.ListView_1,self.bgImg, self.secLvBg, self.sureBtn,datas, self._panel)
        else
        	self:hide()
        end 
    end 
end





