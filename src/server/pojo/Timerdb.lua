-------------------
-----定时器数据-------
--------------
module("server", package.seeall)

Timerdb = class("Timerdb")

function Timerdb:ctor()
    self.id = 0
    self.type = 0 --;
    self.lestime = 0 --;
    self.lasttime  = 0 --;
    self.refreshType = 0 --;//点击触发的通过通过调用方法填具体时间，其它填-1
    self.otherType = 0 --;
    self.smallType = 0 --;
    self.num = 0 --;
    self.attr1 = 0;
    self.attr2 = 0;
    self.attr3 = 0;
    self.begintime = 0 --;
end