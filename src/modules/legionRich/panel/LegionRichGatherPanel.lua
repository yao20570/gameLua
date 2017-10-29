-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-09
--  * @Description: 限时活动_同盟致富_采集分页
--  */
LegionRichGatherPanel = class("LegionRichGatherPanel", BasicPanel)
LegionRichGatherPanel.NAME = "LegionRichGatherPanel"

function LegionRichGatherPanel:ctor(view, panelName)
    LegionRichGatherPanel.super.ctor(self, view, panelName)
    require("modules.legionRich.panel.LegionRichTaskRewardPanel")

end

function LegionRichGatherPanel:finalize()
    LegionRichGatherPanel.super.finalize(self)
end

function LegionRichGatherPanel:initPanel()
	LegionRichGatherPanel.super.initPanel(self)
	self.listview = self:getChildByName("ListView")
	self.proxy = self:getProxy(GameProxys.Activity)
	local descLab = self:getChildByName("topPanel/descLab")
	descLab:setString(self:getTextWord(394004))
    descLab:setColor(cc.c3b(244,244,244))
end

function LegionRichGatherPanel:registerEvents()
	LegionRichGatherPanel.super.registerEvents(self)
	local goBtn = self:getChildByName("bottomPanel/goBtn")
	self:addTouchEventListener(goBtn, self.onGoBtnHandler)
end
function LegionRichGatherPanel:doLayout()
    local topPanel = self:getChildByName("topPanel")
    local bottomPanel = self:getChildByName("bottomPanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel, self.listview, bottomPanel, tabsPanel, 20)
end
function LegionRichGatherPanel:onShowHandler()
	if self.proxy == nil then
 		self.proxy = self:getProxy(GameProxys.Activity)
	end
	local sendData = {}
	sendData.activityId = self.proxy:getCurActivityData().activityId
	self.proxy:onTriggerNet230056Req(sendData)
end
function LegionRichGatherPanel:updateLegionRichGatherView()
	self.myData = self.proxy:getCurActivityData()
	local legionRichInfo = self.proxy:getLegionRichInfoById(self.myData.activityId)
	if legionRichInfo == nil then
		return
	end
	local timeLab = self:getChildByName("topPanel/timeLab")
	timeLab:setString(TimeUtils.getLimitActFormatTimeString(self.myData.startTime,self.myData.endTime,true))
	self:renderListView(self.listview, legionRichInfo.missionInfos, self, self.renderItemPanel, false)
end
function LegionRichGatherPanel:renderItemPanel(item, itemInfo, index)

	local config = ConfigDataManager:getConfigById(ConfigData.LegionRichMissionConfig, itemInfo.id)
	local itemBtn = item:getChildByName("itemBtn")
	itemBtn.id = itemInfo.id
	self:addTouchEventListener(itemBtn, self.onDetailBtnHandler)
	local nameLab = itemBtn:getChildByName("nameLab")
	local iconImg = itemBtn:getChildByName("iconImg")
	local btn = itemBtn:getChildByName("btn")
	local progressBarImg = itemBtn:getChildByName("progressBarImg")
	local progressBar = progressBarImg:getChildByName("progressBar")
	local curNumLab = progressBarImg:getChildByName("curNumLab")
	local targetNumLab = progressBarImg:getChildByName("targetNumLab")
	local redPointImg = itemBtn:getChildByName("redPointImg")
	local redPointNumLab = redPointImg:getChildByName("num")
	

	nameLab:setString(config.missonName)
	local arr = StringUtils:jsonDecode(config.missionContent)
	--大于满值
	if itemInfo.gather > tonumber(arr[2]) then
		curNumLab:setString( StringUtils:formatNumberByK3(tonumber(arr[2])) )
	else
		curNumLab:setString( StringUtils:formatNumberByK3(itemInfo.gather) )
	end
	targetNumLab:setString("/" .. StringUtils:formatNumberByK3(arr[2]) )
	local color = itemInfo.gather >= tonumber(arr[2]) and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)
	curNumLab:setColor(color)
	--居中处理
	curNumLab:setPositionX(progressBarImg:getContentSize().width/2-(curNumLab:getContentSize().width + targetNumLab:getContentSize().width)/2)
	local x = curNumLab:getPosition()
	targetNumLab:setPositionX(x + curNumLab:getContentSize().width)
	local per = itemInfo.gather / tonumber(arr[2]) * 100
	per = per < 0 and 0 or per
	per = per > 100 and 100 or per
	progressBar:setPercent(per)

	local iconInfo = {}
    iconInfo.power = GamePowerConfig.Resource
    iconInfo.typeid = arr[1]
    iconInfo.num = 0
    local icon = item.icon
    if icon == nil then
        icon = UIIcon.new(iconImg,iconInfo,false)
        item.icon = icon
    else
        icon:updateData(iconInfo)
    end

    --任务中有百分百的进度证明有奖励可以领取
    if per == 100 and itemInfo.remainTimes > 0 then
    	--已完成并有可以领取的奖励
    	btn:setTitleText(self:getTextWord(394016))
   	elseif per == 100 and itemInfo.remainTimes == 0 then
   		--已完成并已领取完奖励
   		btn:setTitleText(self:getTextWord(394008))
   	else
   		--未完成任务
   		btn:setTitleText(self:getTextWord(394016))
    end
    redPointImg:setVisible(itemInfo.remainTimes > 0)
    redPointNumLab:setString(itemInfo.remainTimes)



    	
	btn.itemInfo = itemInfo
	btn.per = per
	self:addTouchEventListener(btn, self.onBtnHandler)

end

function LegionRichGatherPanel:onDetailBtnHandler(sender)
    local panel = self:getPanel(LegionRichDetailPanel.NAME)
	panel:show(sender.id) 
end

function LegionRichGatherPanel:onBtnHandler(sender)
	local remainTimes = sender.itemInfo.remainTimes
	local id = sender.itemInfo.id
	local per = sender.per

    if per == 100 and remainTimes > 0 then
		--已完成并有可以领取的奖励
		local function callback()
			local sendData = {}
			sendData.activityId = self.myData.activityId
			sendData.id = id
			self.proxy:onTriggerNet230053Req(sendData)
		end
		self:showTaskGoods(1,id,callback)
   	elseif per == 100 and remainTimes == 0 then
		--已完成并已领取完奖励
		local function callback()
			local sendData = {}
			sendData.activityId = self.myData.activityId
			sendData.id = id
			self.proxy:onTriggerNet230053Req(sendData)
		end
		self:showTaskGoods(2,id,callback)
	
   	else
		local function callback()
			--未完成任务
			self.proxy:goToWorldAndClose()
		end
		self:showTaskGoods(3,id,callback)

    end

end

function LegionRichGatherPanel:showTaskGoods(state,id,callback)
    if not self.LegionRichTaskRewardPanel then
        local parent = self:getParent()
        self.LegionRichTaskRewardPanel = LegionRichTaskRewardPanel.new(parent, self)
    end
    self.LegionRichTaskRewardPanel:updateInfos(state,id,callback)
end

function LegionRichGatherPanel:onGoBtnHandler(sender)
	self.proxy:goToWorldAndClose()
end
