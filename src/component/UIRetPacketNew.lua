UIRetPacketNew = class("UIRetPacketNew", BasicComponent)

function UIRetPacketNew:ctor(parent, panel)
    UIRetPacketNew.super.ctor(self)
    local uiSkin = UISkin.new("UIRetPacketNew")
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
    layout:setPosition(winSize.width/2, winSize.height/2)
    layout:setTouchEnabled(true)
    parent:addChild(layout)
    uiSkin:setParent(layout)
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel

    local touchPanel = self:getChildByName("touchPanel")
    ComponentUtils:addTouchEventListener(touchPanel, self.hide, nil,self)

    -- require "modules.chat.rich.RichTextMgr"
end

--TODO 外部还未调用finalize 
function UIRetPacketNew:finalize()
    --[[
    if self.richText ~= nil then
        self.richText:dispose()
        self.richText = nil
    end
    --]]
    self._uiSkin:finalize()
    self._uiSkin = nil
    UIRetPacketNew.super.finalize(self)
end

function UIRetPacketNew:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UIRetPacketNew:show(data)
	self._parent:setVisible(true)
    self:initView(data)
end

function UIRetPacketNew:hide()
    self._parent:stopAllActions()
	self._parent:setVisible(false)
end

function UIRetPacketNew:render(item, data)
    local isBestHand = data.isBestHand or false
    local playerIcon = item:getChildByName("playerIcon") --玩家头像
    local playerNameLab = item:getChildByName("playerNameLab") --玩家名字
    local timeLab = item:getChildByName("timeLab") --时间展示
    local numLab = item:getChildByName("numLab") --数值
    local unitLab = item:getChildByName("unitLab") --单位
    local bestHandPanel = item:getChildByName("bestHandPanel") --手气最佳

    local playerName = data.name
    local time = TimeUtils:setTimestampToString4(data.time)
    local numValue = data.reward.num
    local unit
    if tonumber(data.reward.typeid) == 201 then
        unit = TextWords:getTextWord(524) --银币
    elseif tonumber(data.reward.typeid) == 206 then
        unit = TextWords:getTextWord(525) --元宝
    end
   
    local iconId = data.icon
    local headInfo = {}
    headInfo.icon = iconId
    headInfo.playerId = data.playerId

    local head = UIHeadImg.new(playerIcon, headInfo, self)
    head:setScale(0.8)

    if isBestHand then
        bestHandPanel:setVisible(true)
    else
        bestHandPanel:setVisible(false)
    end
    playerNameLab:setString(playerName)
    timeLab:setString(time)
    numLab:setString(numValue)
    unitLab:setString(unit)
end

--判断谁是最佳手气 并进行排序
--limitNum  该红包含有的红包个数
local function judgeBestHand(param,limitNum)
    local nowGetPersonNum = #param
    local bestHand
    for k,v in pairs(param) do
        if nowGetPersonNum < limitNum then
            v.isBestHand = false
        else
            if not bestHand then
                bestHand = v
                v.isBestHand = true
            else
                if v.reward.num > bestHand.reward.num then 
                    bestHand.isBestHand = false
                    v.isBestHand = true
                    bestHand = v
                elseif v.reward.num == bestHand.reward.num then 
                    if v.time < bestHand.time then
                        bestHand.isBestHand = false
                        v.isBestHand = true
                        bestHand = v
                    else
                        v.isBestHand = false
                        bestHand.isBestHand = true
                    end
                elseif v.reward.num < bestHand.reward.num then 
                    v.isBestHand = false
                end 
            end 
        end  
    end
end

local function sortFunc(a,b)
    return a.time < b.time
end 


