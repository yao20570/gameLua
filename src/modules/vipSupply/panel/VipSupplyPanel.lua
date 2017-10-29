
--VIP特供 
--edited by fwx 11.9

VipSupplyPanel = class("VipSupplyPanel", BasicPanel)
VipSupplyPanel.NAME = "VipSupplyPanel"

local MAX_DAY = 5  --最大天数，改这里

function VipSupplyPanel:ctor(view, panelName)
	VipSupplyPanel.super.ctor(self, view, panelName,700)
	 
end

function VipSupplyPanel:finalize()

    for i,btn in ipairs(self._mDayBtn) do
        if btn.btnEff then
            btn.btnEff:finalize()
            btn.btnEff = nil
        end
    end
	VipSupplyPanel.super.finalize(self)
end

function VipSupplyPanel:initPanel()
  	VipSupplyPanel.super.initPanel(self)
  	self:setTitle(true, "activity", true)

    self._vipProxy = self:getProxy(GameProxys.Vip)
    self._vipSupplyProxy = self:getProxy(GameProxys.VipSupply)
  	self._panel = self:getChildByName("Panel_1")
    self._middlePanel = self._panel:getChildByName("middlePanel")
    self._middlePanel:setTouchEnabled(false)
    local downPanel = self._panel:getChildByName("downPanel")

    --引用
    self.receiveTimes = {}
    self._mDayBtn = {}
    --self._imgClick = self._middlePanel:getChildByName("img_mouse")
    --self._vipBar = self._middlePanel:getChildByName("vipBar")
    --self._dayText = downPanel:getChildByName("dayText")
    self._payBtn = downPanel:getChildByName("payBtn")--充值
    self._sureBtn = downPanel:getChildByName("sureBtn")--领取
    for i=1, MAX_DAY do
        local dayBtn = self._middlePanel:getChildByName("dayBtn"..i)
        if dayBtn then
            dayBtn.type = i
            self:addTouchEventListener(dayBtn,self.onDayBtn)
            table.insert( self._mDayBtn, dayBtn )
        end
    end
    self:addTouchEventListener(self._payBtn, self.onTouchPayBtn)
    self:addTouchEventListener(self._sureBtn, self.onTouchSureBtn)


    --状态
    self._nCurIndex = nil    --当前选中第几按钮 
    self._nCurState = 0    --当前领取状态  --0 表示不可领取 1 表示未领取 2表示已领取）
end


--=======================================================
--事件
--=======================================================
function VipSupplyPanel:onDayBtn(sender)
    self._nCurIndex = sender.type  --当前选中
    self:renderBtnState()
    self:renderItem()
end

function VipSupplyPanel:onTouchPayBtn(sender)
    ModuleJumpManager:jump(ModuleName.RechargeModule, "RechargePanel")
end

function VipSupplyPanel:onTouchSureBtn(sender)
    if self._nCurState==2 then  --已领取
        self:showSysMessage( self:getTextWord(230142) )
    elseif self._nCurState==0 then  --不可领取
        self:showSysMessage( self.sDayText or "" )--self:getTextWord(230141) )
    else
        local nMyVip = self._vipProxy:getVipLevel() or 0
        if nMyVip<3 then
            local str = string.format( self:getTextWord(230140), nMyVip )
            self:showMessageBox( str, function()
              self:reqGetGift()
            end )
        else
          self:reqGetGift()
        end
    end
end
function VipSupplyPanel:reqGetGift()
    local data = {receiveDay = self._nCurIndex}
    self._vipSupplyProxy:onTriggerNet380001Req( data )
end

function VipSupplyPanel:onHideHandler()
    self:dispatchEvent(VipSupplyEvent.HIDE_SELF_EVENT)
end



--
--=======================================================
--刷新 
--=======================================================
function VipSupplyPanel:onShowHandler()
    self._nCurIndex = nil

  	--刷新数据
  	self:renderPanel()

    --刷新物品
    self:renderItem()
end

