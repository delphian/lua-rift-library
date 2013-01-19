
-- Helper functions for manipulating and transversing currencies.

-- Our object.
AOMRift.Currency = {
  detail = {},
  category = {},
  -- Copy of detail object.
  id = nil,
  name = nil,
  icon = nil,
  value = nil,
}

--
-- Determine if currency identifier is valid or not.
--
-- @param mixed currency_id
--   Can be any data type containing any value, including nil.
--
-- @return
--   (bool) true or false.
--
function AOMRift.Currency.exists(currency_id)
  local report = false
  if type(currency_id) == "string" then 
    local currency = Inspect.Currency.Detail(currency_id)
    if type(currency) == "table" then
      report = true
    end
  end
  return report
end

--
-- Load up AOMRift.Currency object with a currency.
--
-- @param string currency_id
--   Rift currency_id to load.
--
-- @return
--   (AOMRift.Currency) self contained object with currency data.
--   or nil if there was an error loading.
--
function AOMRift.Currency:load(currency_id)
  if AOMRift.Currency.exists(currency_id) == nil then
    return nil
  end
  -- Create a self contained object.
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.detail = Inspect.Currency.Detail(currency_id)
  o.category = Inspect.Currency.Category.Detail(o.detail.category)
  -- Map detail record to base object.
  o.id          = o.detail.id
  o.name        = o.detail.name
  o.value       = o.detail.stack
  o.icon        = o.detail.icon or "Data/\\UI\\item_icons\\loot_platinum_coins.dds"
  
  return o
end
