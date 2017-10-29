-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-01-25 17:57:42
--  * @Description: 探险重播
--  */
LimitExpReplayPanel = class("LimitExpReplayPanel", BasicPanel)
LimitExpReplayPanel.NAME = "LimitExpReplayPanel"

function LimitExpReplayPanel:ctor(view, panelName)
    LimitExpReplayPanel.super.ctor(self, view, panelName, 700)
    
    self:setUseNewPanelBg(true)
end

function LimitExpReplayPanel:finalize()
    LimitExpReplayPanel.super.finalize(self)
end

function LimitExpReplayPanel:initPanel()
	LimitExpReplayPanel.super.initPanel(self)
	self:setTitle(true, self:getTextWord(4100))
end

function LimitExpReplayPanel:onShowHandler(data)
    -- body
    self:onShowReplayList(data)
end

-- -- 界面更新
function LimitExpReplayPanel:onShowReplayList(info)
	local againPanel = self:getChildByName("againPanel")
	againPanel:setVisible(true)

	-- 初始化
	local nameLv = againPanel:getChildByName("nameLv")
	local labLv = againPanel:getChildByName("labLv")--time_key
	local time_key = againPanel:getChildByName("time_key")
	local time = againPanel:getChildByName("time")
	local repeatBtn = againPanel:getChildByName("repeatBtn")
	nameLv:setString(self:getTextWord(4103))
	time:setString(self:getTextWord(4104))
	NodeUtils:alignNodeL2R(time_key,time)
	-- repeatBtn:setEnabled(false)
	-- repeatBtn:setBright(false)
	NodeUtils:setEnable(repeatBtn, false)
	
	for index=1,3 do
		local nameLv = againPanel:getChildByName("nameLv"..index)
		local time = againPanel:getChildByName("time"..index)
		local repeatBtn = againPanel:getChildByName("repeatBtn"..index)
		local time_key = againPanel:getChildByName("time_key_"..index)
		local labLv = againPanel:getChildByName("labLv"..index)
		nameLv:setString(self:getTextWord(4103))
		time:setString(self:getTextWord(4104))
		labLv:setString("")
		NodeUtils:alignNodeL2R(time_key,time)
		-- repeatBtn:setEnabled(false)
		-- repeatBtn:setBright(false)
		NodeUtils:setEnable(repeatBtn, false)
	end


	local function updateItem(nameLv,time,repeatBtn,data,labLv,time_key)
		-- print("通关 time = "..data.time..",lv = "..data.lv)
		repeatBtn.data = data
		if data.lv <= 0 then
			nameLv:setString(self:getTextWord(4103))
			time:setString(self:getTextWord(4104))
			labLv:setString("")
			-- repeatBtn:setEnabled(false)
			-- repeatBtn:setBright(false)
			NodeUtils:setEnable(repeatBtn, false)
			-- repeatBtn:setColor(ColorUtils.forbidColor)

		else
			-- nameLv:setString(data.name.."　Lv."..data.lv)
			nameLv:setString(data.name)
			labLv:setString("Lv."..data.lv)
	
			NodeUtils:alignNodeL2R(nameLv,labLv)

			time:setString(data.time)
			NodeUtils:alignNodeL2R(time_key,time)

			-- repeatBtn:setEnabled(true)
			-- repeatBtn:setBright(true)
			NodeUtils:setEnable(repeatBtn, true)
			-- repeatBtn:setColor(ColorUtils.wordWhiteColor)
		end
		if repeatBtn.isAdd == true then
			return
		end
		repeatBtn.isAdd = true
		self:addTouchEventListener(repeatBtn,self.onAgainBtnReq)
	end

	local nameLv = againPanel:getChildByName("nameLv")
	local time = againPanel:getChildByName("time")
	local repeatBtn = againPanel:getChildByName("repeatBtn")
	updateItem(nameLv,time,repeatBtn,info.firstPass,labLv,time_key)


	local index = 1
	for _,v in pairs(info.nearPass) do
		if index == 4 then
			break
		end
		local nameLv = againPanel:getChildByName("nameLv"..index)
		local labLv = againPanel:getChildByName("labLv"..index)--labLv2
		local time_key = againPanel:getChildByName("time_key_"..index)
		local time = againPanel:getChildByName("time"..index)
		local repeatBtn = againPanel:getChildByName("repeatBtn"..index)
		updateItem(nameLv,time,repeatBtn,v,labLv,time_key)
		index = index + 1
	end
	-- local closeBtn = againPanel:getChildByName("closeBtn")
	-- if closeBtn.isAdd ~= true then
	-- 	closeBtn.isAdd = true
	-- 	local function callback()
	-- 		-- againPanel:setVisible(false)
	-- 	end
	-- 	self:addTouchEventListener(closeBtn,callback)
	-- end
end

function LimitExpReplayPanel:onAgainBtnReq(sender)
	local data = sender.data
	local battleId = sender.data.battleId
	print("sender.data.battleId = "..battleId)
	self:dispatchEvent(LimitExpEvent.AGAINBTN_REQ, {battleId = battleId})
end

function LimitExpReplayPanel:registerEvents()
    LimitExpReplayPanel.super.registerEvents(self)
    
    -- local closeBtn = self:getChildByName("againPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouche)
end

function LimitExpReplayPanel:onCloseBtnTouche(sender)
    self:hide()
end