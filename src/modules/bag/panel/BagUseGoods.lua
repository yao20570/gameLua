
BagUseGoods = class("BagUseGoods", BasicPanel)
BagUseGoods.NAME = "BagUseGoods"

function BagUseGoods:ctor(view, panelName)
    BagUseGoods.super.ctor(self, view, panelName)
    self.typeId = 0

    self:setUseNewPanelBg(true)
end

function BagUseGoods:finalize()
    BagUseGoods.super.finalize(self)
end

function BagUseGoods:initPanel()
	BagUseGoods.super.initPanel(self)
	local lookUpPanel = self:getChildByName("Panel_1/Panel_8")
    --点这里搜索
    self._chatEditBox = ComponentUtils:addEditeBox(lookUpPanel,30,self:getTextWord(5052))
    self._chatEditBox:setMaxLength(40)
end

function BagUseGoods:registerEvents()
	BagUseGoods.super.registerEvents(self)
	for i=1,4 do
		self["button_"..i] = self:getChildByName("Panel_1/Button_"..i)
		self["button_"..i].index = i
		self:addTouchEventListener(self["button_"..i],self.useEvents)
	end
	self.TitleText = self:getChildByName("Panel_1/TextTitle")
end

function BagUseGoods:onShowHandler(data)
	self.typeId = data.typeid
	local num = data.num
	self._chatEditBox:setText("")
	self.TitleText:setString(data.name)
	if num and num == 0 then
		self.TitleText:setString(data.name)
		self.button_2:setVisible(false)
		self.button_4:setTitleText("确定")
		self._chatEditBox:setPlaceHolder(self:getTextWord(5052))
	elseif num and num == 1 then
		self.button_2:setVisible(false)
		self.button_4:setTitleText("确定")
		self._chatEditBox:setPlaceHolder("请输入新的指挥官名称")
	elseif num and num == 2  then --矿点勘察
		self.button_2:setVisible(true)
		self.button_4:setTitleText("搜索")
		self._chatEditBox:setPlaceHolder("请输入指挥官名称")
	elseif num and num == 3 then  --发红包
		self.button_2:setVisible(true)
	else
		self.button_2:setVisible(true)
	end
end

function BagUseGoods:useEvents(sender)
	if sender.index == 1 then
		self:hide()
	elseif sender.index == 2 then
		print("添加")
	elseif sender.index == 3 then
		self:hide()
	elseif sender.index == 4 then  --去改名 搜索等功能都在这里
		local text = self._chatEditBox:getText()
		if text == "" then return end
		local _typeId = self.typeId
		self:dispatchEvent(BagEvent.ESPECIALGOODSUSE_REQ,{typeId = _typeId,name = text})
		self:hide()
	end
end