
ByteArray = class("ByteArray")

function ByteArray:ctor()
    self.bytesAvailable = 0  --可从字节数组的当前位置到数组末尾读取的数据的字节数。
    self.length = 0 --ByteArray 对象的长度（以字节为单位）。
    self.position = 1 --当前位置 从1开始索引
    self.buffer = ""
end

--从字节流中读取带符号的字节。
function ByteArray:readByte()
    local byte = string.sub(self.buffer, self.position ,self.position)
    self.bytesAvailable = self.bytesAvailable - 1
    self.position = self.length - self.bytesAvailable + 1
    byte = string.byte(byte,1,1)
    return byte
end

function ByteArray:readShort()
    local byte1 = self:readByte()
    local byte2 = self:readByte()
    local short = byte1 * 256 + byte2
    return short
end

function ByteArray:readInt()
    local short1 = self:readShort()
    local short2 = self:readShort()
    local int = short1 * 65536 + short2
    return int
end

---实际是一个字符串
---用8位长度的string来存储64位数据
function ByteArray:readInt64()
    local int64 = ""
    local len = 8
    local i = 1
    local byte = 0
    for i = 1,len do
        byte = self:readByte()
        if byte == 0 then
            int64 = int64 .. "\\0"
        else
            int64 = int64 .. string.char(byte)
        end
    end
    return Utils:string_to_int64(int64)
end

function ByteArray:readBytes(len)
    len = len or self.length - self.position + 1 --
    
    local str = string.sub( self.buffer ,self.position, self.position + len - 1)
    
    self.position = self.position + len
    self.bytesAvailable = self.bytesAvailable - len
    return str
    
end

--从字节流中读取一个 UTF-8 字符串。假定字符串的前缀是无符号的短整型（以字节表示长度）。
function ByteArray:readUTF()
    local str = ""
    local len = self:readShort() --短整型（以字节表示长度）
    local i = 1
    local byte = 0;
    for i = 1, len do
        byte = self:readByte()
        str = str .. string.char(byte)
    end

    return str
end

function ByteArray:readUTF8()
    local str = ""
    local len = self:readByte() --短整型（以字节表示长度）
    local i = 1
    local byte = 0;
    for i = 1, len do
        byte = self:readByte()
        str = str .. string.char(byte)
    end

    return str
end

function ByteArray:readUTF32()
    local str = ""
    local len = self:readInt() --短整型（以字节表示长度）
    local i = 1
    local byte = 0;
    for i = 1, len do
        byte = self:readByte()
        str = str .. string.char(byte)
    end

    return str
end

function ByteArray:writeByte(byte)

    self.buffer = self.buffer .. string.char(byte)
    
    self.length = string.len(self.buffer)
    self.bytesAvailable = self.bytesAvailable + 1
end
--
function ByteArray:writeShort( short )
    local byte2 = short % 256
    local byte1 = ( short - byte2 ) / 256
    self:writeByte(byte1)
    self:writeByte(byte2)
end

--
function ByteArray:writeInt( int )
    local short2 = int % 65536
    local short1 = (int - short2) / 65536
    self:writeShort(short1)
    self:writeShort(short2)
end
--
-------64位整形 实际为8位字符串来存储
--function ByteArray:writeInt64( int64 )
--    local str = int64
--    local i = 1
--    local len = 0
--    local byte = string.byte(str, i)
--    while byte ~= nil do      
--        len = len + 1
--        i = i + 1
--        byte = string.byte(str, i)
--    end
--
--    self:writeByte(len)
--    i = 1
--    while(i <= len) do
--        byte = string.byte(str, i)
--        if string.char(byte) == "\\" then
--            i = i + 1
--            byte = 0
--        end
--        self:writeByte(byte)
--        i = i + 1
--    end
--end
--
----32位字符串
--function ByteArray:writeInt32( int32 )
--    local len = string.len(int32)
--    local i = 1
--    local byte = nil
--    for i = 1, len do
--        byte = string.byte(int32, i)
--        self:writeByte(byte)
--    end
--end



--写二进制串
function ByteArray:writeBytes( bytes )

    self.buffer = self.buffer .. bytes
    
    local len = string.len(self.buffer)
    
    self.bytesAvailable = len
    self.length = len
    
--    for index=1, len do
--        local byte = string.sub(bytes,index,index)
--        self:writeByte(byte)
--    end
end

--function ByteArray:writeUTF( str )
--    local i = 1
--    local len = 0
--    local byte = string.byte(str, i)
--    while byte ~= nil do
--        len = len + 1
--        i = i + 1
--        byte = string.byte(str, i)
--    end
--
--    self:writeShort(len)
--    for i=1,len do
--        byte = string.byte(str, i)
--        self:writeByte(byte)
--    end
--end

function ByteArray:getLength()
    return self.length
end

function ByteArray:toString()
    return self.buffer
end