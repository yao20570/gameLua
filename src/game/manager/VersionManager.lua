
--版本管理器

VersionManager = {}

function VersionManager:loadServerVersion(luaStr)
    local versionConfigFun = loadstring(luaStr)
    local versionConfig = versionConfigFun()
    
    self._versionConfig = versionConfig
    self._moduleVersionMap = versionConfig.moduleMap or {}
    return versionConfig
end

--版本是否要显示悬浮框 IOS审核特有
function VersionManager:isShowFloatIcon()
    if self._versionConfig == nil then
        return true
    end
    
    if self._versionConfig.isShowFloatIcon == nil then
        return true
    end
    
    return self._versionConfig.isShowFloatIcon
end

--版本是否要显示排行榜IOS审核特有
function VersionManager:isShowRank()
    if self._versionConfig == nil then
        return true
    end

    if self._versionConfig.isShowRank == nil then
        return true
    end

    return self._versionConfig.isShowRank
end

--版本是否要显示CDKey IOS审核特有
function VersionManager:isShowCDKey()
    if self._versionConfig == nil then
        return true
    end

    if self._versionConfig.isShowCDKey == nil then
        return true
    end

    return self._versionConfig.isShowCDKey
end

--设置进入审核状态
function VersionManager:setToReviewed()
    if self._versionConfig == nil then
        return
    end
    self._versionConfig.isShowFloatIcon = false
    self._versionConfig.isShowRank = false
    self._versionConfig.isShowCDKey = false
end

--获取具体对应的模块版本信息
function VersionManager:getModuleVersionInfo(moduleName)
    local versionMap = self._moduleVersionMap or {}
    return versionMap[moduleName]
end


function VersionManager:getMainVersion()
    if self._versionConfig == nil or  self._versionConfig == 0 then
        return 1
    end
    
    return self._versionConfig.mainVersion
end

function VersionManager:getSubVersion()
    if self._versionConfig == nil or self._versionConfig == 0 then
        return 0
    end

    return self._versionConfig.subVersion
end

function VersionManager:splitContent(content,isISBN)
    local tab = string.split(content, "\n")
    local newSub = nil
    for k,sub in pairs(tab) do
        if isISBN == true then
            if string.find(sub,"ISBN") then
                return "\n" .. sub
            end
        else
            if string.find(sub,"ISBN") == nil then
                if newSub == nil then
                    newSub = sub
                else
                    newSub = newSub .. "\n" .. sub
                end
            end            
        end
    end
    return newSub
end

--获取版本字符串
function VersionManager:getVersionName()
    local defVersion = "0.0.0.0"
    if self._versionConfig == nil or self._versionConfig == 0 then
        return defVersion -- 默认显示
    end

    if self._versionConfig.versionName then -- "当前版本：XXXX"
        defVersion = self._versionConfig.versionName
    end

    return defVersion
end

--获取著作人信息
function VersionManager:getIncName()
    local incName = "著作权人：上海游民网络科技有限公司 出版单位：上海科学技术文献出版社有限公司\n"
    if self._versionConfig == nil or self._versionConfig == 0 then
        return incName -- 默认显示
    end

    if self._versionConfig.incName then -- 著作人信息
        incName = self._versionConfig.incName
    end

    return incName
end

-- 有就读取服务器信息，没有就默认
function VersionManager:getISBNName()
    local isbn = "文网游备字[2016]M-SLG1470号  ISBN 978-7-7979-0012-6  新广出审[2016]1182号"
    if self._versionConfig == nil or self._versionConfig == 0 then
        return isbn -- 默认显示
    end

    if self._versionConfig.isbnName then
        isbn = self._versionConfig.isbnName
        isbn = string.gsub(isbn, "\n", "  ") -- 筛选空格
    end
    return isbn
end

-- --获取版本字符串
-- function VersionManager:getVersionName()
--     if self._versionConfig == nil or self._versionConfig == 0 then
--         return "0.0.0.0"
--     end
--     return self._versionConfig.versionName or "0.0.0.0"
-- end

-- function VersionManager:getISBNName()
--     local isbn = "文网游备字[2016]M-SLG1470号 \nISBN 978-7-7979-0012-6 \n新广出审[2016]1182号"
--     if self._versionConfig == nil or self._versionConfig == 0 then
--         return isbn
--     end
--     return self._versionConfig.isbnName or isbn
-- end

-- function VersionManager:getVersionStr()
--     return self:getVersionName()
-- end
-- 有就读取服务器信息，没有就默认
function VersionManager:getVersionStr()
    local inc = self:getIncName()
    local version = self:getVersionName()
    local info = inc .. version
    return info
end

function VersionManager:getServerSrcVersion()
    local mainVersion = self:getMainVersion()
    local subVersion = self:getSubVersion()
    local version = mainVersion .. "." .. subVersion
    return version
end

function VersionManager:getPackageInfo(packageName)
    local mainVersion = self:getMainVersion()
    local packageMap = self._versionConfig.packageMap
    local name = mainVersion .. "-" .. packageName
    return packageMap[name]
end

--检查下载后的文件数
function VersionManager:checkDownloadFile(packageName)
    local result = true
    local mainVersion = self:getMainVersion()
    local name = mainVersion .. "-" .. packageName .. ".txt"
    local isExist = cc.FileUtils:getInstance():isFileExist(name)
    if isExist == false then
        result = false  --该文件不存在，更新失败
    else
        local downloadCount = cc.FileUtils:getInstance():getStringFromFile(name)
        local info = self:getPackageInfo(packageName)
        local serverCount = info.fileNum --self._packagesInfo[self._downloadPreName]
        if tonumber(downloadCount) ~= tonumber(serverCount) then
            result = false --数量不一致，更新失败
        end
    end
    
    return result
end














