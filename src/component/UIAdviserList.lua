
--军师内政二级界面 任命列表
--by fwx 2016.11.02

UIAdviserList = class("UIAdviserList", BasicComponent)

function UIAdviserList:ctor( panel, title, isForeignState )
    UIAdviserList.super.ctor(self)

    local uiSkin = UISkin.new("UIAdviserList")
    uiSkin:setParent(panel)
    uiSkin:setLocalZOrder( PanelLayer.UI_Z_ORDER_3 )
    self.secLvBg = UISecLvPanelBg.new(uiSkin:getRootNode(), self )
    self.secLvBg:setContentHeight(850)
    self.secLvBg:setBackGroundColorOpacity(150)
    self._uiSkin = uiSkin
    self._panel = panel
    local mainPanel = self._uiSkin:getChildByName("Panel_OneKey")
    mainPanel:setTouchEnabled(false)
    mainPanel:setLocalZOrder(101)
    self:setTitle( title )

    self.isForeignState = isForeignState
    self.visiPos = nil

    self.mTitle = mainPanel:getChildByName("title")
    self.mBtnGo = mainPanel:getChildByName("btn_go")
    self.listView = mainPanel:getChildByName("ListView")

    -- local item = self.listView:getChildByName("Panel_item")
    -- self.oldHeight = item:getContentSize().height
    -- self:setItemHeight( 200 )

    self.mTitle:setString( TextWords:getTextWord(270080) )
    ComponentUtils:addTouchEventListener( self.mBtnGo, function()
        self:jumpToRecruits() --跳转到求贤
        self:hide()
    end) 

    self.proxy = panel:getProxy(GameProxys.Consigliere)
end
function UIAdviserList:finalize()
    self._uiSkin:finalize()
    self._uiSkin = nil
    self.okfn = nil
    self.nofn = nil
    UIAdviserList.super.finalize(self)
end
function UIAdviserList:hide()
    self._uiSkin:setVisible(false)
end
function UIAdviserList:isVisible()
    return self._uiSkin:isVisible()
end


--===============================================
--外部设置
--===============================================

-- --设置item的高度
-- function UIAdviserList:setItemHeight( height )
--     local item = self.listView:getChildByName("Panel_item")
--     local headItem = item:getChildByName( "Panel_head" )
--     item:setContentSize( item:getContentSize().width, height )
--     headItem:setScale( height/self.oldHeight )
-- end

--军师列表 内政用。设置属性 全部以 self.visiPos 职位显示。   默认nil 以自己的 data.pos 职位显示属性
function UIAdviserList:setVisiPos( pos )
    self.visiPos = pos
end



--===============================================
--刷新
--===============================================
function UIAdviserList:show( callbackObj, okfn, nofn )
    self._uiSkin:setVisible(true)
    self.okfn = okfn
    self.nofn = nofn
    self.callbackObj = callbackObj or self._panel
    self:updateListView()
end
function UIAdviserList:setTitle( title )
    if title then
        self.secLvBg:setTitle( title )
    end
end
function UIAdviserList:updateListView()
    local _data = self.proxy:getAllInfo()
    local listData = {}
    for _,v in pairs(_data) do
        if self.isForeignState then  --如果是内政界面打开这个窗口。内政 排除5星 排除上阵
            local conf = self.proxy:getDataById( v.typeId )
            if conf.quality<=4 and v.pos>=0 then
                table.insert( listData, v )
            end
        elseif v.pos==0 then        --上阵列表排除内政军师
            table.insert( listData, v )
        end
    end
    local visiGo = #listData<=0
    self.mTitle:setVisible( visiGo )
    self.mBtnGo:setVisible( visiGo )
    self._firstIndex = nil
    self.listView:jumpToTop()
    self:renderListView( self.listView, listData, self, self.renderItemPanel )
    --因为jumptop的原因，render如果不从0开始，就要重新渲染军师item
    if self._firstIndex ~= nil and self._firstIndex ~= 0 then
        local items = self.listView:getItems()
        for i=1,self._firstIndex + 1 do
            local v = items[i]
            local adviserInfo = listData[i]
            if v ~= nil and adviserInfo ~= nil then
                self:renderItemPanel(v, adviserInfo, i - 1)
            end 
        end
    end
    
