
NodeUtils = {}

--替换父节点
function NodeUtils:switchParent(node, newParent, addChild)
    node:retain()
    node:removeFromParent()
    if addChild == nil then
        addChild = newParent.addChild
    end
    addChild(newParent, node)
    node:release()
end

function NodeUtils:hideChildren(node)
    local children = node:getChildren()
    for _, child in pairs(children) do
        child:setVisible(false)
    end
end

--删除所有Child 除了name
function NodeUtils:removeAllChild(node, name)
    local children = node:getChildren()
    for _, child in pairs(children) do
        if child:getName() ~= name then
            node:removeChild(child)
        end
    end
end

function NodeUtils:setChildrenVisible(node, visible)
    local children = node:getChildren()
    for _, child in pairs(children) do
        child:setVisible(visible)
    end
end

function NodeUtils:setChildrenTouchEnable(node, enable)
    local children = node:getChildren()
    for _, child in pairs(children) do
        child:setTouchEnabled(enable)
    end
end

function NodeUtils:setEnable(node, enable)
    -- node.setBright = nil
    if enable == true then
        if node.setBright ~= nil then
            -- node:setBright(enable)
            -- node:setEnabled(enable)
        else
            -- node:setColor(cc.c3b(255,255,255))
        end
        node:setColor(cc.c3b(255,255,255))
    else
        if node.setBright ~= nil then
            -- node:setBright(false)
            -- node:setEnabled(false)
        else
            -- node:setColor(cc.c3b(155,155,155))
        end
        node:setColor(cc.c3b(155,155,155))
    end
    node:setTouchEnabled(enable)
end

function NodeUtils:setEnableColor(node, enable)
    if enable == true then
        node:setColor(cc.c3b(255,255,255))
    else
        node:setColor(cc.c3b(155,155,155))
    end
end

function NodeUtils:setGray(node, isGray)
    if isGray == true then      
        node:setColor(cc.c3b(155,155,155))  
    else
        node:setColor(cc.c3b(255,255,255))
    end    
end

function NodeUtils:shark(node, num, callback)

    node:stopAllActions()
    
    local function endcall()
        node:setScale(1)
        node:setPosition(0, 0)
        if callback ~= nil then
            callback()
        end
    end
    
    num = num or 2
    local action = cc.Sequence:create( 
        cc.Repeat:create( cc.Sequence:create(
            cc.MoveBy:create(0.06, cc.p(3,3)),
            cc.ScaleTo:create(0.03, 1.03),
            cc.MoveBy:create(0.03, cc.p(-4,-4)), 
            cc.MoveBy:create(0.04, cc.p(3,3))), num ), 
        cc.ScaleTo:create(0.06, 1), 
        cc.CallFunc:create(endcall) )
        
    node:runAction(action)
end


function NodeUtils:textAddShadow(text, color3b, shadowSize)

--    if text.isAddShadow == true then
--        return
--    end
--    text.isAddShadow = true
--    local center = ccui.Text:create()
--    center:setFontName(GlobalConfig.fontName)
--    center:setString(text:getString())
--    center:setColor(color3b)
--    local textContentSize = text:getContentSize()
--    center:setPosition(textContentSize.width * 0.5 - shadowSize,
--        textContentSize.height * 0.5 + shadowSize)
--    text:addChild(center)
--    text.srcSetString = text.setString
--    
--    text.setString = function(srcText, content)
--        srcText.srcSetString(srcText, content)
--        center:setString(content)
--    end
end

function NodeUtils:enableShadow(text, shadowColor, offset, blurRadius)
    shadowColor = shadowColor or cc.c4b(0,0,0, 255)
    offset = offset or cc.size(2,-2)
    blurRadius = blurRadius or 0
    
    text:enableShadow(shadowColor, offset, blurRadius)
end

function NodeUtils:newTipEffect(target, state)
    target:setRotation(5)
    target:setVisible(state)
    target:stopAllActions()
    if state == true then
        target:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(0.3,20),cc.RotateTo:create(0.3,5),cc.RotateTo:create(0.3,-10),cc.RotateTo:create(0.3,5),cc.DelayTime:create(2))))
    else
    end
end

function NodeUtils:getAdaptiveScale()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local winSize = cc.Director:getInstance():getWinSize()

    local scale = winSize.width / visibleSize.width
    
    return scale
end

function NodeUtils:getAdaptiveScaleY()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local winSize = cc.Director:getInstance():getWinSize()

    local scale = winSize.height / visibleSize.height
    
    return scale
end

--设备宽高的比例
function NodeUtils:getFrameViewRate( )
    local winSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local  rate = winSize.height / winSize.width
    return rate
end

--LayoutConfig.TopSpace56 = 56  --距离顶部高度
--LayoutConfig.TopSpace153 = 122  --距离顶部高度
--LayoutConfig.TopSpace147 = 147  --距离顶部高度
--LayoutConfig.TopSpace153 = 153  --距离顶部高度
--LayoutConfig.TopSpace330 = 330  --距离顶部高度
function NodeUtils:adaptiveTopY(widget, topSpace)
    -- 
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    -- 编辑器的大小
    local winSize = cc.Director:getInstance():getWinSize()
    local s = visibleSize.width / winSize.width
    local y = topSpace * s
    local winSize = cc.Director:getInstance():getWinSize()
    local widgetHeight = widget:getContentSize().height
    local anchorY = widget:getAnchorPoint().y 
    widget:setPositionY(960 - (widgetHeight * (1 - anchorY) + topSpace) * s )
    --widget:setPositionY(960 - 154 * s)
end

--
--同时适应上Panel、下ListView布局
--@param widget  上部Panel 不能为空
--@param listView Panel下面的listView 可以为nil，为nil就只是适应一个向上对齐的Panel
--@param downWidget 下方对应widget,可为nil，listView为nil则为nil；downWidget可为坐标，也可为对齐的widget
--@param upWidget 上方对应widget, 不可为nil upWidget可为坐标，也可为对齐的widget
--@param dy 间隔，listView和widget之间的间隔高度
function NodeUtils:adaptiveTopPanelAndListView(widget, listView, downWidget, upWidget, dy)
    
    local function delayAdaptiveTopPanelAndListView()
        self:delayAdaptiveTopPanelAndListView(widget, listView, downWidget, upWidget, dy)
    end

    delayAdaptiveTopPanelAndListView()
    -- TimerManager:addOnce(1,delayAdaptiveTopPanelAndListView, self)