function UIRetPacketNew:initView(data)
    ---[[
    local redBagConfigId --红包配置表id
    local selfGetMoney
    local getRedBagPlayerList = {}
    local personRedPacketInfo
    local errorCode = 0

    if data then
        redBagConfigId = data.id 
        selfGetMoney = data.reward and data.reward.num
        getRedBagPlayerList = data.info or {}
        personRedPacketInfo = data.personRedBagInfo
        errorCode = data.errorCode
    end
    -- print("jiang ***************88 selfGetMoney",selfGetMoney,type(selfGetMoney))
    -- print(data.reward)

    local redBagInfo = ConfigDataManager:getRedPacketInfoById(redBagConfigId)
    local numLimit = redBagInfo.numLimit --红包个数
    local blessingWord = redBagInfo.describes
    local sumInfo = StringUtils:jsonDecode(redBagInfo.sum)
    local moneyUnit = sumInfo[2] --单位
    local allMoney = sumInfo[3] --红包总数
    local unit
    --后面需要拓展单位  在这里处理
    if tonumber(moneyUnit) == 201 then
        unit = TextWords:getTextWord(524) --银币
    elseif tonumber(moneyUnit) == 206 then
        unit = TextWords:getTextWord(525) --元宝
    end

    local fromPlayerName = personRedPacketInfo.fromName

    local headInfo = {}
    headInfo.icon = personRedPacketInfo.playerIcon
    headInfo.playerId = personRedPacketInfo.playerId

    local mianPanel = self:getChildByName("mainPanel/bg_1")

    local arrowUp = self:getChildByName("mainPanel/bg_1/arrowUp")
    ComponentUtils:addTouchEventListener(arrowUp,self.clipArrowUp,nil,self)

    local arrowDown = self:getChildByName("mainPanel/bg_1/arrowDown")
    ComponentUtils:addTouchEventListener(arrowDown,self.clipArrowDown,nil,self)

    local infoImg = self:getChildByName("mainPanel/bg_1/infoImg") --用于展示红包来自于玩家头像
    ComponentUtils:addTouchEventListener(infoImg,self.showPlayerInfo,nil,self)

    local fromPlayerIcon = UIHeadImg.new(infoImg, headInfo, self)

    local redFromLab = self:getChildByName("mainPanel/bg_1/redFromLab") --红包来自于玩家名称
    redFromLab:setString(string.format(TextWords:getTextWord(391004),fromPlayerName))

    local blessingLab = self:getChildByName("mainPanel/bg_1/blessingLab") --祝福语
    blessingLab:setString(blessingWord)

    local resultLab = self:getChildByName("mainPanel/bg_1/resultLab") --结果展示
    local getMoneyLab = self:getChildByName("mainPanel/bg_1/getMoneyLab")
    local unitLab_EX = self:getChildByName("mainPanel/bg_1/unitLab")

    local redWordsLab = self:getChildByName("mainPanel/bg_1/redWordsLab") --异常文字

    local isGet --是否抢到
    if selfGetMoney and tonumber(selfGetMoney) > 0 then
        isGet = true
    else
        isGet = false
        ---[[
        --容错处理(根据服务端所给的列表信息判断自己有没有抢到钱)
        local proxy = self._panel:getProxy(GameProxys.Role)
        local myName = proxy:getRoleName()
        for k,v in pairs(getRedBagPlayerList) do
            if v.name == myName then
                selfGetMoney = v.reward.num
            end 
        end
        --]]
        if selfGetMoney and selfGetMoney > 0 then
            isGet = true
        end 
    end
    judgeBestHand(getRedBagPlayerList,numLimit)
    table.sort(getRedBagPlayerList,sortFunc)
    --抢到
    if isGet then
        redWordsLab:setVisible(false)
        resultLab:setVisible(true)
        getMoneyLab:setVisible(true)
        unitLab_EX:setVisible(true)
        resultLab:setString(TextWords:getTextWord(391006))
        getMoneyLab:setString(selfGetMoney)
        unitLab_EX:setString(unit)
        unitLab_EX:setColor(ColorUtils:color16ToC3b("#5e5c5c"))
        unitLab_EX:setPositionX(getMoneyLab:getPositionX() + getMoneyLab:getContentSize().width )
    --未抢到
    else
        resultLab:setVisible(false)
        getMoneyLab:setVisible(false)
        unitLab_EX:setVisible(false)

        redWordsLab:setVisible(true)
        if errorCode == -5 then 
            redWordsLab:setString(TextWords:getTextWord(391012))
        else
            redWordsLab:setString(TextWords:getTextWord(391008))
        end 
    end 

    local redInfoLab = self:getChildByName("mainPanel/bg_1/detailInfoBg/redInfoLab") --红包信息展示
    redInfoLab:setString(string.format(TextWords:getTextWord(391007),numLimit,allMoney,unit))--多少个红包多少钱

    local btn_close = self:getChildByName("mainPanel/bg_1/btn_close") --关闭
    ComponentUtils:addTouchEventListener(btn_close,self.hide,nil,self)

    local listView = self:getChildByName("mainPanel/bg_1/listview_info")
    self:renderListView(listView, getRedBagPlayerList, self, self.render)
end 

function UIRetPacketNew:removeFromParent()
    self:finalize()
end

function UIRetPacketNew:clipArrowUp()
    --无实际作用  箭头只表示列表可以上下拉动
end 

function UIRetPacketNew:clipArrowDown()
    --无实际作用  箭头只表示列表可以上下拉动
end

function UIRetPacketNew:showPlayerInfo()
    -- print("jiang *******************  showPlayerInfo")
end 