
AOMRift.UI = {
  debug = false,
}

--
-- Make an existing frame dragable.
--
-- Creates a new child frame on the existing frame. Sizes new frame to the
-- same size as the parent and sets opacity to invisible. Attatches event
-- handlers on child frame that will respond to click and hold drags.
--
-- @param (frame) frame
--
-- @return
--   Does not return anything. Modifies object passed in as function argument.
--
function AOMRift.UI:Draggable(frame)
  frame.dragWindow = UI.CreateFrame("Frame", "Draggable", frame)
  frame.dragWindow:SetAllPoints(frame)
  frame.dragWindow:SetLayer(1)
  function frame.dragWindow.Event:LeftDown()
    self.leftDown = true
    local mouse = Inspect.Mouse()
    self.originalXDiff = mouse.x - self:GetLeft()
    self.originalYDiff = mouse.y - self:GetTop()
  end
  function frame.dragWindow.Event:LeftUp()
    self.leftDown = false
  end
  function frame.dragWindow.Event:LeftUpoutside()
    self.leftDown = false
  end
  function frame.dragWindow.Event:MouseMove(x, y)
    if not self.leftDown then
      return
    end
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
  end
end

--
-- Add a close button to an existing frame.
--
-- Creates a child frame onto an existing frame. Arguments to the function
-- describe what image will be used for the close button and where it will
-- be positioned. Adds an event listener to the button that will close the
-- parent frame when clicked.
--
-- @param (frame)  frame  The parent frame.
-- @param (int)    top    Offset from the top of the parent window to 
--                        position button. Defaults to 0.
-- @param (int)    right  Offset from the right of the parent window to
--                        position button. Defaults to 0.
-- @param (int)    width  Width of the image. Defaults to 30.
-- @param (int)    height Height of the image. Defaults to 30.
-- @param (string) image  The image to display as close button. Path is
--                        relative to the base addon. A default image will be
--                        used if this parameter is nil.
--
-- @return
--   Returns nothing. Modofies frame object passed into function.
--
-- Example:
--   -- 5 pixels above top, 10 pixels right of right, 60 pixels width, 80 pixels
--   -- tall, use a speicifc image.
--   AOMRift.UI:CloseButton(parentFrame, -5, 10, 60, 80, "AOMRift/images/close.png")
--
function AOMRift.UI:CloseButton(frame, top, right, width, height, image, source)
  local position = {
    width  = width,
    height = height,
    top    = top,
    right  = right,
  }
  local background = {
    image  = image or "images/close.png",
    source = source or "AOMRift",
  }
  frame.closeButton = self:Content(frame, position, background) 
  frame.closeButton:SetLayer(99) 
  function frame.closeButton.Event:LeftClick()
    frame:SetVisible(false)
  end  
end

--
-- Creates a child frame.
--
-- Reduces the creation of a child frame to configuration of data
-- structures.
--
-- @param frame parentFrame
--   The parent frame.
-- @param table position (optional)
--   Top, left, right and bottom are padding that the new child window should
--   have between itself and it's parent. Positive values shrink the child 
--   window, negative expand. If width and height are specified then only
--   one set of padding (two values) are required (top/left, top/right,
--   bottom/left, bottom/right). 
--   - int width: (optional) The width of the child frame.
--   - int height: (optional) The height of the child frame.
--   - int top: Padding between top edges of child and parent frames.
--   - int left: Padding between left edges of child and parent frames.
--   - int right: Padding between right edges of child and parent frames.
--   - int bottom: Padding between bottom edges of child and parent frames.
-- @param table background (optional)
--   Color, transparancy and image that the background should have. All values
--   default to 0, alpha defaults to 1:
--   - int red: Red color value (0-1).
--   - int green: Green color value (0-1).
--   - int blue: Blue color value (0-1).
--   - int alpha: Transparacy setting (0 = transparent, 1 = opaque).
--   - string image: Path to an image to display as background. If image
--     is specified then RGB values will be ignored.
--   - string source: The name of the addon, or "Rift", which supplies
--     the image. The path is relative to the addon's directory.
-- @param string childFrameType (optional)
--   The type of child frame to create. Defaults to "Frame"
--
-- @return
--   (table) The new child frame which has been attatched to the parent.
--
-- @example
--   -- Create frame 100x50 positioned 25x25 inside parent frame with red
--   -- background and halfway transparent.
--   AOMRift.UI:Content(frame, { width = 100, height = 50, left = 25, top = 25 },
--     { red = 255, alpha = 0.5 }, "Frame")
--   -- Create frame 20 pixels down from top of parent, 10 pixels inside of
--   -- parent's left and right sides, 5 pixels above parent's bottom, with
--   -- a black solid background.
--   AOMRift.UI:Content(frame, { top = 20, right = 10, left = 10, bottom = 5 })        
--
function AOMRift.UI:Content(parentFrame, position, background, childFrameType)
  local content = nil
  local childFrameType = childFrameType or "Frame"
  if type(position) ~= "table" then
    position = { top = 0, right = 0, bottom = 0, left = 0 }
  end
  if type(background) ~= "table" then
    background = { red = 0, green = 0, blue = 0, alpha = 1 }
  end