end

function NodeUtils:delayAdaptiveTopPanelAndListView(widget, listView, downWidget, upWidget, dy)
    local upWidgetWorldPos = 0
    local upWidgetWorldPos = 0 

    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local winSize = cc.Director:getInstance():getWinSize()
    local scale = visibleSize.width / winSize.width

    if type(upWidget) == type(0) then
        upWidgetWorldPos = cc.p(0, upWidget)
    else
        upWidgetWorldPos = upWidget:getWorldPosition()
    end
    
    local size = widget:getContentSize()
    local widgetx = widget:getPositionX()
    local widgetWorldPos = widget.widgetWorldPos
    if widgetWorldPos == nil then
        widget.widgetWorldPos = widget:getWorldPosition()
        widgetWorldPos = widget.widgetWorldPos
    end
    local wdy = upWidgetWorldPos.y - widgetWorldPos.y - size.height * scale
    local startWPos = cc.p(upWidgetWorldPos.x, widgetWorldPos.y )
    local parent = widget:getParent()
    local curPos = parent:convertToNodeSpace(startWPos)
    widget:setPosition(widgetx, curPos.y + wdy)

    if listView ~= nil then
        if downWidget == nil then
            -- print("downWidget为空的情况")
            self:adaptiveListViewByTop(listView,widget,upWidget,dy)
        else
            self:delayAdaptiveListView(listView, downWidget, widget, dy)
        end
    end
    
end

--将ListView自适应到两个Widget之间
--downWidget 数字则为向下Y坐标，widget则为Layout
--upWidget 数字则为向上Y坐标，widget则为Layout
-- dy 向上间隔
--distanceY 向下的间隔
function NodeUtils:adaptiveListView(listView, downWidget, upWidget,dy,distanceY)
--    
--    self:delayAdaptiveListView(listView, downWidget, upWidget)
    distanceY = distanceY or 3
--    listView:setVisible(false)
    local function delayAdaptiveListView()
        self:delayAdaptiveListView(listView, downWidget, upWidget,dy, distanceY)
    end
    
    delayAdaptiveListView()
    -- TimerManager:addOnce(1,delayAdaptiveListView,self)
end

-- 特殊：只有topWidget和mainPanel,没有downWidget的布局
function NodeUtils:adaptiveListViewByTop( listView, widget, upWidget, dy)
    -- body
    local scale = self:getAdaptiveScale()
    scale = 1/scale
    local upWidgetWorldPos
    if type(widget) == type(0) then
        upWidgetWorldPos = cc.p(0, widget)
    else
        upWidgetWorldPos = widget:getWorldPosition()
    end
    
    local size = listView:getContentSize()
    local widgetx = listView:getPositionX()
    local widgetWorldPos = listView.widgetWorldPos
    if widgetWorldPos == nil then
        listView.widgetWorldPos = listView:getWorldPosition()
        widgetWorldPos = listView.widgetWorldPos
    end
    local dy = upWidgetWorldPos.y - widgetWorldPos.y - size.height * scale
    local startWPos = cc.p(widgetWorldPos.x, widgetWorldPos.y)
    local parent = listView:getParent()
    local curPos = parent:convertToNodeSpace(startWPos)
    listView:setPosition(widgetx, curPos.y + dy)
end


function NodeUtils:delayAdaptiveListView(listView, downWidget, upWidget, dy, distanceY)

    if listView.changeTableView == true then
    else
--        listView:setVisible(true)
    end
    local dy = dy or 0  --upWidget和listView之间的间隔
    distanceY = distanceY or 0  --downWidget和listView之间的间隔
    local listViewWorldPos = listView:getWorldPosition()
    local downWorldPos = 0
    local downSize = nil
    local downAnchorPoint = nil
    if type(downWidget) == type(0) then
        downWorldPos = cc.p(0, downWidget)
        downSize = cc.size(0,0)
        downAnchorPoint = cc.p(0,0)
    else
        -- if downWidget.__posy == nil then
        --     downWidget.__posy = downWidget:getPositionY()
        -- end
        -- downWidget:setPositionY(downWidget.__posy + 103)
        downWorldPos = downWidget:getWorldPosition()
        downSize = downWidget:getContentSize()
        downAnchorPoint = downWidget:getAnchorPoint()
    end
    
    local upWidgetWorldPos = 0
    local upSize = nil
    local upAnchorPoint
    if type(upWidget) == type(0) then
        upWidgetWorldPos = cc.p(0, upWidget)
        upSize = cc.size(0,0)
    else
        upWidgetWorldPos = upWidget:getWorldPosition()
        upSize = upWidget:getContentSize()
        upAnchorPoint = upWidget:getAnchorPoint()
    end
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local winSize = cc.Director:getInstance():getWinSize()
    local scale = visibleSize.width / winSize.width
    
    local startWPos = cc.p(
                            listViewWorldPos.x, 
                            downWorldPos.y + downSize.height * scale * (1-downAnchorPoint.y) + distanceY * scale)
    local listViewHeight = upWidgetWorldPos.y - dy - startWPos.y 
    
    local size = listView:getContentSize()
    listViewHeight = listViewHeight * (winSize.width / visibleSize.width )
    listView:setContentSize(size.width, listViewHeight)
    
    local parent = listView:getParent()
    local curPos = parent:convertToNodeSpace(startWPos)
    
    listView:setPosition(curPos.x , curPos.y)
    
--    listView:setFinalPositionY(curPos.y)
    
--    local function delayAdaptiveY()
--        listView:setPosition(curPos.x , curPos.y )
--    end
--    TimerManager:addOnce(1, delayAdaptiveY, self)
end

function NodeUtils:adaptive(widget, aday)
    local scale = self:getAdaptiveScale()
    
    local size = widget:getContentSize()
    local dy = 0
    if scale > 1 then
        -- dy = 60 * (scale - 1)
    end
    widget:setContentSize(size.width, math.floor(size.height * scale) + dy )
    
    if aday == true then
        local y = widget:getPositionY()
        widget:setPositionY(y*(scale - 0))
        -- print("scale,y,dy,size.height = ",scale,y,dy,size.height)
    end
end

-- tabsPanel标签自适应
-- widget=tabsPanel
function NodeUtils:adaptiveTabs(widget, aday)
    -- 修改布局参数达到自适应效果
    if aday == true then
        local scale = self:getAdaptiveScale()    
        local dy = GlobalConfig.tabsAdaptive * (scale - 1)
        
        local parameter = widget:getLayoutParameter()
        local margin = parameter:getMargin()
        
        margin.top = margin.top - dy
        parameter:setMargin(margin)
    end
