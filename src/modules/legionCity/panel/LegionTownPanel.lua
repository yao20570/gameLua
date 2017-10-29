--region LegionTownPanel.lua
--Author : admin
--Date   : 2017/9/15
--此文件由[BabeLua]插件自动生成
-- 郡城

LegionTownPanel = class("LegionTownPanel", BasicPanel)
LegionTownPanel.NAME = "LegionTownPanel"

function LegionTownPanel:ctor(view, panelName)
    LegionTownPanel.super.ctor(self, view, panelName)
    self:setUseNewPanelBg(true)
    --self:setTitle(true,"legionCity",true)

end

function LegionTownPanel:finalize()
    LegionTownPanel.super.finalize(self)

    if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
end

function LegionTownPanel:initPanel()
	LegionTownPanel.super.initPanel(self)
    self._proxy = self:getProxy(GameProxys.Legion)


    self._getBtn = self:getChildByName("lastPanel/getBtn")
    ComponentUtils:addTouchEventListener(self._getBtn, self.onTouchGetBtn, nil, self)


end

function LegionTownPanel:registerEvents()
	LegionTownPanel.super.registerEvents(self)
end

function LegionTownPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function LegionTownPanel:onShowHandler()
     self._proxy:onTriggerNet220800Req()
end

function LegionTownPanel:doLayout()
    local panel =self:getPanel(LegionCityPanel.NAME)
    local tabControl = panel:getControl()

    local topPanel =self:getChildByName("topPanel")
    local middelPanel = self:getChildByName("middelPanel")
    local listView_13 =self:getChildByName("ListView_13")
    local downImg =self:getChildByName("downImg")
    local lastPanel = self:getChildByName("lastPanel")


    --NodeUtils:adaptiveTopY(topPanel,160)
    --NodeUtils:adaptiveUpPanel(middelPanel, topPanel, 20)
    NodeUtils:adaptiveTopPanelAndListView(middelPanel,listView_13,downImg,topPanel)
    --NodeUtils:adaptiveUpPanel(lastPanel,downImg,20)

end 

--0  未开放 1 开战期 2 休战期
function LegionTownPanel:getStatus(dataList)
    local status = 0 
    for k,v in pairs(dataList) do
        if v.cityStatus == 0 then 
            
        elseif v.cityStatus == 1 then 
            status = 1
        elseif v.cityStatus == 2 then 
            status = 1 
        elseif v.cityStatus == 3 then 
            status = 1
        elseif v.cityStatus == 4 then 
            status = 1
        elseif v.cityStatus == 5 then 
            status = 2
            return status
        end
    end
    return status 
end


function LegionTownPanel:onHideHandler()    
    logger:info("执行了 on hider")
end

