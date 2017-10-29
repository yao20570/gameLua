LegionWelfareWarAllotPanel = class("LegionWelfareWarAllotPanel", BasicPanel)
LegionWelfareWarAllotPanel.NAME = "LegionWelfareWarAllotPanel"
function LegionWelfareWarAllotPanel:ctor(view, panelName)
    LegionWelfareWarAllotPanel.super.ctor(self, view, panelName, 800)

    self._openTypeId = nil   --记录，正在分配的物品id

    self._itemData = {}      --引用，正在分配的物品数据
    self._nAllotNum = 0      --记录，点击确定后做记录，剩余可分配总数量
    self._selectNum = 0      --记录，已选中玩家id
    self._memberInfoList = {}
    
    self._factNumLower=false         --记录  选中最低玩家的可分配数量           这个用来显示是否弹出确认框
    self._factRealNum={}         --记录  选中玩家的实际分配数量         这个用来显示真实数据
    self:setUseNewPanelBg(true)
end

function LegionWelfareWarAllotPanel:finalize()
    LegionWelfareWarAllotPanel.super.finalize(self)
    self._itemData = {}
    self._memberInfoList = {}
    self._nAllotNum = 0
    self._selectNum = 0
end

--初始化
function LegionWelfareWarAllotPanel:initPanel()
    LegionWelfareWarAllotPanel.super.initPanel(self)

    self:setTitle( true, TextWords:getTextWord(3030) )

    local upPanel = self:getChildByName("upPanel")
    local moveParent = upPanel:getChildByName("container")

    --btn
    self._m_checkAll = upPanel:getChildByName("CheckBox_all")
    self._listView = upPanel:getChildByName("ListView")

    --createMoveBtn
    local prop = {
        ["moveCallobj"] = self,
        ["count"] = 1,
        ["moveCallback"] = self.onCheckBoxfn,
    }
    self._m_uiMoveBtn = UIMoveBtn.new( moveParent, prop)


end

--
function LegionWelfareWarAllotPanel:registerEvents()
    LegionWelfareWarAllotPanel.super.registerEvents(self)

    --ok fn
    local m_okbtn = self:getChildByName("upPanel/Button_detail")
    self:addTouchEventListener( m_okbtn, self.onClickOkfn )

    --全选
    self._m_checkAll:addEventListener( function()
        local state = self._m_checkAll:getSelectedState()
        self:renderListState( state )
    end)
end

function LegionWelfareWarAllotPanel:onShowHandler(data)
    if self:isModuleRunAction() then
        return
    end

    local legionProxy = self:getProxy(GameProxys.Legion)
    local welfareInsfos = legionProxy:getWelfareInfo()

    local data=welfareInsfos.panelInfo
    self._welfareLv=data.welfarelv
    local configData = ConfigDataManager:getConfigDataBySortId(ConfigData.WelfareLvConfig)
    self.limitMax=configData[self._welfareLv]["limitTimes"]       

    LegionWelfareWarAllotPanel.super.onShowHandler(self)
    self:updateListView()
end 

function LegionWelfareWarAllotPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionWelfareWarAllotPanel:updateListView()
    self._listView:jumpToTop()
    
    self._listItems = {}

    local legionProxy = self:getProxy(GameProxys.Legion)
    local memberInfoList = legionProxy:getMemberInfoList()
    memberInfoList = legionProxy:getSortedList(memberInfoList,1)

    --for _,memberinfo in pairs (memberInfoList) do
    --print("##########^^^^^######"..memberinfo.name.."######"..memberinfo.welfareTimes)
    --end


    --print("####################"..)

    self._memberInfoList = {}

    -- 显示勾选状态
    local state = self._m_checkAll:getSelectedState()
    for k,v in pairs(memberInfoList) do
        v.state = state
        self._memberInfoList[k] = v
    end

    self:renderListView( self._listView, self._memberInfoList, self, self.renderItemPanel )

    -- --新成员进来时，重设state
    -- if #self._tCheckIdList>0 then
    --     -- local m_items = self._listView:getItems()
    --     local m_items = self._listItems
    --     for i,m_item in ipairs(m_items) do
    --         m_check = m_item:getChildByName("CheckBox_ok")
    --         m_check:setSelectedState( false )
    --         for _,id in ipairs(self._tCheckIdList) do
    --             if id==m_item.data.id then
    --                 m_check:setSelectedState( true )
    --             end
    --         end
    --     end
    -- end
    --self:renderListState()
end

