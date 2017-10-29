--region LegionImperialPanel.lua
--Author : admin
--Date   : 2017/9/15
--此文件由[BabeLua]插件自动生成
-- 皇城

LegionImperialPanel = class("LegionImperialPanel", BasicPanel)
LegionImperialPanel.NAME = "LegionImperialPanel"

function LegionImperialPanel:ctor(view, panelName)
    LegionImperialPanel.super.ctor(self, view, panelName)
    self:setUseNewPanelBg(true)
    --self:setTitle(true,"legionCity",true)
end

function LegionImperialPanel:finalize()
    LegionImperialPanel.super.finalize(self)

    if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
end

function LegionImperialPanel:initPanel()
	LegionImperialPanel.super.initPanel(self)

	self._proxy = self:getProxy(GameProxys.Legion)


	self._getBtn = self:getChildByName("lastPanel_0_1/getBtn")
	ComponentUtils:addTouchEventListener(self._getBtn, self.onTouchGetBtn, nil, self)

    local hisBtn =self:getChildByName("addPanel/hisBtn")
    ComponentUtils:addTouchEventListener(hisBtn, self.onTouchHisBtn, nil, self)

    local goBtn = self:getChildByName("addPanel/goBtn")
    ComponentUtils:addTouchEventListener(goBtn, self.onTouchGoBtn, nil,self)
end

function LegionImperialPanel:registerEvents()
	LegionImperialPanel.super.registerEvents(self)
end

function LegionImperialPanel:onClosePanelHandler()
    self.view:hideModuleHandler()

end

function LegionImperialPanel:doLayout()
    local panel =self:getPanel(LegionCityPanel.NAME)
    local tabControl = panel:getControl()

    local topPanel =self:getChildByName("topPanel_0_1")
    local listView_13 =self:getChildByName("ListView_13_0_1")
    local addPanel =self:getChildByName("addPanel")
    local lastPanel = self:getChildByName("lastPanel_0_1")


    --NodeUtils:adaptiveTopY(topPanel,160)
    NodeUtils:adaptiveListView(listView_13,addPanel,topPanel,10,10)
    --NodeUtils:adaptiveUpPanel(lastPanel,addPanel,20)
end

function LegionImperialPanel:onShowHandler()
       self._proxy:onTriggerNet220804Req()
end

function LegionImperialPanel:onHideHandler()
    logger:info("执行了 king 的 onHideHandler")
end


function LegionImperialPanel:onTouchGetBtn(sender)
    local panel = 55 
    local data ={}
    data.panel =panel
    self._proxy:onTriggerNet220801Req(data)
end


function LegionImperialPanel:onTouchGainBtn(sender)
    local panel = self:getPanel( LegionKingTanPanel.NAME )
	panel:show(sender.info)
end


function LegionImperialPanel:onTouchPeronBtn(sender)
	local parent = self:getParent()
	local uiTip = UITip.new(parent)
	uiTip:setTitle(TextWords:getTextWord(290012))
	local lines = { }
	for i = 560521, 560525 do
		logger:info(i)
		local str = TextWords:getTextWord(i)
        line = {{content =str, foneSize = ColorUtils.tipSize16, color = ColorUtils.commonColor.MiaoShu}}
		table.insert(lines, line)
	end
    uiTip:setAllTipLine(lines)
end