--
function VipSupplyPanel:renderPanel()

    local nMyVip = self._vipProxy:getVipLevel() or 0
    local isVip = nMyVip>0

    local vipSupplyInfo = self._vipSupplyProxy:getVipSupplyInfo()
    self.receiveTimes = vipSupplyInfo.receiveTimes or {}


    --按钮们
    for i,btn in ipairs(self._mDayBtn) do
        if btn.btnEff == nil then
            local size = btn:getContentSize()
            btn.btnEff = self:createUICCBLayer("rgb-vip-anniu", btn)
            btn.btnEff:setPosition(size.width * 0.5, size.height * 0.5)
            btn.btnEff:setVisible(false)
        end
    end
    self:renderBtnState()

    --倒计时
  	local topPanel = self._panel:getChildByName("topPanel")
    local timeTxt = topPanel:getChildByName("timeTxt")
   	local lastTimeTxt = topPanel:getChildByName("lastTimeTxt")--时间
    local lastTimeTxt_0 = topPanel:getChildByName("lastTimeTxt_0")
    lastTimeTxt:stopAllActions()

    timeTxt:setVisible( not isVip )
    lastTimeTxt:setVisible( not isVip )
    lastTimeTxt_0:setVisible( not isVip )
    if not isVip then
        lastTimeTxt:runAction( cc.RepeatForever:create( cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                local time = self._vipSupplyProxy:getTime() or 0
                time = math.ceil( time or 0 )
                lastTimeTxt:setString(TimeUtils:getStandardFormatTimeString(time,true))
            end)
        )))
    end
    --时间状态
    self._payBtn:setVisible( not isVip )
    self._sureBtn:setVisible( isVip )
end

function VipSupplyPanel:renderBtnState()

    if self._nCurIndex==nil then  --设置默认位置
        local tmpIndex = 1
        for i,state in ipairs(self.receiveTimes) do
            if state>0 then
                tmpIndex = i
                if state==1 then
                    break
                end
            end
        end
        self._nCurIndex = tmpIndex
        --self._vipBar:setPercent( self._nCurIndex*20-10 )
    end

    for i,btn in ipairs(self._mDayBtn) do

        local state = self.receiveTimes[i] or 0   --0 表示不可领取 1 表示未领取 2表示已领取）

        --if state>0 then
        --    self._vipBar:setPercent( i*20-10 )
        --end
        if self._nCurIndex==i then
            self._nCurState = state
        end
        local stateImg = btn:getChildByName("Image_1")

        local stateText = btn:getChildByName("Image_45")
        local strKey = state==1 and 230144 or 230143
        local c3bColor = state==2 and cc.c3b(155,155,155) or cc.c3b(255,255,255)
        btn:setColor( c3bColor )
       
        if state == 1 then 
            stateText:loadTexture("images/vipSupply/14.png",ccui.TextureResType.plistType)  --艺术字
            btn.btnEff:setVisible(true)
        elseif state ==2 then 
            stateText:loadTexture("images/vipSupply/15.png",ccui.TextureResType.plistType)  --艺术字
            btn.btnEff:setVisible(false)
        end
        stateImg:setVisible( self._nCurIndex==i )
        --if self._nCurIndex==i then
        --    --self._imgClick:setPositionX( btn:getPositionX() )
        --    self._btnEff:setPosition( btn:getPositionX(), btn:getPositionY() )
        --end
    end

    local textKey = self._nCurState==2 and 18000 or 18001
    local sBtnText = self:getTextWord(textKey)
    self.sDayText = string.format( self:getTextWord(230145), self._nCurIndex )

    self._sureBtn:setColor( self._nCurState==1 and cc.c3b(255,255,255) or cc.c3b(155,155,155) )
    self._sureBtn:setTitleText( sBtnText or "" )
    --self._dayText:setString( sDayText )
    --self._dayText:setVisible( false )--self._nCurState==0 )
end

function VipSupplyPanel:renderItem()
    local rewardConf = ConfigDataManager:getConfigById(ConfigData.SupplyRewardConfig, self._nCurIndex)
    if not rewardConf then
        return
    end
    local data = {}
    local strArr = StringUtils:jsonDecode( rewardConf.reward )

    for i=1,6 do
        local container = self._middlePanel:getChildByName("propImg"..i)
        if not container then
            break
        end
        local strData = strArr[i]
        if strData then
            local iconData = {
                power = strData[1],
                typeid = strData[2],
                num = strData[3],
            }
            if not container.icon then
                container.icon = UIIcon.new(container, iconData, true, self, nil, true)
            else
                container.icon:updateData( iconData )
            end
            container:setVisible( true )
        else
            container:setVisible( false )
        end
    end
end