--  if background.image then
--    defaultAlpha = 0
--  end
  background = {
    image  = background.image or nil,
    source = background.source or "Rift",
    red    = background.red or 0,
    green  = background.green or 0,
    blue   = background.blue or 0,
    alpha  = background.alpha or 1,
  }

  if self.debug == true then
    print(AOMLua:print_r(position, "Position"))
    print(AOMLua:print_r(background, "Background"))
  end
  if background.image == nil then
    content = UI.CreateFrame(childFrameType, "Content", parentFrame)
    content:SetBackgroundColor(background.red, background.green, background.blue, background.alpha)
  else
    content = UI.CreateFrame("Texture", "Content", parentFrame)
    content:SetTexture(background.source, background.image)
    content:SetAlpha(background.alpha)  
  end
  -- Size the new frame.
  if (position["left"] ~= nil and position["top"] ~= nil) then
    content:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", position.left, position.top)
  end
  if (position["right"] ~= nil and position["top"] ~= nil) then
    content:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", -position.right, position.top)
  end
  if (position["left"] ~= nil and position["bottom"] ~= nil) then
    content:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", position.left, -position.bottom)
  end
  if (position["right"] ~= nil and position["bottom"] ~= nil) then
    content:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -position.right, -position.bottom)
  end
  if (position.width ~= nil) then
    content:SetWidth(position.width)
  end
  if (position.height ~= nil) then
    content:SetHeight(position.height)
  end
  -- Layer and make visible.  
  content:SetLayer(5)
  content:SetVisible(true)
  return content
end

--
--
--
function AOMRift.UI:Attatch(childFrame, parentFrame, side)
  if ((type(childFrame) ~= "table") or (type(parentFrame) ~= "table")) then
    print("Invalid parameter")
    return false
  end
  childFrame:ClearPoint("TOPLEFT")
  childFrame:ClearPoint("TOPRIGHT")
  childFrame:ClearPoint("BOTTOMLEFT")
  childFrame:ClearPoint("BOTTOMRIGHT")
  -- Attatch child frame to bottom of parent frame.
  if (string.lower(side) == "bottom") then
    childFrame:SetPoint("TOPLEFT", parentFrame, "BOTTOMLEFT", 0, 0)
    childFrame:SetPoint("TOPRIGHT", parentFrame, "BOTTOMRIGHT", 0, 0)
  end
  -- Attatch child frame to right of parent frame.
  if (string.lower(side) == "right") then
    childFrame:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 0, 0)
    childFrame:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMRIGHT", 0, 0)
  end
  return true
end

--
-- Create a graphic border for one side of a frame.
--
-- @param (frame) frame  The parent frame we will be constructing a border on.
-- @param 
function AOMRift.UI:Border(frame, side, depth, background)
  depth = depth or 5
  if (string.lower(side) == "top") then
    position = {height = depth, top = 0, left = 0, right = 0}
  end
  if (string.lower(side) == "bottom") then
    position = {height = depth, bottom = 0, left = 0, right = 0}
  end
  if (string.lower(side) == "left") then
    position = {width = depth, bottom = 0, top = 0, left = 0}
  end
  if (string.lower(side) == "right") then
    position = {width = depth, bottom = 0, top = 0, right = 0}
  end
  bar = self:Content(frame, position, background)
  return bar
end

--
-- Resize a window. Reframes borders around new window size.
--
function AOMRift.UI:resize(window, width, height)
  window:SetWidth(width)
  window:SetHeight(height)
end

--
-- Create a RiftWindow that is dragable.
-- Example:
--   rw = AOMRift.UI:window("My Window", 200, 300)
--   function rw.frame.Event.LeftClick()
--     print("Left Click!")
--   end
-- 
function AOMRift.UI:Window(title, width, height)
  -- Create the context and window
  local context = UI.CreateContext(title)
  local window = UI.CreateFrame("Frame", title, context)
  window:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
  window:SetWidth(width + 2)
  window:SetHeight(height + 12)
  window:SetBackgroundColor(0, 0, 0, 0)
  window:SetVisible(true)
  -- Make the window draggable.
  self:Draggable(window)
  -- Setup the borders.
  window.borderTop    = self:Border(window, "top",    10)
  window.borderBottom = self:Border(window, "bottom", 2)
  window.borderLeft   = self:Border(window, "left",   1)
  window.borderRight  = self:Border(window, "right",  1)
  -- Setup content area.
  window.content = self:Content(window, {top=10, right=1, bottom=2, left=1}, {alpha=0.5}) 
  -- Add a close button.
  self:CloseButton(window, -5, -5, 20, 20)
  return window
end
