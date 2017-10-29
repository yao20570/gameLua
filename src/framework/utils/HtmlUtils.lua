
HtmlUtils        = {}

function HtmlUtils:getP(text, color, fontSize)
    color = color or "255,255,255"
    fontSize = fontSize or 20
    
    local strTable = {}
    table.insert(strTable, "<p color='")
    table.insert(strTable, color)
    table.insert(strTable, "' size='")
    table.insert(strTable, fontSize)
    table.insert(strTable, "'>")
    table.insert(strTable, text)
    table.insert(strTable, "</p>")
    local str = table.concat(strTable)
    return str
end