--=====================================================
--刷新
--=====================================================
function LegionWelfareWarAllotPanel:updateInfo( data )
    self._m_checkAll:setSelectedState( false )
    self:renderListState(false)

    self._itemData = data
    self._openTypeId = data.type

    local _data = {
        power = data.power or 0,
        typeid = data.type or 0,
        num = data.number or 0,
    }

    local m_total = self:getChildByName("upPanel/Label_total_num")
    m_total:setString( _data.num )
    self._m_uiMoveBtn:setEnterCount( _data.num,true )

    --icon
    if not self._m_icon then
        local imgIcon = self:getChildByName("upPanel/Image_icon_0")
        self._m_icon = UIIcon.new(imgIcon, _data, true, self)
    else
        self._m_icon:updateData( _data )
    end

    --self:updateListView()
end

function LegionWelfareWarAllotPanel:updateNumber( number )
    if number==0 then
        self:hide()
    elseif self._itemData then
        self._itemData.number = number
        self:updateInfo( self._itemData )
    end
end

function LegionWelfareWarAllotPanel:renderItemPanel( m_item, data, index )
    local m_name = m_item:getChildByName("Label_name")
    local m_icon = m_item:getChildByName("Image_icon")
    local m_level = m_item:getChildByName("Label_lv")
    local m_power = m_item:getChildByName("Label_power")                                         --7184 国力值改为每日领取福利数上限
    local m_check = m_item:getChildByName("CheckBox_ok")
    local m_Label = m_item:getChildByName("Label_188")
    local m_touch = m_item:getChildByName("Button_isTouch")
    m_Label:setString(TextWords:getTextWord(380007))

    local m_date = m_item:getChildByName("Label_date")
    m_date:setVisible(true)
  
    --m_date  当前领取福利次数
    local data_date = data.welfareTimes
    m_date:setString(self.limitMax-data_date)                                                                       --当前的领取数

    if data_date >= self.limitMax then
	    data_date = self.limitMax
	    m_date:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Red))
    else
	    m_date:setColor(ColorUtils:color16ToC3b(ColorUtils.commonColor.Green))
    end
 
    NodeUtils:alignNodeL2R(m_Label,m_date)
    NodeUtils:alignNodeL2R(m_date,m_power)

     --name level power
    local lv = data.level or 0
    m_name:setString( data.name or "" )
    m_level:setString( string.format("Lv.%d", lv) )
    m_power:setString( "/"..StringUtils:formatNumberByK(self.limitMax, 0) )

    NodeUtils:alignNodeL2R(m_name,m_level,3)

    --head
    local tHeadInfo = {
        icon = data.iconId,
        pendant = data.pendantId,
        preName1 = "headIcon",
        preName2 = "headPendant",
        isCreatPendant = true,
        playerId = rawget(data, "id"),
        --isCreatButton = false,
    }
    if m_item.head == nil then
        m_item.head = UIHeadImg.new( m_icon, tHeadInfo, self )
    else
        m_item.head:updateData( tHeadInfo )
    end

    -- 显示勾选状态
    local state = data.state
    if state then
        m_check:setSelectedState( state )
    end

    m_item.data = data
    m_check.data = data

    data.joinTimeEnough = data.joinTimeEnough                                                            --加入同盟是否满足24小时判断
    if data.joinTimeEnough <= 0 then 
        m_touch:setVisible(true)
    else
        m_touch:setVisible(false)
    end
    self:addTouchEventListener(m_touch,self.onCannotTouch)
    self:addTouchEventListener(m_check,self.onItemCheckTouch)
end

function LegionWelfareWarAllotPanel:onCannotTouch(sender)
    self:showSysMessage(TextWords:getTextWord(380008))
end

function LegionWelfareWarAllotPanel:onItemCheckTouch(sender)
    local data = sender.data
    local state = sender:getSelectedState()
    state = not state
    for k,v in pairs(self._memberInfoList) do
        if v.id == data.id then
            self._memberInfoList[k].state = state
            break
        end
    end

    self._m_checkAll:setSelectedState( false )
    self:renderListState()    
end

