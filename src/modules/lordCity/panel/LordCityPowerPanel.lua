--[[
城主战：参战资格弹窗
]]
LordCityPowerPanel = class("LordCityPowerPanel", BasicPanel)
LordCityPowerPanel.NAME = "LordCityPowerPanel"

function LordCityPowerPanel:ctor(view, panelName)
    LordCityPowerPanel.super.ctor(self, view, panelName, 750)
end

function LordCityPowerPanel:finalize()
    LordCityPowerPanel.super.finalize(self)
end

function LordCityPowerPanel:initPanel()
	LordCityPowerPanel.super.initPanel(self)
	self:setTitle(true,self:getTextWord(370085))
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
	self._scrollView = self:getChildByName("mainPanel/scrollView")
	local itemPanel = self._scrollView:getChildByName("itemPanel")
	itemPanel:setVisible(false)

	for i=1,4 do
		local typeTxt = self:getChildByName("mainPanel/typePanel/type"..i)
		txtNO = self:getTextWord(370085+i)
		if typeTxt and txtNO then
			typeTxt:setString(txtNO)
		end
	end
	local tipTxt = self:getChildByName("mainPanel/tipTxt")
	tipTxt:setString(self:getTextWord(370090))

end

function LordCityPowerPanel:registerEvents()
	LordCityPowerPanel.super.registerEvents(self)
end

function LordCityPowerPanel:onClosePanelHandler()
	self:hide()
end

function LordCityPowerPanel:onShowHandler()
	local infos = self._lordCityProxy:getPowerInfos() or {}
	self:renderScrollView(self._scrollView, "itemPanel", infos, self, self.renderItem)
end

function LordCityPowerPanel:renderItem(itemPanel,info)
	if itemPanel == nil or info == nil then
		return
	end
	itemPanel:setVisible(true)

	local legionNameTxt = itemPanel:getChildByName("legionName")
	local fightCapTxt = itemPanel:getChildByName("fightCap")
	local curNumberTxt = itemPanel:getChildByName("curNumber")
	local maxNumberTxt = itemPanel:getChildByName("maxNumber")
	local rankTxt = itemPanel:getChildByName("rank")
	local itemBgImg = itemPanel:getChildByName("imgItemBg")
    
    local rank = info.rank
    if rank%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    end
	local capacity = StringUtils:formatNumberByK3(info.capacity)

	legionNameTxt:setString(info.legionName)
	fightCapTxt:setString(capacity)
	rankTxt:setString(rank)
	curNumberTxt:setString(info.curNumber)
	maxNumberTxt:setString("/" .. info.maxNumber)
end

function LordCityPowerPanel:onPowerUpdate()
	self:onShowHandler()
end
