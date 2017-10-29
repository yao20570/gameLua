CommentProxy = class("CommentProxy", BasicProxy)


function CommentProxy:ctor()
    CommentProxy.super.ctor(self)
    self.proxyName = GameProxys.Comment

    self._commentData = {} -- 评论信息
end


function CommentProxy:initSyncData(data)


end

-- 断线重置
function CommentProxy:resetAttr()

end


------
-- M420000 获得评论信息列表
function CommentProxy:onTriggerNet420000Req(data)
    self:syncNetReq(AppEvent.NET_M42, AppEvent.NET_M42_C420000, data)
end

------
-- M420001 发送点评
function CommentProxy:onTriggerNet420001Req(data)
    self:syncNetReq(AppEvent.NET_M42, AppEvent.NET_M42_C420001, data)
end

------
-- M420002 点赞
function CommentProxy:onTriggerNet420002Req(data)
    self:syncNetReq(AppEvent.NET_M42, AppEvent.NET_M42_C420002, data)
end


------
-- M420000 获得评论信息列表
function CommentProxy:onTriggerNet420000Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._typeId  = data.typeId
    self._childId = data.childId
    self._commentData = data.commentInfo
    
    self:sendNotification(AppEvent.PROXY_COMMENT_ON_SHOW, {})
end

------
-- M420001 发送点评，全部刷
function CommentProxy:onTriggerNet420001Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._typeId  = data.typeId
    self._childId = data.childId
    self._commentData = data.commentInfo
    
    self:sendNotification(AppEvent.PROXY_COMMENT_DID_COMMENT, {})
end

------
-- M420002 点赞，自己刷
function CommentProxy:onTriggerNet420002Resp(data)
    if data.rs ~= 0 then
        return
    end

    local newUpNum = data.upNum
    local isUp     = 1 -- 0-未点赞 1-已点赞
    
    if self._likeIndex then
        local info = self._commentData[self._likeIndex]
        info.upNum = newUpNum
        info.isUp  = isUp
        self._likeIndex = nil
    end
    

    self:sendNotification(AppEvent.PROXY_COMMENT_DID_LIKE, {})
end

------
-- 获取评论信息表
function CommentProxy:getCommentData()
    -- 排序
    local data = self:sortListData(self._commentData)
    self._commentData = data
    return self._commentData
end


-- 类型  1-兵营 2-武将 3-太学院 4-战法 5-军师 
-- 子类id 0-表示没有子类
function CommentProxy:toCommentModule(typeId, childId, name)
    local data = {}
    data.moduleName = ModuleName.CommentModule
    data.extraMsg = {}
    data.extraMsg.typeId  = typeId
    data.extraMsg.childId = childId
    data.extraMsg.name    = name or ""
    self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT, data)
end

function CommentProxy:getTypeName(id)
    local str = ""
    local commentMoldConfig = ConfigDataManager:getConfigById(ConfigData.CommentMoldConfig, id)
    if commentMoldConfig.commentType2 == 0 then
        str = commentMoldConfig.commentName
    end
    return str
end

-- 保存点赞的那个index
function CommentProxy:setReqLikeIndex(index)
    self._likeIndex = index
end

function CommentProxy:getReqLikeIndex()
    return self._likeIndex
end

function CommentProxy:sortListData(data)
    -- 获取配置数据
    self._commentSetConfig = ConfigDataManager:getConfigById(ConfigData.CommentSetConfig, 1)
    self._maxBestNum = self._commentSetConfig.bestNum

    if #data <= self._maxBestNum then
        -- 未超过神评数
        table.sort(data,
        function(item01, item02, index)
            local upNum01 = item01.upNum
            local upNum02 = item02.upNum
            if upNum01 == upNum02 then
                -- 按时间先后
                return item01.time < item02.time -- 时间久的在前面
            else
                -- 点赞数从高到低
                return upNum01 > upNum02
            end
        end)

        return data
    else
        -- 超过神评数，分两种排序
        table.sort(data,
        function(item01, item02)
            local upNum01 = item01.upNum
            local upNum02 = item02.upNum
            if upNum01 == upNum02 then
                -- 按时间先后
                return item01.time < item02.time -- 时间久的在前面
            else
                -- 点赞数从高到低--
                return upNum01 > upNum02
            end
        end)

        local best = {}
        for i = 1, self._maxBestNum do
            best[i] = data[i]
        end

        local newer = {}
        local count = 1
        for key, value in pairs(data) do
            if key > self._maxBestNum then
                newer[count] = value
                count = count + 1
            end
        end

        table.sort(newer,
        function (item011, item022)
            return item011.time > item022.time -- 时间大的在前面
        end)

        -- 合并
        for key, value in pairs(newer) do
            best[self._maxBestNum + key] = value
        end
        
        -- 
        return best
    end
   
end