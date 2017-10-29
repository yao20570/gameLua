
ReportPanel = class("ReportPanel", BasicPanel)
ReportPanel.NAME = "ReportPanel"

local CHECK_N = 6

function ReportPanel:ctor(view, panelName)
	ReportPanel.super.ctor(self, view, panelName, 700)
	self:initData()
    
    self:setUseNewPanelBg(true)
end

function ReportPanel:finalize()
	self._nCurCheck1 = nil
	self._nCurCheck2 = nil
	self._sPlayerName = ""
	ReportPanel.super.finalize(self)
end


--==================================================================================
--初始化
--==================================================================================
function ReportPanel:initData()
	self._nCurCheck1 = CHECK_N   --记录，举报原因，默认最后一个
	self._nCurCheck2 = 0 		--记录，发言证据，默认最后一个
	self._nCurData = nil
	self._sPlayerName = ""
end

function ReportPanel:initPanel()
	ReportPanel.super.initPanel(self)

	self:setTitle( true, TextWords:getTextWord(917) )

	--checks
	self._mCheck1 = {}
	self._mPanel = self:getChildByName( "Panel_16" )
	self._mInput = self._mPanel:getChildByName( "Img_input" )
    self._listView=self._mPanel:getChildByName( "ListView" )

	for i=1, CHECK_N do
		self._mCheck1[i] = self._mPanel:getChildByName( "Check_0"..i )
		self._mCheck1[i]:addEventListener( function()
			self._nCurCheck1 = i
			self:updateCheckState( i )
		end)
	end

	--edite
	local bgurl = "images/newGui9Scale/SpKeDianJiBg.png"
	self._chatEditBox = ComponentUtils:addEditeBox(self._mInput,40,self:getTextWord(918),nil,nil,bgurl)
	self._chatEditBox:setMaxLength(40)
	self._chatEditBox:setFontName("system")
	self._chatEditBox:setFontSize(23)

	--listview
	local tempItem = self._listView:getChildByName("Panel_item")
	self._nOldItemHeight = tempItem:getContentSize().height
	self:renderListView( self._listView, {}, self, self.renderItemPanel )
end

function ReportPanel:registerEvents()
	ReportPanel.super.registerEvents(self)

	local btnOk = self._mPanel:getChildByName( "But_ok" )
	local btnHelp = self._mPanel:getChildByName( "But_help" )
	self:addTouchEventListener(btnOk, self.onOkTouch)
	self:addTouchEventListener(btnHelp, self.onHelpTouch)
end


--==================================================================================
--事件
--==================================================================================
--点击确定
function ReportPanel:onOkTouch( sender )
	local context = self._chatEditBox:getText() or ""
	if context=="" and self._nCurCheck1==CHECK_N then
		self:showSysMessage( TextWords:getTextWord(919) )
		return
	end

	if nil==self._nCurData then
		self:showSysMessage( TextWords:getTextWord(920) )
		return
	end

	--整理数据
	self._nCurData = self._nCurData or {}
	local reportInfo = {
		["reportId"] = self._nCurData.reportId,
		["type"] = self._nCurData.type,
		["context"] = self._nCurData.context,
		["playerId"] = self._nCurData.playerId,
		["time"] = self._nCurData.time,
	}
	local data = {}
	data.reason = self._nCurCheck1
	data.context = context
	data.reportInfo = {reportInfo}
	self:dispatchEvent( ReportEvent.REPORT_EVENT, data )
end
--点击感叹号
function ReportPanel:onHelpTouch( sender )
	local uiTip = UITip.new( self:getParent() )
	local text = {{{content = TextWords:getTextWord(923), foneSize = ColorUtils.tipSize20, color = ColorUtils.wordColorDark1601}}}
	uiTip:setAllTipLine(text)
end

function ReportPanel:onHideHandler()
	self.view:dispatchEvent( ReportEvent.HIDE_SELF_EVENT )
end


--==================================================================================
--外部入口
--==================================================================================
function ReportPanel:onShowHandler()
	self:initData()
	self:updateCheckState( self._nCurCheck1 )
end

function ReportPanel:onUpdateInfo( reportList )
	local newData = {}
	for i, data in ipairs( reportList ) do
		if data.context~=nil and data.context~="" and data.context~="nil" and self._sPlayerName~=nil then
			table.insert( newData, data )
		end
	end
	self:renderListView( self._listView, newData, self, self.renderItemPanel )
	if #newData>0 then
		local index = self._nCurCheck2
		self:updateListState( index, newData[index+1] )
	else
		self:showSysMessage( TextWords:getTextWord(922) )
	end
end

function ReportPanel:onUpdateName( playerName )
	local mName = self._mPanel:getChildByName( "Text_name" )
	local mTit = self._mPanel:getChildByName( "Text_tit" )
	mName:setString( playerName )
	self._sPlayerName = playerName
	self._chatEditBox:setText( "" )

	--居中坐标
	local width = mName:getContentSize().width+mTit:getContentSize().width
	local x = (mName:getParent():getContentSize().width-width)*0.5
	-- mTit:setPositionX( x )
	-- mName:setPositionX( x+mTit:getContentSize().width )
end

--==================================================================================
--刷新
--==================================================================================
function ReportPanel:updateListState( index, data )
    local m_check, nCheck = nil, 0
    local m_items = self._listView:getItems()
    for i,m_item in ipairs(m_items) do
    	local state = index==i-1
        m_check = m_item:getChildByName("CheckBox")
        m_check:setSelectedState( state )
    end
    self._nCurData = data
    self._nCurCheck2 = index
end

function ReportPanel:updateCheckState( index )
	for i=1, CHECK_N do
		local state = index==i
		self._mCheck1[i]:setSelectedState( state )
	end
end

function ReportPanel:renderItemPanel( m_item, data, index )
    local m_textTit = m_item:getChildByName("Text_tit")
    local m_check= m_item:getChildByName("CheckBox")
	local state = m_check:getSelectedState()

    m_check:addEventListener( function()
        self:updateListState( index, data )
    end)

    local charId = data.type==1 and 902 or 924
    local channelStr = self:getTextWord(charId)
    local str = string.format( "[%s]%s: %s", channelStr, self._sPlayerName, data.context )
	m_textTit:setTextAreaSize(cc.size(0,0))
	m_textTit:setString( str )

	--自适应高度
	-- local oldSize = m_textTit:getCustomSize()
	-- local size = m_textTit:getVirtualRendererSize()
	-- local itemSize = m_item:getContentSize()
	-- local d = math.ceil(size.width / oldSize.width)
	-- local newSize = cc.size(oldSize.width, size.height*d+11 )
	-- m_textTit:setContentSize( cc.size(oldSize.width, size.height*10 ) )
	-- m_item:setContentSize( cc.size( itemSize.width, self._nOldItemHeight + size.height*(d-1) ) )
end

