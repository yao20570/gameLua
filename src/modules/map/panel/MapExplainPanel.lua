MapExplainPanel = class("MapExplainPanel", BasicPanel)
MapExplainPanel.NAME = "MapExplainPanel"

function MapExplainPanel:ctor(view, panelName)
    local layer = view:getLayer(ModuleLayer.UI_TOP_LAYER)
    MapExplainPanel.super.ctor(self, view, panelName, 800, layer)
    
    self:setUseNewPanelBg(true)
end

function MapExplainPanel:finalize()
    if self._effect ~= nil then
        self._effect:finalize()
        self._effect = nil
    end

    MapExplainPanel.super.finalize(self)
end

function MapExplainPanel:initPanel()
	MapExplainPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(290028))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

    self.btns = {}
    for i=1,3 do
        self.btns[i] = self:getChildByName("Panel_2/btn"..i)
        self.btns[i].id = i
        self:addTouchEventListener(self.btns[i], self.topBtnTouch)
    end

    local sureBtn = self:getChildByName("Panel_2/sureBtn")
    self:addTouchEventListener(sureBtn, self.hide)

    self:initPanelNew()
    self:initDataPanel()

    self.XChoose = 1
    self.YChoose = 1
    self.XMax = 6
    --self.YMax = 1
    self:initEvent()
end

function MapExplainPanel:onShowHandler()
    self:topBtnTouch({id = 1})
end

function MapExplainPanel:topBtnTouch(sender)
    sender.id = sender.id or 1
    for k,v in pairs(self.btns) do
        local img = v:getChildByName("img")
        img:setVisible(v.id ~= sender.id)
    end

    self:updateView(sender.id)
    --self:updateGroup(sender.id)
    --self.updateCheckBox()
end

function MapExplainPanel:updateView(index)
    for i=1,3 do
        local descLab = self:getChildByName("Panel_2/descLab"..i)
        local key = string.format("2900%d%d", (index + 2), i)
        local text = TextWords:getTextWord(tonumber(key))
        descLab:setString(text)
    end
    if self._oldIndex == index and (index ~= 1 or (index == 1 and self._effect ~= nil)) then
        return
    end

    local city = self:getChildByName("Panel_2/cityNode1")
    city:setVisible(index == 3)

    local mainCity = self:getChildByName("Panel_2/cityNode2")
    local url = index == 2 and "images/map/res2.png" or "images/map/building52.png"
    TextureManager:updateImageView(mainCity, url)

    local targetCity = self:getChildByName("Panel_2/cityNode3")
    url = (index == 1 or index == 2) and "images/map/building54.png" or "images/map/building52.png"
    TextureManager:updateImageView(targetCity, url)

    local scale = index == 2 and 1 or 0.6
    mainCity:setScale(scale)

    local iconImg = self:getChildByName("Panel_2/iconImg")
    iconImg:setScale(1)
    iconImg:setVisible(false)

    local stateImg = self:getChildByName("Panel_2/stateImg")
    stateImg:setVisible(false)

    local effectName = {{name = "rgb-wfsm-gongjidiren"}, {name = "rgb-wfsm-caiji"}, {name = "rgb-wfsm-yuanzhu"}}



    if self._oldIndex == index and (index ~= 1 or (index == 1 and self._effect ~= nil)) then
        return
    else
        TimerManager:remove(self.changEffect, self)
        local curPauseIndex = 1
        self._oldIndex = index
        if self._effect ~= nil then
            self._effect:finalize()
            self._effect = nil
        end
        TimerManager:addOnce(500, self.changEffect, self, curPauseIndex, index)
    end
end

function MapExplainPanel:changEffect(curPauseIndex, index)
    local effectName = {{name = "rgb-wfsm-gongjidiren"}, {name = "rgb-wfsm-caiji"}, {name = "rgb-wfsm-yuanzhu"}}
    local maxCounts = {3, 4, 2}
    local effectInfo = effectName[index]
    local parent = self:getChildByName("Panel_2/effectNode")
    self._effect = UICCBLayer.new(effectInfo.name, parent, {pause = function()
        self:pauseFunc(curPauseIndex, index)
        curPauseIndex = curPauseIndex + 1
        if curPauseIndex > maxCounts[index] then
            curPauseIndex = 1
        end
    end})
end

