--region LegionCapitalPanel.lua
--Author : admin
--Date   : 2017/9/15
--此文件由[BabeLua]插件自动生成
--都城

LegionCapitalPanel = class("LegionCapitalPanel", BasicPanel)
LegionCapitalPanel.NAME = "LegionCapitalPanel"

function LegionCapitalPanel:ctor(view, panelName)
    LegionCapitalPanel.super.ctor(self, view, panelName)
    self:setUseNewPanelBg(true)
    --self:setTitle(true,"legionCity",true)
end

function LegionCapitalPanel:finalize()
    LegionCapitalPanel.super.finalize(self)
    if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
end

function LegionCapitalPanel:initPanel()
	LegionCapitalPanel.super.initPanel(self)
	--self:setBgType(ModulePanelBgType.NONE)
    self._proxy = self:getProxy(GameProxys.Legion)


    self._getBtn = self:getChildByName("lastPanel_0/getBtn")
    ComponentUtils:addTouchEventListener(self._getBtn, self.onTouchGetBtn, nil, self)
end

function LegionCapitalPanel:registerEvents()
	LegionCapitalPanel.super.registerEvents(self)
end

function LegionCapitalPanel:onClosePanelHandler()

    self.view:hideModuleHandler()
end

function LegionCapitalPanel:doLayout()
    local panel =self:getPanel(LegionCityPanel.NAME)
    local tabControl = panel:getControl()

    local topPanel =self:getChildByName("topPanel_0")
    local middelPanel = self:getChildByName("middelPanel_0")
    local listView_13 =self:getChildByName("ListView_13_0")
    local downImg =self:getChildByName("downImg_0")
    local lastPanel = self:getChildByName("lastPanel_0")


    --NodeUtils:adaptiveTopY(topPanel,160)
    --NodeUtils:adaptiveUpPanel(middelPanel, topPanel, 20)
    --NodeUtils:adaptiveTopPanelAndListView(middelPanel,listView_13,downImg,topPanel)
    --NodeUtils:adaptiveUpPanel(lastPanel,downImg,20)
end

function LegionCapitalPanel:onShowHandler()
     self._proxy:onTriggerNet220803Req()
end


function LegionCapitalPanel:onHideHandler()
    logger:info("执行了  都城的 onHideHandler")
end

