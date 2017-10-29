-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CommentPanel = class("CommentPanel", BasicPanel)
CommentPanel.NAME = "CommentPanel"
 
function CommentPanel:ctor(view, panelName)
    CommentPanel.super.ctor(self, view, panelName, true)

    self:setUseNewPanelBg(true)
end

function CommentPanel:finalize()
    CommentPanel.super.finalize(self)
end

function CommentPanel:initPanel()
	CommentPanel.super.initPanel(self)

    self:setBgType(ModulePanelBgType.NONE)

    self:setTitle(true,"comment",true)

    self._commentProxy = self:getProxy(GameProxys.Comment)

    -- 获取配置数据
    self._commentSetConfig = ConfigDataManager:getConfigById(ConfigData.CommentSetConfig, 1)
    self._maxBestNum = self._commentSetConfig.bestNum
end

function CommentPanel:registerEvents()
	CommentPanel.super.registerEvents(self)
    self._topPanel = self:getChildByName("topPanel") 
    self._commentBtn = self._topPanel:getChildByName("commentBtn")

    self:addTouchEventListener(self._commentBtn, self.onCommentBtn)

    self._listview = self:getChildByName("listView")
    self._nameTxt = self._topPanel:getChildByName("nameTxt")
    self._emptyTxt = self._topPanel:getChildByName("emptyTxt")
    self._emptyTxt:setString(self:getTextWord(470003))
    self._emptyTxt:setVisible(false)
end

function CommentPanel:doLayout()
    NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self._listview, GlobalConfig.downHeight, GlobalConfig.topHeight, 4)
end

function CommentPanel:onClosePanelHandler()
    self:dispatchEvent(CommentEvent.HIDE_SELF_EVENT, {})
end

function CommentPanel:onShowHandler(extraMsg)
    self._listview:setVisible(false)
    self._targetMsg = extraMsg
    if extraMsg then
        self._typeId   = extraMsg.typeId
        self._childId  = extraMsg.childId
        self._titleName= extraMsg.name
        logger:info("当前TypeID："..self._typeId .."当前childId："..self._childId.."当前的名字"..self._titleName)
        -- 发送消息
        self:allCommentReq(self._typeId, self._childId)
    end


    -- 设置名称
    self:setTypeName()
    
end

function CommentPanel:updateCommentListView(data)
    self._listview:setVisible(true)

    self:isShowEmptyTxt(#data) -- 是否显示空白字符串
    self:renderListView(self._listview, data, self, self.renderCommentItem)
    self._listview:refreshView()
end

function CommentPanel:renderCommentItem(itemPanel, info, index)
    --print("渲染index".. index + 1)
    local midImg = itemPanel:getChildByName("midImg")
    local content = itemPanel:getChildByName("contentTxt") -- 根据文本高度动态改动高度
    content:setString(info.content)
    
    --------------------------------------------------------------


    -- 设置角色名
    local writerTxt = itemPanel:getChildByName("writerTxt")
    local writerName = info.playerName -- 角色名
    local areaKey    = info.areaKey
    writerTxt:setString(info.playerName)

    -- 是否显示神评和改变相关背景
    local bestMarkIcon = itemPanel:getChildByName("bestMarkIcon")
    bestMarkIcon:setVisible(index + 1 <= self._maxBestNum)
    if index + 1 <= self._maxBestNum then
        -- 神评论
        midImg:setColor( cc.c3b(255, 255, 255))
    else

        midImg:setColor( cc.c3b(200, 200, 200))
    end



    -- 显示点赞数upNum
    local likeNumTxt = itemPanel:getChildByName("likeNumTxt") 

    likeNumTxt:setString( StringUtils:formatNumberByK4(info.upNum))

    -- 是否点了赞0-未点赞 1-已点赞
    local likeImg   = itemPanel:getChildByName("likeImg") 
    local unlikeImg = itemPanel:getChildByName("unlikeImg") 
    likeImg:setVisible(info.isUp == 1)
    unlikeImg:setVisible(info.isUp == 0)
    likeImg.info = info
    unlikeImg.info = info
    unlikeImg.index = index + 1 

    self:addTouchEventListener(unlikeImg, self.onLikeReq)
end

function CommentPanel:onCommentBtn(sender)
    local boardPanel = self:getPanel(CommentBoardPanel.NAME)
    
    boardPanel:show()
end

-- 获取来源信息
function CommentPanel:getTargetMsg()
    return self._targetMsg
end


-- 点赞
function CommentPanel:onLike()
    local data = {}
    data.typeId     = self._typeId
    data.childId    = self._childId
    data.commentId  = self._commentId

    self._commentProxy:onTriggerNet420002Req(data)
end

-- 获取列表请求
function CommentPanel:allCommentReq(typeId, childId )
    -- 发送数据请求
    local data = {}
    data.typeId  = typeId 
    data.childId = childId
    self._commentProxy:onTriggerNet420000Req(data)
end


-- 回调
function CommentPanel:updateCommentPanel()
    local data = self._commentProxy:getCommentData()
    self:updateCommentListView(data)
end

-- 点赞刷新
function CommentPanel:updateLikeNum()
    local data = self._commentProxy:getCommentData()
    self:updateCommentListView(data)
end

-- 设置type名
function CommentPanel:setTypeName()
    local str = self._titleName 
     print(self._typeId.."------------1---------------"..self._titleName)
    if str == "" then
        str = self._commentProxy:getTypeName(self._typeId)
        print(str.."__--------------------___str")
    end
    print(self._typeId.."-------------2-------------"..self._titleName)
    self._nameTxt:setString(str)
end


function CommentPanel:onLikeReq(sender)
    local info = sender.info
    local data = {}
    data.typeId    = info.typeId   
    data.childId   = info.childId  
    data.commentId = info.commentId
    self._commentProxy:onTriggerNet420002Req(data)
    
    self._commentProxy:setReqLikeIndex(sender.index)
    
end

function CommentPanel:isShowEmptyTxt(count)
    if count == 0 then
        self._emptyTxt:setVisible(true)
    else
        self._emptyTxt:setVisible(false)
    end
end