function MapExplainPanel:pauseFunc(pauseIndex, index)
    local maxCounts = {3, 4, 2}
    if pauseIndex > maxCounts[index] then
        return
    end

    local mainCity = self:getChildByName("Panel_2/cityNode2")
    local stateImg = self:getChildByName("Panel_2/stateImg")
    local iconImg = self:getChildByName("Panel_2/iconImg")
    stateImg:setVisible(index ~= 2)
    iconImg:setVisible(index == 2)

    if index == 1 then
        if pauseIndex == 1 then
            TextureManager:updateImageView(stateImg, "images/map/bg_Selected.png")
            TextureManager:updateImageView(mainCity, "images/map/building52.png")
        elseif pauseIndex == 2 then
            TextureManager:updateImageView(stateImg, "images/newGui1/none.png")
        else
            TextureManager:updateImageView(mainCity, "images/map/building51.png")
        end
    elseif index == 2 then
        if pauseIndex == 1 then
            TextureManager:updateImageView(iconImg, "images/map/bg_Selected.png")
        elseif pauseIndex == 2 then
            TextureManager:updateImageView(iconImg, "images/newGui1/none.png")
        elseif pauseIndex == 3 then
            TextureManager:updateImageView(iconImg, "images/map/bg_collection.png")
        else
            TextureManager:updateImageView(iconImg, "images/newGui1/none.png")
        end
    else
        if pauseIndex == 1 then
            TextureManager:updateImageView(stateImg, "images/map/bg_gotogar.png")
        else
            TextureManager:updateImageView(stateImg, "images/map/bg_Garrison.png")
        end
    end

end

--重写关闭方法，释放特效，因为特效无限循环，回调一直在消耗
function MapExplainPanel:hide()
    if self._effect ~= nil then
        self._effect:finalize()
        self._effect = nil
    end
    MapExplainPanel.super.hide(self)
end

-- //null 初始化新的panel 老版依旧保留
function MapExplainPanel:initPanelNew()
--	logger:info("初始化新的界面")
	local Panel_2 = self:getChildByName("Panel_2")

	-- //null 初始化新checkbox
	self._checkBox = { }
	for i = 1, 6 do
		self._checkBox[i] = Panel_2:getChildByName("CheckBox_" .. i)
        local  txt =self._checkBox[i]:getChildByName("nameLab")
        self._checkBox[i].id = i
        if i == 1 then
        self._checkBox[i]:setSelectedState(true)
        txt:setColor(ColorUtils.wordNameColor)
        else
        self._checkBox[i]:setSelectedState(false)
        txt:setColor(ColorUtils.wordYellowColor03)
        end
	--	logger:info("加载了一checkbox  " .. i)
        self:addTouchEventListener(self._checkBox[i],self.updateCheckBox)

       local data=ConfigDataManager:getInfosFilterByOneKey(ConfigData.WorldHelpConfig,"group",i)
       local strName = data[1].name
    --   print(strName)
       local nameTxt=self._checkBox[i]:getChildByName("nameLab")
       nameTxt:setString(strName)
	end

	-- 左btn
	self._leftBtn = Panel_2:getChildByName("leftBtn")
    self._leftBtn.dir = -1
    self.leftEct = self:createUICCBLayer("rgb-fanye", self._leftBtn)
    self.leftEct:setPosition(self._leftBtn:getContentSize().width/2+10,self._leftBtn:getContentSize().height/2)
	-- 右btn
	self._right = Panel_2:getChildByName("right")
    self._right.dir =  1
    self.rightEct = self:createUICCBLayer("rgb-fanye", self._right)
    self.rightEct:setPosition(self._leftBtn:getContentSize().width/2-10.5,self._leftBtn:getContentSize().height/2-2)
    self._right:setScaleX(-1)


	self._Label_name = Panel_2:getChildByName("Label_name")

	self._image_8 = Panel_2:getChildByName("Image_8")

	self._descs = { }
	for i = 1, 3 do
		self._descs[i] = Panel_2:getChildByName("desc" .. i)
--		logger:info("加载了一desc  " .. i)
	end

    self:addTouchEventListener(self._leftBtn, self.dirBtnTouch)
    self:addTouchEventListener(self._right,self.dirBtnTouch)
end

function MapExplainPanel:dirBtnTouch(sender)
 --   logger:info(" dir "..sender.dir)
    self.YChoose =self.YChoose + sender.dir
    if sender.dir > 0 then
        if self.YChoose > self.YMax then
        self.YChoose = 1
        end
    else 
        if self.YChoose <= 0 then
        self.YChoose =self.YMax
        end
    end
--    print("x-------y"..self.XChoose..self.YChoose)
    self:updateGroup(self.XChoose,self.YChoose)
end

