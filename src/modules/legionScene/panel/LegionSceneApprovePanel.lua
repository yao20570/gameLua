-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 审批
--  */

LegionSceneApprovePanel = class("LegionSceneApprovePanel", BasicPanel)
LegionSceneApprovePanel.NAME = "LegionSceneApprovePanel"

function LegionSceneApprovePanel:ctor(view, panelName)
    LegionSceneApprovePanel.super.ctor(self, view, panelName, 760)
    
    self:setUseNewPanelBg(true)
end

function LegionSceneApprovePanel:finalize()
    LegionSceneApprovePanel.super.finalize(self)
end

function LegionSceneApprovePanel:initPanel()
	LegionSceneApprovePanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(3023))
    self._legionProxy = self:getProxy(GameProxys.Legion)

    local capacityTxt = self:getChildByName("mainPanel/titleImg/capacityTxt")
    capacityTxt:setString(self:getTextWord(136))
end

function LegionSceneApprovePanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneApprovePanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    --打开界面，实时请求审核列表
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220202Req()
end

--审核列表更新
function LegionSceneApprovePanel:onUpdateApplyInfos()
    local applyInfos = self._legionProxy:getApplyInfos()

    self._applyInfos = applyInfos

    local curNum = #applyInfos
    local maxNum = 20
    local Label_26 = self:getChildByName("mainPanel/Label_26")
    Label_26:setString(string.format("(%d/%d)", curNum,maxNum))

    local approveListView = self:getChildByName("mainPanel/approveListView")
    self:renderListView(approveListView,applyInfos, self, self.renderItemPanel)
end


function LegionSceneApprovePanel:renderItemPanel(itemPanel, info)
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local levelTxt = itemPanel:getChildByName("levelTxt")
    local capacityTxt = itemPanel:getChildByName("capacityTxt")
    local passBtn = itemPanel:getChildByName("passBtn")
    local refuseBtn = itemPanel:getChildByName("refuseBtn")
    
    nameTxt:setString(info.name)
    -- levelTxt:setString(info.level)
    levelTxt:setString(string.format(self:getTextWord(3200), info.level))
    capacityTxt:setString(StringUtils:formatNumberByK(info.capacity,0))
    
    passBtn.info = info
    refuseBtn.info = info

    if passBtn.isAddEvent ~= true then
        passBtn.isAddEvent = true
        self:addTouchEventListener(passBtn, self.onPassBtnTouch)
        self:addTouchEventListener(refuseBtn, self.onRefuseBtnTouch)
    end
end

function LegionSceneApprovePanel:onPassBtnTouch(sender)
  --TODO 通过
    local info = sender.info
    
    local data = {}
    data.id = info.id
    data.type = 1
    
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220203Req(data)
end

function LegionSceneApprovePanel:onRefuseBtnTouch(sender)
  --TODO 拒绝
    local info = sender.info

    local data = {}
    data.id = info.id
    data.type = 2

    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220203Req(data)
end


function LegionSceneApprovePanel:registerEvents()
	LegionSceneApprovePanel.super.registerEvents(self)
	
	-- local closeBtn = self:getChildByName("mainPanel/closeBtn")
    -- self:addTouchEventListener(closeBtn, self.onCloseBtnTouch)
    
    local clearBtn = self:getChildByName("mainPanel/clearBtn")
    self:addTouchEventListener(clearBtn, self.onClearBtnTouch)
end

function LegionSceneApprovePanel:onCloseBtnTouch(sender)
    self:hide()
end

--清空删除列表
function LegionSceneApprovePanel:onClearBtnTouch(sender)
    if self._applyInfos == nil or #self._applyInfos == 0 then
        self:showSysMessage(self:getTextWord(3011))
        return
    end

    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220204Req({})

    self:onCloseBtnTouch(sender)
end