end

-- 无标签的Panel界面，topPanel自适应
-- widget=topPanel
function NodeUtils:adaptiveTopPanel(widget)
    -- 修改布局参数达到自适应效果
    if widget ~= nil then
        local scale = self:getAdaptiveScale()    
        local dy = math.floor(GlobalConfig.topAdaptive * (scale - 1))
        
        local parameter = widget:getLayoutParameter()
        local margin = parameter:getMargin()
        
        margin.top = margin.top - dy
        parameter:setMargin(margin)

        print("topPanel自适应 dy,margin.top=",dy,margin.top)

    end
end


function NodeUtils:adaptiveScale9Image(scale9Image)
    local rect = scale9Image:getCapInsets()
    local scale = self:getAdaptiveScale()
    
    local newScale = cc.rect(rect.x,rect.y,rect.width,rect.height * scale)
    scale9Image:setCapInsets(newScale)
end

--[[
    --@把pnl的上边缘对齐node的下边缘
    --@param:pnl,panle节点
    --@param:top_pnl,任意节点
    --top_pnl可以为nil,为空的时候,就是适配屏幕最高点
--]]
function NodeUtils:adaptiveUpPanel(pnl,topPnl,dy)
    dy = dy or 0

    if not pnl then
        return
    end
    local topWorldPos
    if topPnl then
        topWorldPos = topPnl:getWorldPosition()
    else
        local winsize = cc.Director:getInstance():getVisibleSize()--cc.Director:getInstance():getWinSize()
        topWorldPos = cc.p(0,winsize.height)
    end

    local size = pnl:getContentSize()
    local pos = cc.p(pnl:getPosition())
    local scaleY = pnl:getScaleY()

    local worldPos = pnl:getWorldPosition()

    --diff y
    local diffY  = topWorldPos.y - (worldPos.y + size.height * scaleY)

    pnl:setPositionY(pos.y + diffY - dy)

end

--[[
    --@把pnl的上边缘对齐node的下边缘 (计算 scale 和anchorpoint)
    --@param:pnl,panle节点
    --@param:top_pnl,任意节点
    --top_pnl可以为nil,为空的时候,就是适配屏幕最高点
--]]
function NodeUtils:adaptiveUpPanelABS(pnl,topPnl,dy)
    dy = dy or 0

    if not pnl then
        return
    end
    local topWorldPos
    local topSize
    local topScaleY
    local topAnchorPoint
    if topPnl then
        topWorldPos = topPnl:getWorldPosition()
        topSize = topPnl:getContentSize()
        topScaleY = topPnl:getScaleY()
        topAnchorPoint = topPnl:getAnchorPoint()
    else
        local winsize = cc.Director:getInstance():getVisibleSize()--cc.Director:getInstance():getWinSize()
        topWorldPos = cc.p(0,winsize.height)
    end

    local size = pnl:getContentSize()
    local pos = cc.p(pnl:getPosition())
    local scaleY = pnl:getScaleY()
    local anchorPoint = pnl:getAnchorPoint()
    local worldPos = pnl:getWorldPosition()

    --diff y
    local diffY  = topWorldPos.y - 
                        (topSize.height * topAnchorPoint.y * topScaleY) - 
                        (worldPos.y + size.height * anchorPoint.y * scaleY)

    pnl:setPositionY(pos.y + diffY - dy)

end

--[[
    --@把pnl的位置(不能说下边缘)对齐downPnl的上边缘 dy 个像素
    --@param:pnl,panle节点
    --@param:downPnl,任意节点
    --downPnl可以为nil,为空的时候,就是适配屏幕最低点
--]]
function NodeUtils:adaptiveDownPanel(pnl,downPnl,dy)
    dy = dy or 0

    if not pnl then
        return
    end
    local downWorldPos
    local size
    if downPnl then
        downWorldPos = downPnl:getWorldPosition()
        local anchor_point = downPnl:getAnchorPoint()
        local box = downPnl:getBoundingBox()
        size = cc.size(box.width,box.height)
        -- downWorldPos.x = downWorldPos.x - anchor_point.x*box.height --x方向不用计算
        downWorldPos.y = downWorldPos.y - anchor_point.y*box.height --防止锚点不是(0,0)
    else
        downWorldPos = cc.p(0,0)
        size = cc.size(0,0)
    end


    local worldPos = pnl:getWorldPosition()

    --diff y
    local diffY  = worldPos.y - (downWorldPos.y + size.height)

    pnl:setPositionY(pnl:getPositionY() - diffY + dy)

end



--获取屏幕中心位置
function NodeUtils:getCenterPosition()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    return visibleSize.width / 2, visibleSize.height / 2
end

--自适应Panel，拉伸缩放背景
--命名规则 bigBg midBg downPanel
--curLineNum当前要显示的行数
-- maxLineNum最大行数 
--lineHeight行高
--panel默认是最大的视图
function NodeUtils:adaptivePanel(panel, curLineNum, maxLineNum, lineHeight)
    local children = panel:getChildren()
    local dy = (maxLineNum - curLineNum) * lineHeight
    

    for _, child in pairs(children) do
    	local name = child:getName()
    	if name == "bigBg" or name == "midBg" then
    	    if child.srcSize == nil then
    	        child.srcSize = child:getContentSize()
    	    end
    	    
    	    local ch = child.srcSize.height - dy
    	    local cw = child.srcSize.width
    	    child:setContentSize(cw, ch)
            local subChildren = child:getChildren()
            for _, subChild in pairs(subChildren) do
    	    	if subChild.srcY == nil then
                    subChild.srcY = subChild:getPositionY()
    	    	end
                local scy = subChild.srcY - dy
                subChild:setPositionY(scy)
    	    end
    	end
    	
    	if name == "downPanel" then
            if child.srcY == nil then
                child.srcY = child:getPositionY()
            end
            local scy = child.srcY + dy / 2
            child:setPositionY(scy)
    	end
    end
end

