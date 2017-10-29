-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-18
--  * @Description: 限时活动_同盟致富_任务奖励预览弹窗
--  */
LegionRichTaskRewardPanel = class("LegionRichTaskRewardPanel")

function LegionRichTaskRewardPanel:ctor(parent, panel)
    local uiSkin = UISkin.new("LegionRichTaskRewardPanel")
    local winSize = cc.Director:getInstance():getWinSize()
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    layout:setPosition(winSize.width/2, winSize.height/2)
    parent:addChild(layout)
    local secLvBg = UISecLvPanelBg.new(layout, self)
    secLvBg:setBackGroundColorOpacity(120)
    secLvBg:setContentHeight(400)
    uiSkin:setParent(parent)
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel
    self.secLvBg = secLvBg
    self:initUi()
    self:initEvent()
    self.secLvBg:hideCloseBtn(true)
end

function LegionRichTaskRewardPanel:initUi()
    self.secLvBg:setTitle(TextWords:getTextWord(394015))
    self.ListView_1 = self:getChildByName("mainPanel/ListView_1")
    self.bgImg = self:getChildByName("mainPanel/bgImg")
    self.sureBtn = self:getChildByName("mainPanel/sureBtn")
    self.mainPanel = self:getChildByName("mainPanel")
end

function LegionRichTaskRewardPanel:initEvent()
    local closebtn = self.secLvBg:getCloseBtn()
    closebtn:setVisible(false)
    ComponentUtils:addTouchEventListener(self.sureBtn, self.onSureBtnTouch, nil, self)
    ComponentUtils:addTouchEventListener(self.mainPanel, self.hide, nil, self)
end

function LegionRichTaskRewardPanel:onSureBtnTouch(sender)
	print("-----------------onSureBtnTouch")
    -- logger:info("sender.ID %d",sender.ID)
    if type(self.callfunc) == "function" then
        self.callfunc()
    end
    self:hide()   
end

function LegionRichTaskRewardPanel:hide()
    self._uiSkin:setVisible(false)
    self._parent:setVisible(false)
end

function LegionRichTaskRewardPanel:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function LegionRichTaskRewardPanel:updateInfos(state,id,callback)
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

function LegionRichTaskRewardPanel:updateGoods(id)

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

