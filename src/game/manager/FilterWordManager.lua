
FilterWordManager = {}

function FilterWordManager:init()
    self._filterWordConfig = require("excelConfig.FilterwordConfig" )
    local symbol = {"?", "？", "！", "!", ",", "，", ".", "。", " ","#", "=", "、", "（", "）", "%", "@", "+", "-", " ", "(", ")", ":", ";"}
    
    local spcKey = {"$", "[", "^"}

    self._spcWords = {}
    for k,v in pairs(spcKey) do
        self._spcWords[v] = true
    end

    self._symbols = {}
    for k,v in pairs(symbol) do
        self._symbols[v] = true
    end
end

function FilterWordManager:isEnglish(word)
    local as = word:byte()
    return ((as > 64 and as < 91) or (as > 96 and as < 123) )
end

function FilterWordManager:wordFilter(word)
    local filterWord = word
    local wordAry = StringUtils:separate(word)
    for _, word in pairs(wordAry) do
        if word:byte() <= 128 and tonumber(word) == nil and self._symbols[word] ~= true and word ~= "*"
           and self:isEnglish(word) == false then
            --特殊字符，前面要加%转义
            if self._spcWords[word] then
                word = "%"..word
                filterWord = string.gsub(filterWord, word, "**")
            else
                filterWord = string.gsub(filterWord, word, "**")
            end
        end
        local filterAry = self._filterWordConfig[word]
        if filterAry ~= nil then
            for key, filter in pairs(filterAry) do
                filterWord = string.gsub(filterWord, key, "**")
            end
    	end

    end
    
    return filterWord
end

function FilterWordManager:isHasFilterWords(word)
    local filterWord = self:wordFilter(word)
    return filterWord ~= word
end

FilterWordManager:init()