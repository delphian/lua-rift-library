
-- Helper functions for manipulating and transversing items.

-- Our object.
AOMRift.Item = {}

--
-- Determine if item identifier is valid or not.
--
-- @param mixed item_id
--   Can be any data type containing any value, including nil.
--
-- @return
--   (bool) true or false.
--
function AOMRift.Item.Exists(item_id)
  local report = false
  if type(item_id) == "string" then 
    local item = Inspect.Item.Detail(item_id)
    if type(item) == "table" then
      report = true
    end
  end
  return report
end

--
-- Load up AOMRift.Item object with a currency.
--
-- @param string item_id
--   Rift item_id to load.
--
-- @return
--   (AOMRift.Item) self contained object with item data.
--   or false if there was an error loading.
--
function AOMRift.Item:Load(item_id)
  if (AOMRift.Item.Exists(item_id) == false) then
    return false
  end
  -- Create a self contained object.
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.detail = Inspect.Item.Detail(item_id)
  -- Map detail record to base object.
  o.id    = o.detail.id
  o.name  = o.detail.name
  o.value = o.detail.stack or 0
  o.icon  = o.detail.icon or "Data/\\UI\\item_icons\\loot_platinum_coins.dds"
  o.description = o.detail.description
  o.type  = Inspect.Item.Detail(o.detail.type)

  return o
end