--队列显示动画
--从左往右消失
--从右往左显示
--默认横x的， dir = y竖的
function NodeUtils:queueShowAction(panel, visible, dir)
    panel:setVisible(true)
    local nodeList = {}
    local bgImg = nil
    local children = panel:getChildren()
    for _, child in pairs(children) do
        local name = child:getName()
        if name == "bgImg" or name == "bgImg_2" then
            if child:isVisible() == true then
                bgImg = child
            end
        else
            local x = child:getPositionX()
            child.x = x
            child.y = child:getPositionY()
            child.srvVisible = child:isVisible()
            table.insert( nodeList, child)
            
            if visible == true then
                child:setOpacity(0)
            else
                child:setOpacity(255)
            end
        end
    end
    
    local dir = dir or "x"
    --显示的比较
    local function comp1(a, b)
        return a[dir] > b[dir]
    end
    --隐藏
    local function comp2(a, b)
        return a[dir] < b[dir]
    end
    
    local comp = nil
    if visible == true then
        comp= comp1
    else
        comp= comp2
    end
    table.sort(nodeList,comp)
    
--    if bgImg ~= nil then
--       bgImg:setVisible(visible)
--    end
    
    local ot = 0
    if visible == true then
        ot = 255
    end
    
    local actionTime = 0.1
    local index = 1
    
    local function callback()
        local lastNode = nodeList[index] --上一个Node
        lastNode:setVisible(lastNode.srvVisible)
        index = index + 1
        local node = nodeList[index]
        
        local fadeTo = cc.FadeTo:create(actionTime, ot)
        local action = cc.Sequence:create(fadeTo, cc.CallFunc:create(callback))
        if node ~= nil then
            node:runAction(action)
        else  --动画结束
            panel:setVisible(visible)
        end
    end
    for _,node in pairs(nodeList) do
        node:stopAllActions()
        if visible then
            node:setOpacity(0)
        else
            node:setOpacity(255)
        end
    end
    --逐个动画
    local fadeTo = cc.FadeTo:create(actionTime, ot)
    local action = cc.Sequence:create(fadeTo, cc.CallFunc:create(callback))
    
    local node = nodeList[index]
    node:runAction(action)
    
end

--sprit图片描边处理
--color 颜色 c3b
function NodeUtils:renderStoke(node, color)

    local glProgram = cc.GLProgramCache:getInstance():getGLProgram("renderStoke")
    if glProgram == nil then
        local vertDefaultSource = "\n".."\n" ..
        "attribute vec4 a_position;\n" ..
        "attribute vec2 a_texCoord;\n" ..
        "attribute vec4 a_color;\n\n" ..
        "\n#ifdef GL_ES\n" .. 
        "varying lowp vec4 v_fragmentColor;\n" ..
        "varying mediump vec2 v_texCoord;\n" ..
        "\n#else\n" ..
        "varying vec4 v_fragmentColor;" ..
        "varying vec2 v_texCoord;" ..
        "\n#endif\n" ..
        "void main()\n" ..
        "{\n" .. 
        "   gl_Position = CC_MVPMatrix * a_position;\n"..
        "   v_fragmentColor = a_color;\n"..
        "   v_texCoord = a_texCoord;\n" ..
        "} \n"

        local fileUtiles = cc.FileUtils:getInstance()
        local fragSource = fileUtiles:getStringFromFile("shaders/example_outline.fsh")
        glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,fragSource)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, "renderStoke")
    end


    local glprogramstate = cc.GLProgramState:create(glProgram)
    local color = cc.Vertex3F(color.r / 255, color.g / 255, color.b / 255)
    local radius = 0.02
    local threshold = 1.15
    node:setGLProgramState(glprogramstate)
    node:getGLProgramState():setUniformVec3("u_outlineColor", color)
    node:getGLProgramState():setUniformFloat("u_radius", radius)
    node:getGLProgramState():setUniformFloat("u_threshold", threshold)
end

function NodeUtils:renderBrightness(node,r,g,b,a)
    --assert(r and g and b and a ,"r,g,b,a Cannot default!")
    local vertDefaultSource = "\n"..
                           "attribute vec4 a_position; \n" ..
                           "attribute vec2 a_texCoord; \n" ..
                           "attribute vec4 a_color; \n"..                                                    
                           "#ifdef GL_ES  \n"..
                           "varying lowp vec4 v_fragmentColor;\n"..
                           "varying mediump vec2 v_texCoord;\n"..
                           "#else                      \n" ..
                           "varying vec4 v_fragmentColor; \n" ..
                           "varying vec2 v_texCoord;  \n"..
                           "#endif    \n"..
                           "void main() \n"..
                           "{\n" ..
                            "gl_Position = CC_PMatrix * a_position; \n"..
                           "v_fragmentColor = a_color;\n"..
                           "v_texCoord = a_texCoord;\n"..
                           "}"
    local str
    if r then
        str = string.format("c *= vec4(%d*c.r, %d*c.g, %d*c.b,%d*c.w); \n",r,g,b,a)
    else
        str = "c *= vec4(1, 1, 1, 1); \n"
    end
    local psGrayShader = "#ifdef GL_ES \n" ..
                            "precision mediump float; \n" ..
                            "#endif \n" ..
                            "uniform sampler2D u_texture;"..
                            "varying vec4 v_fragmentColor; \n" ..
                            "varying vec2 v_texCoord; \n" ..
                            "void main(void) \n" ..
                            "{ \n" ..
                            "vec4 c = v_fragmentColor * texture2D(CC_Texture0, v_texCoord); \n"..  
                            str..
                            "gl_FragColor = c; \n"..  
                            "} \n" 
        local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,psGrayShader)


        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:use()
        pProgram:updateUniforms()
        node:setGLProgram(pProgram)
end

function NodeUtils:adaptiveXCenter(node, size)
    local size = size or node:getContentSize()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local winSize = cc.Director:getInstance():getWinSize()

    if winSize.width <= size.width 
        and winSize.height <= size.height then

        local x = node:getPositionX()
        x = x - (size.width - visibleSize.width) / 2
        node:setPositionX(x)
    end
end

function NodeUtils:scPos2MapPos(scrollView, scPosX, scPosY)
    local movePos = scrollView:getMoveChildPoint()
    local x = scPosX + math.abs(movePos.x)
    local y = scPosY + math.abs(movePos.y)

    return x, y
end