function MapExplainPanel:initDataPanel()
	local configData = ConfigDataManager:getConfigData(ConfigData.WorldHelpConfig)
    self.list={}
    for i=1,6 do
    local data=ConfigDataManager:getInfosFilterByOneKey(ConfigData.WorldHelpConfig,"group",i)
    if i == 1 then
    self.YMax = #data
    end
    print(#data)
    local txt =self._checkBox[i]:getChildByName("nameLab")
    --txt:setString(data[1][name])
    end   
    logger:info(self.YMax)
    self:updateGroup(1,1)
end

--//null 刷新当前选中界面内容
function MapExplainPanel:updateGroup(id,group)
    group = group or 1
    id = id or 1
--    logger:info(id.."    %%%%%%   "..group.." YMax   "..self.YMax)
    local data = ConfigDataManager:getInfoFindByTwoKey(ConfigData.WorldHelpConfig, "group", id, "sort", group)
    local describe =data.describe
    local listDesc = ComponentUtils:Split(describe,"#")

    --//null 中间图片刷新
    local url ="bg/worldHelp/"..id..group..".webp"
    --print(url)

    TextureManager:updateImageViewFile(self._image_8, url )

    --//null  
    local rolepro = self:getProxy(GameProxys.Role)
    local hour,desc =rolepro:getWorldTimeConfig(id)
--    print(hour.."        "..desc)

    local Panel_bg=self:getChildByName("Panel_2/Panel_bg")
    local Label_75 = Panel_bg:getChildByName("Label_75")
    if desc ~="" then
        Panel_bg:setVisible(true)
        Label_75:setString(desc)
    else
        Panel_bg:setVisible(false)
    end
 
   --//null 标题和描述 
    local Label_name=self:getChildByName("Panel_2/Label_name")
    Label_name:setString(data.title)

    for k,v in pairs(listDesc) do
        local desc = self:getChildByName("Panel_2/desc"..k)
    --    logger:info("----------------"..k..v)
        desc:setFontSize(20)
        desc:setString(v) 
    end

    --//null 第几页共几页
    local Label_tag =self:getChildByName("Panel_2/Label_tag")
    local str =string.format(TextWords[540020],group,self.YMax)
    Label_tag:setString(str)
    self:updateIcon(group,self.YMax)
      
end

function MapExplainPanel:initEvent()
	local touchPanel = self:getChildByName("Panel_2/touchPanel")
	local function onTouchHandler(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			self._startPos = sender:getTouchBeganPosition()
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			self._endPos = sender:getTouchEndPosition()
--			print("self endppos" .. self._endPos.x)
			if self._startPos.x > self._endPos.x then
                touchPanel.dir = 1
                self:dirBtnTouch(touchPanel)
--				print("左滑动")
			elseif self._startPos.x < self._endPos.x then
                touchPanel.dir = -1
                self:dirBtnTouch(touchPanel)
--				print("右滑动")
			end
		end
	end
	touchPanel:addTouchEventListener(onTouchHandler)

end


function MapExplainPanel:updateCheckBox(sender)
	-- logger:info("sender  id " ..sender.id)

	for i = 1, 6 do
        local  txt =self._checkBox[i]:getChildByName("nameLab")
		if i == sender.id then
			self._checkBox[i]:setSelectedState(false)
            txt:setColor(ColorUtils.wordNameColor)
 --           print("true")
		else
			self._checkBox[i]:setSelectedState(false)
            txt:setColor(ColorUtils.wordYellowColor03)
  --          print("false")
		end
        self._checkBox[i]:setSelectedState(false)    
	end
   

	if self.XChoose == sender.id then
		return
	end

    local data=ConfigDataManager:getInfosFilterByOneKey(ConfigData.WorldHelpConfig,"group",sender.id)
    self.YMax = #data

    --//当前选择 肯定 Y choose 肯定是 1
	self.XChoose = sender.id
    self.YChoose = 1
	self:updateGroup(self.XChoose, self.YChoose)

end

function MapExplainPanel:updateIcon(group,YMax)
    local urlWhite = "images/newGui2/white.png"
    local urlYellow = "images/newGui2/yellow.png"

    local Label_tag =self:getChildByName("Panel_2/Label_tag")                                           --校准点的中心

    local icons={}

    for i=1, 10 do
        local iconC = self:getChildByName("Panel_2/tip"..i)
        iconC:setVisible(false)
    end

    local posx= 260 

    for i=1,YMax do
        local iconC = self:getChildByName("Panel_2/tip"..i)
        iconC:setVisible(true)
        iconC:setPositionX(i*10+260)
        iconC:setPositionY(95)
        if i ==  group then
        TextureManager:updateImageView(iconC, urlYellow)
        else
        TextureManager:updateImageView(iconC, urlWhite)
        end
        icons[i] = iconC
    end


    NodeUtils:centerNodesGlobal(Label_tag, icons)
    Label_tag:setVisible(false)



end