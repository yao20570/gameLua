module("server", package.seeall)

Item = class("Item")

function Item:ctor()
    self.typeId = 0
    self.num = 0
end