function LegionImperialPanel:onUpdateImperial(data)
    local ListView_37 =self:getChildByName("lastPanel_0_1/ListView_37")
    self:renderListView(ListView_37, data.rewardInfoList, self, self.renderItemRewardPanel,nil,true,0)
    local Label_37 = self:getChildByName("lastPanel_0_1/Label_37_0")
    if #data.rewardInfoList >0 then 
    Label_37:setVisible(false)
    else
    Label_37:setVisible(true)
    end

    local Button_32 = self:getChildByName("lastPanel_0_1/Button_32")
    ComponentUtils:addTouchEventListener(Button_32, self.onTouchPeronBtn, nil, self)

    local listView_13 =self:getChildByName("ListView_13_0_1")
    self:renderListView(listView_13, data.cityAllList, self, self.renderItemPanel,nil,true,0)

    local getBtn = self:getChildByName("lastPanel_0_1/getBtn")
    if data.isReward == 1 then
       NodeUtils:setEnable(getBtn, false)
    else
       NodeUtils:setEnable(getBtn, true)
    end

    local timeLab = self:getChildByName("lastPanel_0_1/timeLab")
    timeLab:setString(string.format(TextWords:getTextWord(560510),data.time))

    local xLab = self:getChildByName("topPanel_0_1/Image_3/xLab")

    TimerManager:remove(self.showRestTime, self)
    self:showRestTime(data.nextTime)

    local y =os.date("%Y", data.nextTime)                                                                        --年
    local m =os.date("%m", data.nextTime)                                                                        --月
    local d =os.date("%d", data.nextTime)                                                                        --日
    local h =os.date("%X", data.nextTime)
    logger:info(data.nextTime)
    logger:info(" 年 月 日 时 "..y.."  "..m.."  "..d.."  "..h)
    

    --local time = data.nextTime-GameConfig.serverTime
    --local date = math.floor(time / 86400)
    --local hour = math.floor(time % 86400 /3600)
    --logger:info("               "..date.." "..hour)
    --xLab:setString(string.format(TextWords:getTextWord(560526),date,hour))


    local Panel_34 =self:getChildByName("lastPanel_0_1/Panel_34")
    if self._leftEffect == nil then
      self._leftEffect = self:createUICCBLayer("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self:getChildByName("lastPanel_0_1/Panel_35")
    if self._rightEffect ==nil then
       self._rightEffect = self:createUICCBLayer("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end
end


function LegionImperialPanel:renderItemRewardPanel(itemPanel,data,index)
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



--[[
    data.cityId  ,cityName = {13 ,许昌} {14，长安} { 15，洛阳}
]]
function LegionImperialPanel:renderItemPanel(itemPanel,data,index)
    local urlCity = { }
    urlCity[1] = "images/emperorCityIcon/icon_city1.png"                            
    urlCity[2] = "images/emperorCityIcon/icon_city2.png"                            -- 王城
    urlCity[3] = "images/emperorCityIcon/icon_city3.png"                            -- 皇城

    local statusCity1 = "images/emperorCityIcon/font_status1.png"                   --未开放
    local statusCity2 = "images/emperorCityIcon/font_status3.png"                   --准备中
    local statusCity3 = "images/emperorCityIcon/font_status4.png"                   --争夺期

    local cityName1 = "images/emperorCityIcon/font_city_name13.png"
     local cityName2 = "images/emperorCityIcon/font_city_name14.png"
      local cityName3 = "images/emperorCityIcon/font_city_name15.png"

    local empIcon = itemPanel:getChildByName("empIcon")
    if data.cityId == 13  or data.cityId == 14 then 
        TextureManager:updateImageView(empIcon, urlCity[2] )
        elseif data.cityId == 15 then 
        TextureManager:updateImageView(empIcon, urlCity[3])

    end

    local empName = itemPanel:getChildByName("empName")
    if data.cityId == 13 then 
       TextureManager:updateImageView(empName, cityName1 )
       elseif data.cityId == 14 then
       TextureManager:updateImageView(empName, cityName2 )
       elseif data.cityId == 15 then 
       TextureManager:updateImageView(empName, cityName3 )
   end


   local legionName =itemPanel:getChildByName("legionName")
   if data.legionOwner =="" then 
        legionName:setString(TextWords:getTextWord(560507))
        legionName:setColor(ColorUtils.wordBadColor)
   else
        legionName:setString(data.legionOwner)
        legionName:setColor(ColorUtils.wordNameColor)
   end
   
   local getBtn = itemPanel:getChildByName("getBtn")
   getBtn.info = data
   ComponentUtils:addTouchEventListener(getBtn, self.onTouchGainBtn, nil, self)

   local jumpBtn= itemPanel:getChildByName("jumpBtn")
   local configInfo={}
   configInfo.dataX =data.x
   configInfo.dataY =data.y
    jumpBtn.configInfo =configInfo
   ComponentUtils:addTouchEventListener(jumpBtn, self.onTouchJumpBtn, nil, self)

   local stateImg =itemPanel:getChildByName("stateImg")
   logger:info("    "..data.cityStatus)
   stateImg:setVisible(true)
   if   data.cityStatus == 1  then 
        TextureManager:updateImageView(stateImg, statusCity1)
        elseif data.cityStatus == 2 then
        TextureManager:updateImageView(stateImg, statusCity1)
        stateImg:setVisible(false)
        elseif data.cityStatus == 3 then 
        TextureManager:updateImageView(stateImg, statusCity2)
        elseif data.cityStatus == 4 then 
        TextureManager:updateImageView(stateImg, statusCity3)
    end

    local url1 = "images/newGui1/BtnMiniRed1.png"
    local url2 = "images/newGui1/BtnMiniRed2.png"

    local url3 = "images/newGui1/BtnMiniGreed1.png"
    local url4 = "images/newGui1/BtnMiniGreed2.png"
    if data.cityStatus == 4 then
        TextureManager:updateButtonNormal(jumpBtn, url1)
        TextureManager:updateButtonPressed(jumpBtn,url2)
        jumpBtn:setTitleText(TextWords:getTextWord(560535))
    else
        TextureManager:updateButtonNormal(jumpBtn, url3)
        TextureManager:updateButtonPressed(jumpBtn,url4)
        jumpBtn:setTitleText(TextWords:getTextWord(560536))
    end


end


function LegionImperialPanel:onTouchHisBtn(sender)
   logger:info("点击查看历史战绩")
    -- 加入同盟才可查看战绩
    local roleProxy =self:getProxy(GameProxys.Role)
    local myLegionName = roleProxy:getLegionName()
    if myLegionName == "" then
        self:showSysMessage(self:getTextWord(915))
        return 
    end
    local empProxy =self:getProxy(GameProxys.EmperorCity)
    empProxy:onTriggerNet550002Req({})   
end

function LegionImperialPanel:onTouchGoBtn(sender)

    logger:info("点击皇权")

    -- 屏蔽检查
    if self:getProxy(GameProxys.Country):getIsOpen() == 0 then
        self:showSysMessage(self:getTextWord(821))
        return
    end

    self:dispatchEvent(LegionCityEvent.SHOW_OTHER_EVENT, "CountryModule")
end

function LegionImperialPanel:onTouchJumpBtn(sender)
    TimerManager:remove(self.showRestTime, self)
    local configInfo =sender.configInfo
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = configInfo.dataX
    data.extraMsg.tileY = configInfo.dataY

    self:dispatchEvent(LegionCityEvent.GOTO_MAPPOS_REQ, data)

end

function LegionImperialPanel:updateInfo(data)
    local list =data[1]

    for k,v in pairs (list) do
        logger:info(v.cityStatus)
    end
    logger:info("刷新的 新列表 "..#list)
    local listView_13 =self:getChildByName("ListView_13_0_1")
    self:renderListView(listView_13,list, self, self.renderItemPanel,nil,true,0)
end


function LegionImperialPanel:sortInfo(data)
end

function LegionImperialPanel:showRestTime(nextTime)
    
    local xLab = self:getChildByName("topPanel_0_1/Image_3/xLab")
    local time = nextTime-GameConfig.serverTime
    local date = math.floor(time / 86400)
    local hour = math.floor(time % 86400 /3600)
    local min = math.floor( time % 3600 /60  )                                                              --分钟
    local second =math.floor(time %60 )

    logger:info("               "..date.." "..hour.."  "..min.." "..second)
    --xLab:setString(string.format(TextWords:getTextWord(560526),date,hour))
    if time > 0 then
        TimerManager:addOnce(1000, self.showRestTime, self,nextTime)
        if date > 0  then
            xLab:setString(string.format(TextWords:getTextWord(560526),date,hour))      
        elseif hour  >0 then
            xLab:setString(string.format(TextWords:getTextWord(560540),hour,min))
        elseif min>0 then
            xLab:setString(string.format(TextWords:getTextWord(560541),min,second))   
        end
    else
        self._proxy:onTriggerNet220804Req() 
    end
end

function LegionImperialPanel:removeFun()
    TimerManager:remove(self.showRestTime, self)
end