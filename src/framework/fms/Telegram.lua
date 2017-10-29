Telegram = class("Telegram")

function Telegram:ctor(sender, receiver, msg, extraInfo)
    self.sender = sender
    self.receiver = receiver
    self.msg = msg
    self.dispatchTime = 0 --delay
    self.extraInfo = extraInfo ---info
end