--刷新状态
function LegionWelfareWarAllotPanel:renderListState( state )
    local m_check, nCheck = nil, 0
    local m_items = self._listView:getItems()
    for k,v in pairs(self._memberInfoList) do
        if state ~= nil then
            if v.joinTimeEnough > 0 then      --判断加入同盟时间是否超过24小时
            v.state = state
            else
            v.state = false 
            end
            self._memberInfoList[k].state = v.state
        end

        if  v.state then
            nCheck = nCheck + 1
        end
    end
    self._selectNum = nCheck

    local m_people = self:getChildByName("upPanel/Label_people_num1")
    m_people:setString( nCheck )

    --for i,m_item in ipairs(m_items) do
    --    m_check = m_item:getChildByName("CheckBox_ok")
    --    if nil~=state then
    --        m_check:setSelectedState( state )
    --    end
    --end
    local  isAll = true
    for i,m_item in ipairs (m_items) do
        for j,memberinfo in ipairs (self._memberInfoList) do
            local name = m_item:getChildByName("Label_name"):getString()
            local memberName= memberinfo.name
            if name == memberName then
                   local m_check = m_item:getChildByName("CheckBox_ok")
                   if   state ~=nil  then
                        m_check:setSelectedState(memberinfo.state)
                        if memberinfo.state == false then
                        isAll = false
                        end
                   end
            end
        end
    end

    if isAll == false and state == true then
    self:showSysMessage(TextWords:getTextWord(380011))
    end

    --uiMoveBtn
    local nAllotNum, nPeople = self:getEveryoneAllot()
    nAllotNum = math.max( 1, nAllotNum )
    nAllotNum = nPeople==0 and self._itemData.number or nAllotNum
    self._m_uiMoveBtn:setEnterCount( nAllotNum,true )
end

--计算每人最终可分配
function LegionWelfareWarAllotPanel:getEveryoneAllot()
    local nTotalNum = self._itemData.number or 0
    local nPeople = self._selectNum
    local nAllotNum = math.floor( nTotalNum/nPeople ) --每人最终可分配
    if nTotalNum==0 or nPeople==0 then
        nAllotNum = 0
    end
    return nAllotNum, nPeople
end


--===================================================
--事件
--===================================================
function LegionWelfareWarAllotPanel:onCheckBoxfn( nNum )
    if not self._m_uiMoveBtn then
        return
    end
    nNum = nNum or self:getCurAllotNumber()

    -- set m_num2
    local str = string.format("+%d", tonumber(nNum))
    local m_num2 = self:getChildByName("upPanel/Label_people_num2")
    m_num2:setString( str )

    local nTotalNum = self._itemData.number or 0
    self._nAllotNum = nTotalNum - self._selectNum * nNum
end

function LegionWelfareWarAllotPanel:onClickOkfn( sender )
    self._factNumLower = false                                                                      --每次提交都重新判断是否有超额item
    local nAllotNum, nPeople = self:getEveryoneAllot()
    if nPeople==0 then
        self:showSysMessage( TextWords[3031] )
    elseif nAllotNum<1 then
        self:showSysMessage( TextWords[3032] )
    else
        
        local nCurAllotNumber = self:getCurAllotNumber()                                            --当前没人的分配数量
        local selectList = {}
        for k,v in pairs(self._memberInfoList) do
            if v.state then
                table.insert( selectList, v.id )
                local num =self.limitMax -v.welfareTimes 
                if num < nCurAllotNumber then                                                       --只要有一个超出 就要弹框
                self._factNumLower = true
                end
            end
        end

        local data = {}
        data.playerList = selectList

        for _,player in pairs(selectList) do
            print("#####################################   "..player)
        end

        data.walfareInfo = {
            type = self._itemData.type or 0,
            power = self._itemData.power or 0,
            number = nCurAllotNumber or 0,
        }
       self._upData=data
       if self._factNumLower == true  then
       --调弹框
       print("---------------------factNumLower true")
       self:showMessageBoxData()
       else
       print("---------------------factNumLower false")
       self.view:dispatchEvent( LegionWelfareEvent.WELFARE_ALLOT_REQ, data ) --请求分配战事福利
       --local legionProxy = self:getProxy(GameProxys.Legion)
       --legionProxy:onTriggerNet220016Req()
       end
    end
end

function LegionWelfareWarAllotPanel:showMessageBoxData()
	self:showMessageBox(TextWords:getTextWord(380009),handler(self, self.onOkBtn))
    print("二次 弹框 调用！")
end

function LegionWelfareWarAllotPanel:onOkBtn()
    if self._upData ~=nil then
      self:welfareReq(self._upData) 
      --legionProxy:onTriggerNet220016Req()
    end
end

function LegionWelfareWarAllotPanel:welfareReq(data)
    self.view:dispatchEvent( LegionWelfareEvent.WELFARE_ALLOT_REQ, data ) --请求分配战事福利
end

function LegionWelfareWarAllotPanel:getCurUseTypeId()
    return self._openTypeId
end

--每人分配数量
function LegionWelfareWarAllotPanel:getCurAllotNumber()
    local m_num2 = self:getChildByName("upPanel/Label_people_num2")
    local nAlltonum = tonumber(m_num2:getString())
    return nAlltonum or 0
end