--在两点之前画虚线
function NodeUtils:drawDottedLine(node1, node2, parent, dottedNode)
    local dottedGroup = {}
    
    local size1 = node1:getContentSize()
    local size2 = node2:getContentSize()
    local anchor1 = node1:getAnchorPoint()
    local anchor2 = node2:getAnchorPoint()
    local x1, y1 = node1:getPosition()
    local x2, y2 = node2:getPosition()
    
    x1 = x1 + size1.width * (0.5 - anchor1.x)
    y1 = y1 + size1.height * (0.5 - anchor1.x)
    
    x2 = x2 + size2.width * (0.5 - anchor2.x)
    y2 = y2 + size2.height * (0.5 - anchor2.x)
    
    local dir = cc.p(x2 - x1, y2 - y1)
    local normalDir = cc.pNormalize(dir)
    
    local angle = math.deg(cc.pToAngleSelf(dir))
    
    local inval = 40
    
    local len = cc.pGetLength(dir)
    local size = math.floor(len / inval)
    
    for index=2, size - 2 do
    	local dlen = inval * index
        local dir2 = cc.pMul(normalDir, dlen)
        
        local dotted = dottedNode:clone()
        dotted:setPosition(x1 + dir2.x, y1 + dir2.y)
        parent:addChild(dotted)
        dotted:setRotation(-angle)
        
        dotted:setLocalZOrder(100)
        
        table.insert(dottedGroup, dotted)
    end
    
    return dottedGroup
end

--tudo:为了有的背景图片紧靠着upWidget
function NodeUtils:adaptivePanelBg(panelBg, downWidget, upWidget)
    local dy
    local scale = self:getAdaptiveScale()
    if scale <= 1 then
        dy = -3
    else
        dy = 0 
    end
    local function delayAdaptiveListView()
        self:delayAdaptiveListView(panelBg, downWidget, upWidget,dy)
    end
    
    delayAdaptiveListView()
    -- TimerManager:addOnce(1,delayAdaptiveListView,self)
end


------
-- 竖向ListView停留在当前卡片
-- @param  listView [obj] listview
-- @return 
function NodeUtils:stayCurrentIndex(listView)
    local container = listView:getInnerContainer()
    local size = container:getContentSize()
    local x , y = container:getPosition()
    local listContentHeight = listView:getContentSize().height
    local trueHeight = (size.height - listContentHeight)
    local percent = 100 - ( y/(-trueHeight) ) *100
    listView:jumpToPercentVertical(percent)
end

------
-- 返回自身移动动作
function NodeUtils:selfMoveTo(moveNode, time, scale)
    scale = scale or 1
    local initPosX = moveNode:getPositionX()
    local initPosY = moveNode:getPositionY()
    local panelWidth = moveNode:getContentSize().width
    local moveToX = initPosX - panelWidth
    time = time or 0.2

    moveToX = moveToX* scale

    local moveTo = cc.MoveTo:create(time, cc.p(moveToX, initPosY)) 
    return moveTo
end

------
-- 添加点击屏蔽层
function NodeUtils:addSwallow()
    local swallowLayer = ccui.Layout:create()
    local director = cc.Director:getInstance()
    local winSize = director:getWinSize()
    swallowLayer:setTouchEnabled(true)
    swallowLayer:setContentSize(winSize)
    swallowLayer:setName("swallow_layer")
    local director = cc.Director:getInstance()
    local runScene = director:getRunningScene()
    runScene:addChild(swallowLayer, 999)
end

-----
-- 去除点击屏蔽层
function NodeUtils:removeSwallow()
    local swallowLayer = NodeUtils:getTopViewByName("swallow_layer")
    if swallowLayer then
        swallowLayer:removeFromParent(true)
    end
end 

-----
-- 根据名字获取当前场景子节点
function NodeUtils:getTopViewByName(viewName)
    local director = cc.Director:getInstance()
    local runScene = director:getRunningScene()
    return runScene:getChildByName(viewName)
end

------
-- X轴位置修正， 适用x锚点==0
-- @param  node01 [obj] 第一个节点
-- @param  node02 [obj] 第二个节点
-- @param  space [int] 两个节点的间隙长度，为nil时 == 0
function NodeUtils:fixTwoNodePos(node01, node02, space)
    space = space or 0
    node02:setPositionX( node01:getContentSize().width + node01:getPositionX() + space)
end

