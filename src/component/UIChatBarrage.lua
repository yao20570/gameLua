UIChatBarrage = class("UIChatBarrage", BasicComponent)

function UIChatBarrage:ctor(panel, parent)
	UIRetPacketNew.super.ctor(self)
	self._panel = panel
	self._uiSkin = UISkin.new("UIChatBarrage")


	self._uiSkin:setVisible(true)
	self._uiSkin:setParent(parent)

	self._mainPanel = self._uiSkin:getChildByName("mainPanel")
	self._mainPanel:setTouchEnabled(false)
	self._barragePanel = self._uiSkin:getChildByName("mainPanel/barragePanel")
	print(self._barragePanel:getTag())
	self._barrageBtn = self._mainPanel:getChildByName("barrageCheck")
	self._barrageBtn:setSelectedState(false)
    self._barrageBtn:setVisible(false)
	self._barrageImg = self._uiSkin:getChildByName("mainPanel/barrageImg")
	self._barrageImg:setVisible(false)

	self._btnTouch = self._uiSkin:getChildByName("mainPanel/Button_1")

	self:init()

	--ComponentUtils:addTouchEventListener(self._barrageBtn, self.onBarrageBtn, nil, self)
	ComponentUtils:addTouchEventListener(self._btnTouch, self.onBtnTouch, nil, self)

    self._objPool = {}
end

function UIChatBarrage:finalize()
	self._uiSkin:finalize()
	self._uiSkin = nil
	UIChatBarrage.super.finalize(self)

	-- //对象池 释放
	for k, v in pairs(self._objPool) do
		v:removeFromParent()
	end

	self._objPool = nil
end

function UIChatBarrage:onBarrageBtn(sender)
	if self._barrageBtn:getSelectedState() then
		self._barragePanel:setVisible(true)
	else
		self._barragePanel:setVisible(false)
	end
end


function UIChatBarrage:updateDataChat(k, data)
	-- //弹幕屏没开
	if self._barragePanel:isVisible() == false then
		return
	end

	-- //是不是分享
	if rawget(data, "isShare") == true then
		return
	end

	-- //判断时间戳
	local times = data.time
	local gameServer = GameConfig.serverTime
	--   print(times.."   "..gameServer.."  "..gameServer-times)
	if gameServer - times > 600 then
		return
	end


	-- //来的数据是 私聊 或者 喇叭聊
	if data.type == 0 or data.extendValue == 2 then
		return
	end

	-- //是不是自己发的 自己发的不弹
	local proxy = self._panel:getProxy(GameProxys.Role)
	local name = proxy:getRoleName()

	if name == data.name then
		 return
	end
	-- self._barragePanel:setVisible(false)