function LegionTownPanel:onUpdateTown(data) 
    logger:info("多少个奖励.."..#data.rewardInfoList)
    local ListView_37 =self:getChildByName("lastPanel/ListView_37")
    self:renderListView(ListView_37, data.rewardInfoList, self, self.renderItemRewardPanel,nil,true,0)
    local Label_37 = self:getChildByName("lastPanel/Label_37")
    if #data.rewardInfoList >0 then 
    Label_37:setVisible(false)
    else
    Label_37:setVisible(true)
    end


    local Button_32 = self:getChildByName("lastPanel/Button_32")
    ComponentUtils:addTouchEventListener(Button_32, self.onTouchPeronBtn, nil, self)

    local townLab = self:getChildByName("topPanel/Image_3/townLab")
    local status = self:getStatus(data.cityAllList)
    logger:info("郡城状态  "..status)
    local str = nil
    if status == 0 then 
        str = TextWords:getTextWord(560504)
    elseif status == 1 then 
        str = TextWords:getTextWord(560505)
    elseif status == 2 then 
        str = TextWords:getTextWord(560506)
    end
    townLab:setString(str)

    local xLab =self:getChildByName("topPanel/Image_3/xLab")
    xLab:setString(data.remainTimes)


    local yLab =self:getChildByName("topPanel/Image_3/yLab")
    yLab:setString(string.format("/%d",data.maxTimes))

    NodeUtils:alignNodeL2R(xLab,yLab)

    local listView_13 =self:getChildByName("ListView_13")
    table.sort(data.cityAllList,function(a,b) return a.cityStatus > b.cityStatus  end )

    local allList = self:sortList(data)

    self:renderListView(listView_13, allList, self, self.renderItemPanel,nil,true,0)

    local getBtn = self:getChildByName("lastPanel/getBtn")
    if data.isReward == 1 then
       NodeUtils:setEnable(getBtn, false)
    else
       NodeUtils:setEnable(getBtn, true)
    end

    local timeLab = self:getChildByName("lastPanel/timeLab")
    timeLab:setString(string.format(TextWords:getTextWord(560510),data.time))

    local Panel_34 =self:getChildByName("lastPanel/Panel_34")
    if self._leftEffect == nil then
      self._leftEffect = self:createUICCBLayer("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self:getChildByName("lastPanel/Panel_35")
    if self._rightEffect ==nil then
       self._rightEffect = self:createUICCBLayer("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end

end

function LegionTownPanel:renderItemPanel(itemPanel, info, index)
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
		idd = 471002
	elseif info.cityStatus == 1 then
		color = ColorUtils.wordBlueColor
		idd = 471003
	elseif info.cityStatus == 2 then
		color = ColorUtils.wordBadColor
		idd = 471004
	elseif info.cityStatus == 3 then
		color = ColorUtils.wordBadColor
		idd = 471005
	elseif info.cityStatus == 4 then
		color = ColorUtils.wordGreenColor
		idd = 471006
	elseif info.cityStatus == 5 then
		color = ColorUtils.wordGreenColor
		idd = 471007
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


function LegionTownPanel:renderItemRewardPanel(itemPanel,data,index)
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

function LegionTownPanel:onTouchGetBtn(sender)
    local panel = 47 
    local data ={}
    data.panel =panel
    self._proxy:onTriggerNet220801Req(data)
end


function LegionTownPanel:onTouchGainBtn(sender)
    local panel = self:getPanel( LegionTanPanel.NAME )
    sender.info.panel = LegionTownPanel.NAME
	panel:show(sender.info)

    --self._proxy:onTriggerNet220802Req()
end


function LegionTownPanel:onTouchPeronBtn(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	uiTip:setTitle(TextWords:getTextWord(290012))
	local lines = { }
	for i = 560512, 560517 do
		logger:info(i)
		local str = TextWords:getTextWord(i)
        line = {{content =str, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
		table.insert(lines, line)
	end
    uiTip:setAllTipLine(lines)

end

function LegionTownPanel:onTouchGoBtn(sender)
    local configInfo =sender.configInfo
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = configInfo.dataX
    data.extraMsg.tileY = configInfo.dataY

    self:dispatchEvent(LegionCityEvent.GOTO_MAPPOS_REQ, data)
end

function LegionTownPanel:updateInfo(data)
    local list =data[1]
    local listView_13 =self:getChildByName("ListView_13")
    local allList =self:sortList(list)
    self:renderListView(listView_13, list, self, self.renderItemPanel,nil,true,0)

end

function LegionTownPanel:sortList(data)
    
    --// 同盟宣战 1 同盟开战 2 同盟归属 3 同盟保护 4 其他归属 5 可宣战 6 未开放 7

    local mine =self._proxy:getMineInfo()
    local mineId =mine.id
    local allList =data.cityAllList
    local function getShowLevel(item)
            local level = 0
	        if #item.declareList > 0 and item.declareList ~= nil then
		        for i, j in pairs(item.declareList) do
			        if mine.id == j then
				       level = 1
			        end
		        end

	        elseif mine.name == item.legionOwner then
		        level = 2

	        elseif item.legionOwner ~= "" then
		        level = 5

	        elseif item.cityStatus == 4 or item.cityStatus == 5 then
		       level = 4

	        elseif item.cityStatus == 1 then
		       level = 6
	        elseif item.cityStatus == 0 then
		        level = 7
	        end
            --logger:info("level "..level.." "..item.cityName)
            return level
        end

    table.sort(allList,function (a,b) 
        local level1 =getShowLevel(a)
        local level2 =getShowLevel(b)   
        return level1 < level2
    end)
   
    return allList
end