function LegionCapitalPanel:onUpdateCapital(data)
    logger:info("刷新了 220803 的数据")
    logger:info("多少个奖励.."..#data.rewardInfoList)
    local ListView_37 =self:getChildByName("lastPanel_0/ListView_37")
    self:renderListView(ListView_37, data.rewardInfoList, self, self.renderItemRewardPanel,nil,true,0)
    local Label_37 = self:getChildByName("lastPanel_0/Label_37_0")
    if #data.rewardInfoList >0 then 
    Label_37:setVisible(false)
    else
    Label_37:setVisible(true)
    end

    local Button_32 = self:getChildByName("lastPanel_0/Button_32")
    ComponentUtils:addTouchEventListener(Button_32, self.onTouchPeronBtn, nil, self)

    local xLab = self:getChildByName("topPanel_0/Image_3/xLab")
    if data.isWar == 1 then
        xLab:setString(TextWords:getTextWord(560527))
    elseif data.isWar ==2  then
        xLab:setString(TextWords:getTextWord(560528))
    end


     local listView_13 =self:getChildByName("ListView_13_0")
    self:renderListView(listView_13, data.cityAllList, self, self.renderItemPanel,nil,true,0)

    local getBtn = self:getChildByName("lastPanel_0/getBtn")
    if data.isReward == 1 then
       NodeUtils:setEnable(getBtn, false)
    else
       NodeUtils:setEnable(getBtn, true)
    end

    local timeLab = self:getChildByName("lastPanel_0/timeLab")
    timeLab:setString(string.format(TextWords:getTextWord(560510),data.time))

    local Panel_34 =self:getChildByName("lastPanel_0/Panel_34")
    if self._leftEffect == nil then
      self._leftEffect = self:createUICCBLayer("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self:getChildByName("lastPanel_0/Panel_35")
    if self._rightEffect ==nil then
       self._rightEffect = self:createUICCBLayer("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end

end




function LegionCapitalPanel:renderItemRewardPanel(itemPanel,data,index)
    logger:info("第 "..index.." 四个字段 "..data.power.." "..data.typeid.."  "..data.num.."  "..data.rest)
    local Label_40 =itemPanel:getChildByName("Label_40")
    local limitImg =itemPanel:getChildByName("limitImg")

    if data.rest == -1 then 
    Label_40:setVisible(false)
    limitImg:setVisible(false)
    else
    Label_40:setVisible(true)
    Label_40:setString(string.format(TextWords:getTextWord(560509),data.rest))
    limitImg:setVisible(true)
    end
    
    local Panel_39 = itemPanel:getChildByName("Panel_39")
    if itemPanel.icon == nil then
        local icon =UIIcon.new(Panel_39,data,true,self,false,true)
        itemPanel.icon =icon
    else
        itemPanel.icon:updateData(data)
    end


end

function LegionCapitalPanel:onTouchGetBtn(sender)
    local panel = 36 
    local data ={}
    data.panel =panel
    self._proxy:onTriggerNet220801Req(data)
end


function LegionCapitalPanel:onTouchGainBtn(sender)
    local panel = self:getPanel( LegionTanPanel.NAME )
    sender.info.panel = LegionCapitalPanel.NAME
	panel:show(sender.info)
end


function LegionCapitalPanel:onTouchPeronBtn(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	uiTip:setTitle(TextWords:getTextWord(290012))
	local lines = { }
	for i = 560518, 560520 do
		logger:info(i)
		local str = TextWords:getTextWord(i)
        line = {{content =str, foneSize = ColorUtils.tipSize18, color = ColorUtils.commonColor.MiaoShu}}
		table.insert(lines, line)
	end
    uiTip:setAllTipLine(lines)

end


function LegionCapitalPanel:renderItemPanel(itemPanel, info, index)
	logger:info("index  " .. index)
	local bg1 = itemPanel:getChildByName("bg1")
	local bg2 = itemPanel:getChildByName("bg2")
	if index % 2 == 0 then
		bg1:setVisible(true)
		bg2:setVisible(false)
	else
		bg1:setVisible(false)
		bg2:setVisible(true)
	end

	local nameLab = itemPanel:getChildByName("nameLab")
	nameLab:setString(info.cityName)

	local belongLab = itemPanel:getChildByName("belongLab")
	if info.legionOwner == "" then
		belongLab:setString(TextWords:getTextWord(560507))
        belongLab:setColor(ColorUtils.wordBadColor)
	else
		belongLab:setString(info.legionOwner)
        belongLab:setColor(ColorUtils.wordYellowColor03)
	end

	local statueLab = itemPanel:getChildByName("statueLab")
	local idd = nil
	local color = nil
	if info.cityStatus == 0 then
		color = ColorUtils.wordGrayColor
		idd = 550003
	elseif info.cityStatus == 1 then
		color = ColorUtils.wordBadColor
		idd = 550003
	elseif info.cityStatus == 2 then
		color = ColorUtils.wordGreenColor
		idd = 550005
	elseif info.cityStatus == 3 then
		color = ColorUtils.wordBadColor
		idd = 550006
	end
	statueLab:setString(TextWords:getTextWord(idd))
	statueLab:setColor(color)



	local getBtn = itemPanel:getChildByName("getBtn")
    getBtn.info =info
    ComponentUtils:addTouchEventListener(getBtn, self.onTouchGainBtn, nil, self)


	local Button_21 = itemPanel:getChildByName("Button_21")
    local configInfo={}
    configInfo.dataX =info.x
    configInfo.dataY =info.y
    Button_21.configInfo =configInfo
    ComponentUtils:addTouchEventListener(Button_21, self.onTouchGoBtn, nil, self)


end

function LegionCapitalPanel:onTouchGoBtn(sender)
    local configInfo =sender.configInfo
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = configInfo.dataX
    data.extraMsg.tileY = configInfo.dataY

    self:dispatchEvent(LegionCityEvent.GOTO_MAPPOS_REQ, data)
end

function LegionCapitalPanel:updateInfo(data)
    local list =data[1]
    logger:info("刷新的 新列表 "..#list)
    local listView_13 =self:getChildByName("ListView_13_0")
    self:renderListView(listView_13,list, self, self.renderItemPanel,nil,true,0)
end