-- //新弹幕 从对象池里面取

	local barrage = nil
	if #self._objPool > 0 then
		barrage = self._objPool[1]
		barrage:setVisible(true)
		table.remove(self._objPool, 1)
        --logger:info("d对象池 对象")
	else
		barrage = self._barrageImg:clone()
        self._barragePanel:addChild(barrage)
	end

	barrage:setVisible(true)
	barrage:setLocalZOrder(20)
    barrage:setAnchorPoint(0,1)
	--self._barragePanel:addChild(barrage)

	local contentTxt = barrage:getChildByName("contentTxt")
	contentTxt:setAnchorPoint(0, 1)
	contentTxt:setVisible(false)
	local typeTxt = barrage:getChildByName("typeTxt")
	typeTxt:setAnchorPoint(0, 1)

	-- 聊天类型 1 世界 2 同盟
	if data.type == 1 then
		typeTxt:setString(TextWords:getTextWord(540021))
	elseif data.type == 2 then
		typeTxt:setString(TextWords:getTextWord(540022))
	end

	-- 聊天值 1 系统红包 3 玩家红包 2 语音信息
	local txt = nil
	local color = nil
	if data.extendValue == 1 or data.extendValue == 3 then
		txt = data.name .. TextWords:getTextWord(540023)
		contentTxt:setString(txt)
		contentTxt:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Red))
		color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Red)
	else
		txt = data.name .. ":" .. data.context
		contentTxt:setString(txt)
	end

	if barrage.chatItem ~= nil then
		self:setValue(barrage.chatItem, txt, color)
        local size = barrage.chatItem :getContentSize()
        barrage:setContentSize(380,(size.height+10)*0.9)

	else
		local chatItem = self:resetValue(txt, color)
		barrage.chatItem = chatItem
		barrage:addChild(chatItem)
        local size = chatItem :getContentSize()
        barrage:setContentSize(380,(size.height+10)*0.9)
	end

	--contentTxt:ignoreContentAdaptWithSize(false)


	local contextWidth = contentTxt:getContentSize().width

	-- //偏移间距
	local distant = 1
	--print("contextWidth  " .. contextWidth..contentTxt:getString())
    --print("真实宽度 "..barrage.chatItem:getRealWidth().."  designwidth "..barrage.chatItem:getDesignWidth()*0.6 )
    --print(barrage.chatItem:getContentSize().width)

	if contextWidth > 560 then

		--contentTxt:setContentSize(280, 90)
		barrage:setContentSize(280 + 150, 90)

		--contentTxt:setPositionY(85)
		typeTxt:setPositionY(85)
		distant = 3

	elseif contextWidth > 280 and contextWidth < 560 then
		--contentTxt:setContentSize(280, 60)
		barrage:setContentSize(280 + 150, 60)

		--contentTxt:setPositionY(55)
		typeTxt:setPositionY(55)
		distant = 2

	else
		barrage:setContentSize(contentTxt:getContentSize().width + 150, 35)
        typeTxt:setPositionY(30)
		distant = 1
	end

    if  barrage.chatItem:getRealWidth() < 300 then
        barrage:setContentSize(contentTxt:getContentSize().width + 100, 35)
        typeTxt:setPositionY(30)
		distant = 1
    end



	-- 设置一条弹幕的位置
	local winSize = cc.Director:getInstance():getWinSize()
	local barrageSize = barrage:getContentSize()

	barrage:setPositionX(math.random(0, winSize.width - barrageSize.width))

	local offsetHeight = math.random(65, 75)

	local oDis = 0
	if distant == 1 then
		oDis = 30
	elseif distant == 2 then
		oDis = 50
	elseif distant == 3 then
		oDis = 70

	end


	-- if barrage:getContentSize().height > 50 then
	-- barrage:setPositionY(k*-offsetHeight-50)
	-- else
	-- barrage:setPositionY(k*-offsetHeight)
	-- end

	barrage:setPositionY(k * - offsetHeight - oDis)

	barrage:setOpacity(0)


	-- 淡入动画
	-- local action1 =cc.FadeIn:create(5)
	-- barrage:runAction(action1)

	local moveTo = cc.MoveBy:create(3 + k / 2 + 0.5, cc.p(0, self._barragePanel:getContentSize().height * 0.7 + k * offsetHeight + oDis))

	-- if barrage:getContentSize().height > 50 then
	-- moveTo = cc.MoveBy:create(3+k/2, cc.p(0, self._barragePanel:getContentSize().height * 0.7+k*offsetHeight+50))
	-- end

	-- local easeSineOut = cc.EaseSineOut:create(moveTo)

	-- 弹幕动画
	local action = cc.Spawn:create(
	cc.Sequence:create(cc.DelayTime:create(k / 2 + 0.5),
	cc.FadeIn:create(1)),
	moveTo,
	cc.Sequence:create(
	cc.DelayTime:create(2 + k / 2),
	cc.FadeOut:create(1),
	cc.CallFunc:create( function()
		-- 释放这个对象
		--barrage:removeFromParent()
        --barrage:removeFromParentAndCleanup(false)

		-- 隐藏这个对象 放入对象池
		barrage:setVisible(false)
        barrage.chatItem:setData({})
		table.insert(self._objPool, barrage)
	end ))
	)


	barrage:runAction(action)

end


function UIChatBarrage:init()
	self._barrageList = { }
	-- self:updateBarrage()
end

-- //null  纵坐标偏移 
function UIChatBarrage:setHeight(height)
	self._mainPanel:setPositionY(height)
	self._offset = height
	self._aimHeight = self._barragePanel:getContentSize().height - height
end


function UIChatBarrage:updateBarrage()
end

function UIChatBarrage:onBtnTouch(sender)
    --print(" touch once angine")
    local url1 = "images/component/barrageBtn1.png"
    local url2 = "images/component/barrage3.png"
    local url3 = "images/component/barrageBtn2.png"
    local url4 = "images/component/barrage4.png"

    if self._barragePanel:isVisible() == true then
        self._barragePanel:setVisible(false)
        TextureManager:updateButtonNormal(self._btnTouch, url3)
        TextureManager:updateButtonPressed(self._btnTouch, url2)
    else
         self._barragePanel:setVisible(true)
        TextureManager:updateButtonNormal(self._btnTouch, url1)
        TextureManager:updateButtonPressed(self._btnTouch, url4)

    end
end


function UIChatBarrage:resetValue(chatText,color)
   local chatParams = ComponentUtils:getChatItem(chatText,0.6)
   local chatItem  = RichTextMgr:getInstance():getRich(chatParams, 350, color, nil, nil, RichLabelAlign.left_top)
   chatItem:setScale(0.9)
   chatItem:setAnchorPoint(0,0)
   chatItem:setPosition(90,5)
   return chatItem   
end


function UIChatBarrage:setValue(node,chatText,color)
  local chatParams = ComponentUtils:getChatItem(chatText,0.6)
  node:setData(chatParams,350,color)
  --node:setScale(0.9)
  node:setAnchorPoint(0,0)
  node:setPosition(90,5)
end