--@ 从左到右把节点排列起来
--@ 最后一个参数:节点间空格
--@ 最后一个参数前:节点
--@ 兼容任意锚点
function NodeUtils:alignNodeL2R(...)
    local arg = { ...}
    local space = arg[#arg]
    if type(space) ~= type(0) then
        table.insert(arg, 0)
        NodeUtils:alignNodeL2R(unpack(arg))
        return
    end

    arg[#arg] = nil
    local last_node = arg[1]
    for i = 2, #arg do
        local node = arg[i]
        local anchor_point = last_node:getAnchorPoint()
        local size = last_node:getContentSize()
        local x = last_node:getPositionX() +
        size.width * last_node:getScaleX() *(1 - anchor_point.x) +
        node:getContentSize().width * node:getScaleX() * node:getAnchorPoint().x +
        space
        node:setPositionX(x)
        last_node = node
    end
end


--@ 从左到右把节点排列起来 间隔用配置匹配
--@ 最后一个参数:节点间空格配置 {int}
--@ 最后一个参数前:节点(node)
--@ 兼容任意锚点
function NodeUtils:alignNodeL2RWithConf(...)
    local arg = { ...}
    local spacesTable = arg[#arg]
    if type(spacesTable) ~= type({}) then
        return NodeUtils:alignNodeL2R(...)
    else
        local defaultSpace = 0
        table.remove(arg,#arg)
        for i = 1,#arg - 1 do
            local space = spacesTable[i] or defaultSpace
            NodeUtils:alignNodeL2R(arg[i],arg[i+1],space)
        end
    end
end

--@ 从右到左把节点排列起来
--@ 最后一个参数:节点间空格
--@ 最后一个参数前:节点
--@ 兼容任意锚点
--@ 注意:最后会固定位置,传参从左到右传(节点顺序),具体逻辑是从右向左排的
--@ 好像有bug  ,建议先用L2R
function NodeUtils:alignNodeR2L(...)
    local arg = {...}
    local space = arg[#arg]
    if type(space) ~= type(0) then
        table.insert(arg,0)
        NodeUtils:alignNodeR2L(unpack(arg))
        return
    end

    arg[#arg] = nil
    local last_node = arg[#arg]
    for i = #arg-1,1 do
        local node = arg[i]
        local anchor_point = last_node:getAnchorPoint()
        local size = last_node:getContentSize()
        local x = last_node:getPositionX() - 
                    size.width*last_node:getScaleX() * anchor_point.x - 
                    node:getContentSize().width * (1-node:getAnchorPoint().x) -
                    space
        node:setPositionX(x)
        last_node = node
    end
end

--@ 从上到下把节点排列起来
--@ 最后一个参数:节点间空格
--@ 最后一个参数前:节点
--@ 兼容任意锚点
function NodeUtils:alignNodeU2D(...)
    local arg = {...}
    local space = arg[#arg]
    if type(space) ~= type(0) then
        table.insert(arg,0)
        NodeUtils:alignNodeU2D(unpack(arg))
        return
    end

    arg[#arg] = nil
    local last_node = arg[1]
    for i = 2,#arg do
        local node = arg[i]
        local anchor_point = last_node:getAnchorPoint()
        local size = last_node:getContentSize()
        local y = last_node:getPositionY() -
                    size.height*last_node:getScaleY() *anchor_point.y - 
                    node:getContentSize().height * (1-node:getAnchorPoint().y) -
                    space
        node:setPositionY(y)
        last_node = node
    end
end

--@ 从上到下把节点排列起来
--@ tb:节点s
--@ space:节点间空格
--@ 兼容任意锚点
function NodeUtils:alignNodeU2DForTable(tb,space)
    local arg = tb or {}
    local space = space or 0

    local last_node = arg[1]
    for i = 2,#arg do
        local node = arg[i]
        local anchor_point = last_node:getAnchorPoint()
        local size = last_node:getContentSize()
        local y = last_node:getPositionY() -
                    size.height*last_node:getScaleY() *anchor_point.y - 
                    node:getContentSize().height * (1-node:getAnchorPoint().y) -
                    space
        node:setPositionY(y)
        last_node = node
    end
end

--@ 从上到下把节点排列起来(节点用点来看,忽略size的,就只是点跟点之间的距离定死)
--@ tb:节点s
--@ space:节点间空格
--@ 兼容任意锚点
function NodeUtils:alignNodeU2DForAbsLength(tb,space)
    local arg = tb or {}
    local space = space or 0

    local last_node = arg[1]
    for i = 2,#arg do
        local node = arg[i]
        local y = last_node:getPositionY() - space
        node:setPositionY(y)
        last_node = node
    end
end

--计算两点的角度
--@pBegin = cc.p 起点坐标
--@pEnd = cc.p 终点坐标
--@return 角度(0-360)
function NodeUtils:getAngle(pBegin, pEnd)
	local lenY = pEnd.y - pBegin.y
	local lenX = pEnd.x - pBegin.x
	local toDegree = 180 / 3.1415926
	local tanYX = math.abs(lenY / lenX)
	local angle = math.atan(lenY / lenX) * toDegree
	if lenY > 0 and lenX < 0 then
		angle = math.atan(tanYX) * toDegree - 90
	elseif lenY > 0 and lenX > 0 then
		angle = 90 - math.atan(tanYX) * toDegree
	elseif lenY < 0 and lenX < 0 then
		angle = math.atan(tanYX) * -1 * toDegree - 90
	elseif lenY < 0 and lenX > 0 then
		angle = math.atan(tanYX) * toDegree + 90
	end
	return angle
end


------
-- 计算两点之间的距离 
-- @param  pos01 [cc.p] 坐标1
-- @param  pos02 [cc.p] 坐标2
-- @return 距离
function NodeUtils:getTwoPointDistance(pos01, pos02)
    local value = (pos01.x - pos02.x)*(pos01.x - pos02.x) + (pos01.y - pos02.y)*(pos01.y - pos02.y)

    return math.sqrt(value)
end

--延迟回调方法接口
--注意，这个是采用node的Action来做的，如果在延时的过程中，又runAction了
--则会打断前面的定时
--node
--delay 单位秒
--func 
--obj
function NodeUtils:delayCallback(node, delay, func, obj)
    local delayTime = cc.DelayTime:create(delay)
    node:runAction(cc.Sequence:create(delayTime, cc.CallFunc:create(function ( )
        func(obj)
    end)))
end

--判断两个控件是否重叠了
function NodeUtils:isOverlap(widget1, widget2)
    local wpos1 = widget1:getWorldPosition()
    local wpos2 = widget2:getWorldPosition()
    local size1 = widget1:getContentSize()
    local size2 = widget2:getContentSize()
    local anp1 = widget1:getAnchorPoint()
    local anp2 = widget2:getAnchorPoint()

    local rc1 = cc.rect(wpos1.x - anp1.x * size1.width, wpos1.y - anp1.y * size1.height, size1.width, size1.height)
    local rc2 = cc.rect(wpos2.x - anp2.x * size2.width, wpos2.y - anp2.y * size2.height, size2.width, size2.height)

    return self:isOverlapByRect(rc1, rc2)

end

function NodeUtils:isOverlapByRect(rc1, rc2)
    if rc1.x + rc1.width > rc2.x and
        rc2.x + rc2.width > rc1.x and
        rc1.y + rc1.height > rc2.y and
        rc2.y + rc2.height > rc1.y then
        return true
    else
        return false
    end
end


--节点变灰和变正常处理
--reset传true  图片为正常模式   nil或者false这是灰化处理
--sprite可以直接传  NodeUtils:showGreyView(sprite, reset) 
--imageview传  NodeUtils:showGreyView(imageview:getVirtualRenderer(), reset) 
function NodeUtils:showGreyView(node, reset) 
    local vertDefaultSource = "\n"..
                           "attribute vec4 a_position; \n" ..
                           "attribute vec2 a_texCoord; \n" ..
                           "attribute vec4 a_color; \n"..                                                    
                           "#ifdef GL_ES  \n"..
                           "varying lowp vec4 v_fragmentColor;\n"..
                           "varying mediump vec2 v_texCoord;\n"..
                           "#else                      \n" ..
                           "varying vec4 v_fragmentColor; \n" ..
                           "varying vec2 v_texCoord;  \n"..
                           "#endif    \n"..
                           "void main() \n"..
                           "{\n" ..
                            "gl_Position = CC_PMatrix * a_position; \n"..
                           "v_fragmentColor = a_color;\n"..
                           "v_texCoord = a_texCoord;\n"..
                           "}"
 
    --变灰
    local psGrayShader = "#ifdef GL_ES \n" ..
                            "precision mediump float; \n" ..
                            "#endif \n" ..
                            "varying vec4 v_fragmentColor; \n" ..
                            "varying vec2 v_texCoord; \n" ..
                            "void main(void) \n" ..
                            "{ \n" ..
                            "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
                            "gl_FragColor.xyz = vec3(0.299*c.r + 0.587*c.g +0.114*c.b); \n"..
                            "gl_FragColor.w = c.w; \n"..
                            "}"

    local pszRemoveGrayShader = "#ifdef GL_ES \n" ..  
        "precision mediump float; \n" ..  
        "#endif \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord; \n" ..  
        "void main(void) \n" ..  
        "{ \n" ..  
        "gl_FragColor = texture2D(CC_Texture0, v_texCoord); \n" ..  
        "}"   

    local shader = reset and pszRemoveGrayShader or psGrayShader

    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, shader)
    
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:use()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end




------
-- 截全屏 
-- @param  args [obj] 参数
-- @return renderTexture
function NodeUtils:screenshot()
    local winSize = cc.Director:getInstance():getWinSize()
    local renderTexture = cc.RenderTexture:create(winSize.width, winSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    --renderTexture:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    renderTexture:begin()
    cc.Director:getInstance():getRunningScene():visit()
    renderTexture:endToLua()
    renderTexture:retain()
    return renderTexture
end

function NodeUtils:preLoadShader()
    self:loadBlurShader()
end

function NodeUtils:isHaveShader(name)
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(name)
    return glProgram ~= nil
end

function NodeUtils:loadBlurShader()
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram("nodeBlur")
    if glProgram == nil then
        local vertDefaultSource = "\n".."\n" ..
            "attribute vec4 a_position;\n" ..
            "attribute vec2 a_texCoord;\n" ..
            "attribute vec4 a_color;\n" ..
            "\n#ifdef GL_ES\n" ..
            "\nprecision mediump float;\n"..
            "\n#endif\n" ..
            "varying vec4 v_fragmentColor;\n" ..
            "varying vec2 v_texCoord;\n" ..
            "void main()\n" ..
            "{\n" .. 
            "   gl_Position = CC_PMatrix * a_position;\n"..
            "   v_fragmentColor = a_color;\n"..
            "   v_texCoord = a_texCoord;\n" ..
            "}\n"
            
        local fileUtiles = cc.FileUtils:getInstance()
        local fragSource = fileUtiles:getStringFromFile("shaders/example_Blur.fsh")
        glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, fragSource)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, "nodeBlur")
    end
end

------
-- 节点模糊
-- @param  node [2D node] 参数
-- @param  blurRadius [int] 半径
-- @param  sampleNum [] 参数
-- @return nil
function NodeUtils:nodeBlur(node, blurRadius, sampleNum)

    local glProgram = cc.GLProgramCache:getInstance():getGLProgram("nodeBlur")
    self:loadBlurShader()

    if glProgram == nil then
        return
    end

    
    local glProgramState = cc.GLProgramState:create(glProgram)
    local size = node:getTexture():getContentSizeInPixels()
    node:setGLProgramState(glProgramState)
    --设置模糊参数
    node:getGLProgramState():setUniformVec2("resolution", cc.p(size.width, size.height))
    node:getGLProgramState():setUniformFloat("blurRadius", tonumber(blurRadius) or 16.0)
    node:getGLProgramState():setUniformFloat("sampleNum", tonumber(sampleNum)  or 8.0)
end


------
-- 节点模糊
-- @param  node [2D node] 参数
-- @param  blurRadius [int] 半径
-- @param  sampleNum [] 参数
-- @return nil
-- function NodeUtils:nodeBlurr(node, blurRadius, sampleNum)
--     --模糊处理
--     local vertDefaultSource = 
--         "#ifdef OPENGL_ES\n" ..
--         "precision mediump vec2;\n" ..
--         "precision mediump float;\n" ..
--         "#endif\n" ..

--         "attribute vec3 a_position;\n" ..
--         "attribute vec2 a_texCoord;\n" ..
--         "attribute vec4 a_color;\n" ..

--         "#ifdef GL_ES\n" ..
--         "varying vec2 v_texCoord;\n" ..
--         "#else\n" ..
--         "varying vec2 v_texCoord;\n" ..
--         "#endif\n" ..
--         "varying vec4 v_fragmentColor;\n" ..

--         "void main()\n" ..
--         "{\n" ..
--         "    gl_Position = CC_PMatrix * vec4(a_position, 1.0);\n" ..
--         "    v_texCoord = a_texCoord;\n" ..
--         "    v_fragmentColor = a_color;\n" ..
--         "}\n"
        
--     local fileUtiles = cc.FileUtils:getInstance()
--     local size = node:getTexture():getContentSizeInPixels()
--     local fragSource = fileUtiles:getStringFromFile("shaders/example_Blur_Not_For.fsh")
--     local program = cc.GLProgram:createWithByteArrays(vertDefaultSource, fragSource)
--     local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(program)
--     node:setGLProgramState(glProgramState)
--     --设置模糊参数
--     node:getGLProgramState():setUniformVec2("resolution", cc.p(size.width, size.height))
--     node:getGLProgramState():setUniformVec2("direction", cc.p(0, 0.1))
--     node:getGLProgramState():setUniformFloat("radius", 10.0)
-- end


-- nodes的节点整体相对于panel居中
-- @param  panel 相对要居中的节点
-- @param  nodes [] 半径
-- @return nil
-- @@说明:nodes看成一个整体A,A的中心X要对其panel的中心X
-- @@**条件:panel和nodes里面的节点都要同一个父节点
function NodeUtils:centerNodes(panel, nodes)
    -- 求panel的中心X
    local pnl_box = panel:getBoundingBox()
    local center_x =  cc.rectGetMidX(pnl_box)
    -- 获取所有节点boudingbox
    local boxs = {}
    for i = 1,#nodes do
        local node = nodes[i]
        table.insert(boxs,node:getBoundingBox())
    end
    --计算整体Rect的最右边 和最左边
    local rightest,leftest;
    for i = 1,#boxs do
        local box = boxs[i]
        local max_x = cc.rectGetMaxX(box)
        if not rightest or max_x>rightest then
            rightest = max_x
        end
        if not leftest or box.x < leftest then
            leftest = box.x
        end
    end
    --计算中点
    local mid_x = (leftest + rightest) / 2
    --计算整体中点和实际中点的差值
    local diff_x = mid_x - center_x
    --nodes一起偏移
    for i = 1,#nodes do
        nodes[i]:setPositionX( nodes[i]:getPositionX() - diff_x)
    end
end

-- 把一堆节点一个rect,rect的中心x跟pnl的中心对准x
-- @param  pnl 要对准的pnl
-- @param  nodes [] 节点
-- @return nil
-- @@说明:nodes看成一个整体A,A的中心X要对其panel的中心X
-- @@说明:Y方向参考centerNodesGlobalY
function NodeUtils:centerNodesGlobal(pnl,nodes)
    -- 求panel的中心X
    local pnl_box = pnl:getBoundingBox()
    local pnl_world_pos = pnl:getWorldPosition()

    --//null
    print(pnl_world_pos.x.."-----------world pos--------"..pnl_world_pos.y)
    local pnl_anchor_point = pnl:getAnchorPoint()
    pnl_box.x = pnl_world_pos.x - pnl_anchor_point.x*pnl_box.width

    local center_x =  cc.rectGetMidX(pnl_box)
    -- 获取所有节点boudingbox
    local boxs = {}
    for i = 1,#nodes do
        local node = nodes[i]
        local box = node:getBoundingBox()
        local node_world_pos = node:getWorldPosition()
        local node_anchor_point = node:getAnchorPoint()
        box.x = node_world_pos.x - node_anchor_point.x*box.width
        table.insert(boxs,box)
    end
    --计算整体Rect的最右边 和最左边
    local rightest,leftest;
    for i = 1,#boxs do
        local box = boxs[i]
        local max_x = cc.rectGetMaxX(box)
        if not rightest or max_x>rightest then
            rightest = max_x
        end
        if not leftest or box.x < leftest then
            leftest = box.x
        end
    end
    --计算中点
    local mid_x = (leftest + rightest) / 2
    --计算整体中点和实际中点的差值
    local diff_x = mid_x - center_x
    --nodes一起偏移
    for i = 1,#nodes do
        nodes[i]:setPositionX( nodes[i]:getPositionX() - diff_x)
    end
end


-- 把一堆节点一个rect,rect的中心x跟pnl的中心对准Y
-- @param  pnl 要对准的pnl
-- @param  nodes [] 节点
-- @return nil
-- @@说明:nodes看成一个整体A,A的中心X要对其panel的中心Y
-- @@Y方向
-- @@说明:X方向参考centerNodesGlobalX
function NodeUtils:centerNodesGlobalY(pnl,nodes)
    -- 求panel的中心X
    local pnl_box = pnl:getBoundingBox()
    local pnl_world_pos = pnl:getWorldPosition()
    local pnl_anchor_point = pnl:getAnchorPoint()
    pnl_box.y = pnl_world_pos.y - pnl_anchor_point.y*pnl_box.height

    local center_y =  cc.rectGetMidY(pnl_box)
    -- 获取所有节点boudingbox
    local boxs = {}
    for i = 1,#nodes do
        local node = nodes[i]
        local box = node:getBoundingBox()
        local node_world_pos = node:getWorldPosition()
        local node_anchor_point = node:getAnchorPoint()
        box.y = node_world_pos.y - node_anchor_point.y*box.height
        table.insert(boxs,box)
    end
    --计算整体Rect的最右边 和最左边
    local topest,bottomest;
    for i = 1,#boxs do
        local box = boxs[i]
        local max_y = cc.rectGetMaxY(box)
        if not topest or max_y>topest then
            topest = max_y
        end
        if not bottomest or box.y < bottomest then
            bottomest = box.y
        end
    end
    --计算中点
    local mid_y = (bottomest + topest) / 2
    --计算整体中点和实际中点的差值
    local diff_y = mid_y - center_y
    --nodes一起偏移
    for i = 1,#nodes do
        nodes[i]:setPositionY( nodes[i]:getPositionY() - diff_y)
    end
end



--函数功能:widget会设置到topPanel 跟 distanceY(这个是离屏幕底部的距离) 之间
--param:widget 目标节点
--param:topPanel 参照节点
--param:distanceY 离屏幕底部的距离
--注意:会把widget的中心点为标准来对齐的
function NodeUtils:adaptiveCenterPanel(widget,topPanel,distanceY)
    distanceY = distanceY or 0
    local topPos = topPanel:getWorldPosition()
    local topBox = topPanel:getBoundingBox()
    local topAnchor = topPanel:getAnchorPoint()
    local topY = topPos.y - topBox.height * topAnchor.y

    local mid = (topY + distanceY) / 2

    local parent = widget:getParent()
    local curPos = parent:convertToNodeSpace(cc.p(0,mid))--x随便设置都可以

    local wAnchor = widget:getAnchorPoint()
    local wBox = widget:getBoundingBox()

    widget:setPositionY(curPos.y -  wBox.height / 2 )
end

--函数功能:把节点的名称作为父节点的key来访问
--parent:作为依赖的节点,nil的使用,用target作为依赖节点
--target:作为递归的节点
--level:target递归的层级
function NodeUtils:setNodeNameForKey(target,level,parent)
    if not target then
        return
    end
    parent = parent or target
    if level then
        level = level - 1
        local children = target:getChildren()
        for _,child in pairs(children) do
            local name = child:getName()
            parent[name] = child
            if level > 0 then
                self:setNodeNameForKey(target,level,parent)
            end
        end
    else--深递归
        local children = target:getChildren()
        for _,child in pairs(children) do
            local name = child:getName()
            parent[name] = child
            self:setNodeNameForKey(target,level,parent)
        end
    end
end




--让widget 到达水平线 也就是屏幕 y=dy的位置
--parm node:节点
--param ScreenX:屏幕x ,省略=不设
--param ScreenY:屏幕y ,省略=不设
--注意,要在addChild之后设置
function NodeUtils:adaptiveSetScreenPosition(node,ScreenX,ScreenY)
    if node then
        local parent = node:getParent()
        if parent then
            -- local box = widget:getBoundingBox() --这个x ,y就是对应的世界坐标
            local tmpx = ScreenX or 0
            local tmpy = ScreenY or 0
            local toScreenPos = cc.p(tmpx,tmpy)
            local pos = parent:convertToNodeSpace(toScreenPos)
            if ScreenX then
                node:setPositionX(pos.x)
            end
            if ScreenY then
                node:setPositionY(pos.y)
            end
        else
            logger:error("NodeUtils:adaptiveSetScreenPosition(node,ScreenX,ScreenY) 要在addChild之后设置")
            return
        end
    end

end