end

function UIAdviserList:renderItemPanel(item, data, index )
    self._firstIndex = self._firstIndex or index
    print("~~~~~ ",index)
    local mBtnOk = item:getChildByName("btn_ok")
    local mBtnNo = item:getChildByName("btn_no")
    local mPpro = item:getChildByName( "Panel_pro" )
    local mPHead = item:getChildByName( "Panel_head" )
    local mText = item:getChildByName( "__mText" )
    local mDes = item:getChildByName("text_des")

    local conf = self.proxy:getDataById(data.typeId)

    local posUrl = nil
    if data.pos>0 then
        posUrl = "images/consigliere/tit2_"..data.pos..".png"
    elseif data.pos<0 then
        posUrl = "images/newGui1/adviser_state.png"
    end

    --btn
    local visi = false
    if data.pos>0 and self.isForeignState then  --内政状态
        visi = true
    elseif data.pos<0 then  --上阵状态
        visi = true
    end
    mBtnNo:setVisible( visi )
    mBtnOk:setVisible( not visi )
    ComponentUtils:renderConsigliereItem( mPHead, data.typeId, data.lv, posUrl, true)

    local addInfo = conf.addInfo
    local desStr = ""
    -- --附加内容
    -- if conf.addInfo and conf.addInfo~="" and conf.addInfo~=" " then
    --     mDes:setString( "\n天赋："..conf.addInfo )
    -- else
    --     mDes:setString("")
    -- end

    --property
    if not self.isForeignState then  --上阵显示属性
        conf = self.proxy:getLvData( data.typeId, data.lv )
        ComponentUtils:updateConsigliereProperty( mPpro, conf, self._panel, nil )
        desStr = ComponentUtils:analyzeConsiglierePropertyStr( conf.skillID, addInfo, true )
        mPpro:setVisible( true )
    else                                   --内政属性
        mPpro:setVisible( false )  
        if not mText then
            mText = ccui.Text:create()
            mText:setFontName(GlobalConfig.fontName)
            mText:setFontSize(20)
            mText:setAnchorPoint( 0, 0.5 )
            mText:setName( "__mText" )
            item:addChild( mText )
        end
        desStr = ComponentUtils:analyzeConsiglierePropertyStr( nil, addInfo, false )
        local str = self.proxy:getForeignAddVul( conf.quality, self.visiPos or data.pos )
        mText:setString( StringUtils:getStringAddBackEnter( str, 14)  )
        mText:setColor( ColorUtils:getColorByQuality( conf.quality ) )
        mText:setPosition( mPpro:getPositionX()-20, item:getContentSize().height*0.5 )
    end
    mDes:setString( desStr )

    --回调  返回参数一：data
    ComponentUtils:addTouchEventListener( mBtnOk, function() --任命
        local ret = false
        if self.okfn then
            ret = self.okfn( self.callbackObj, data )
        end
        if ret==true then
            self:hide()
        end
    end )
    ComponentUtils:addTouchEventListener( mBtnNo, function() --卸任
        local ret = false
        if self.nofn then
            ret = self.nofn( self.callbackObj, data )
        end
        if ret==true then
            self:hide()
        end
    end)
end

function UIAdviserList:jumpToRecruits()
    local PANELNAME = "ConsigliereRecruitsPanel"
    local panel = self._panel:getPanel( "ConsiglierePanel" )
    if panel and panel._tabControl then
        panel._tabControl:changeTabSelectByName( PANELNAME )
        self:hide()
    else
        ModuleJumpManager:jump( ModuleName.ConsigliereModule, PANELNAME )
    end
end