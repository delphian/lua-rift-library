
AOMRift.UI = {}

-- Create a RiftWindow that is dragable.
-- Example:
--   rw = AOMRift.UI:window("My Window", 200, 300)
--   function rw.frame.Event.LeftClick()
--     print("Left Click!")
--   end
-- 
function AOMRift.UI:window(title, width, height)
  -- Create a self contained object.
  local o = {}
  setmetatable(o, self)
  self.__index = self
  -- Create the context and window
  o.context = UI.CreateContext(title)
  o.window = UI.CreateFrame("RiftWindow", title, o.context)
  o.window:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
  o.window:SetWidth(width)
  o.window:SetHeight(height)
  o.window:SetTitle("")
  o.window:SetVisible(true)  
  -- Make the window dragable.  
  o.window.dragWindow = UI.CreateFrame("Frame", o.window:GetName().."Drag", o.window:GetBorder())
  o.window.dragWindow:SetAllPoints(o.window)
  function o.window.dragWindow.Event:LeftDown()
    self.leftDown = true
    local mouse = Inspect.Mouse()
    self.originalXDiff = mouse.x - self:GetLeft()
    self.originalYDiff = mouse.y - self:GetTop()
  end
  function o.window.dragWindow.Event:LeftUp()
    self.leftDown = false
  end
  function o.window.dragWindow.Event:LeftUpoutside()
    self.leftDown = false
  end
  function o.window.dragWindow.Event:MouseMove(x, y)
    if not self.leftDown then
      return
    end
    o.window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
  end
  -- Create inner black frame.
  o.frame = UI.CreateFrame("Frame", "My Frame", o.window)
  o.frame:SetPoint("TOPLEFT", o.window, "TOPLEFT", math.floor(width * 0.05), math.floor(height * 0.15))
  o.frame:SetBackgroundColor(0, 0, 0, 190)
  o.frame:SetWidth(math.floor(width * 0.9))
  o.frame:SetHeight(math.floor(height * 0.8))
  o.frame:SetVisible(true)
  return o
end
