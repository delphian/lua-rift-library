
-- Helper functions for manipulating and transversing achievements.

-- Our object.
AOMRift.Achievement = {
  detail = {},
  category = {},
  -- Copy of detail object.
  id = nil,
  name = nil,
  description = nil,
  previous = nil,
  requirement = {},
  -- Some new values.
  complete = nil,
  current = nil,

}

--
-- Determine if an achievement identifier is valid or not.
--
-- @param mixed achievement_id
--   Can be any data type containing any value, including nil.
--
-- @return
--   (bool) true or false.
function AOMRift.Achievement.exists(achievement_id)
  local report = false
  if type(achievement_id) == "string" then 
    local achievement = Inspect.Achievement.Detail(achievement_id)
    if type(achievement) == "table" then
      report = true
    end
  end
  return report
end

--
-- Load up AOMRift.Achievement object with an achievement.
--
-- @param string achievement_id
--   Rift achievement_id to load.
--
-- @return
--   (AOMRift.Achievement) self contained object with achievement data.
--   or nil if there was an error loading.
function AOMRift.Achievement:load(achievement_id)
  if AOMRift.Achievement.exists(achievement_id) == nil then
    return nil
  end
  -- Create a self contained object.
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.detail = Inspect.Achievement.Detail(achievement_id)
  o.category = Inspect.Achievement.Category.Detail(o.detail.category)
  -- Map detail record to base object.
  o.id          = o.detail.id
  o.name        = o.detail.name
  o.description = o.detail.description
  o.requirement = o.detail.requirement
  o.previous    = o.detail.previous
  o.icon        = o.detail.icon
  -- Calculate some new values.
  o.current     = o:is_current()
  o.complete    = o:is_complete()
  
  return o
end

--
-- Determine if the achievement is complete
--
-- @return
--   (bool) true if complete, false otherwise.
function AOMRift.Achievement:is_complete()
  local report = true
  -- Check if each requirement has been completed.
  for key, requirement in pairs(self.detail.requirement) do
    if requirement["complete"] == nil then
      report = false
    end
  end
  return report
end

--
-- Retrieve a formated version of a requirement. Keeps fields standardized
-- and sets default values.
--
-- @param int req_id
--   The index into the requirement table
--
-- @return
--   (table) An individual requirement:
--   - name:     (string) name of the requirement.
--   - done:     (int)    the current amount that has been gained.
--   - total:    (int)    the total amount that must be gained.
--   - complete: (bool)   status of requirement's finished state.
--   - id:       (string) unique identifier for this requirement (not sure what this is).
--   - type:     (string) classification of this requirement. Genreally this cam
--               be one of: event, artifactset, etc.
function AOMRift.Achievement:get_req(req_id)
  local report = {
    name     = self.requirement[req_id]["name"],
    done     = self.requirement[req_id]["countDone"] or 0,
    total    = self.requirement[req_id]["count"] or 0,
    complete = self.requirement[req_id]["complete"] or false,
    id       = self.requirement[req_id]["id"] or 0,
    type     = self.requirement[req_id]["type"] or "none", 
  }
  return report
end

--
-- Get all requirements that are not yet complete.
--
-- @return
--   (table) A table of requirements or empty table if none.
function AOMRift.Achievement:get_incomplete()
  local report = {}
  for key, requirement in ipairs(self.detail.requirement) do
    if requirement["complete"] == nil then
      table.insert(report, requirement)
    end    
  end
  return report
end

--
-- Get all requirements that are complete.
--
-- @return
--   (table) A table of requirements or empty table if none.
function AOMRift.Achievement:get_complete()
  local report = {}
  for key, requirement in ipairs(self.detail.requirement) do
    if requirement["complete"] == true then
      table.insert(report, requirement)
    end    
  end
  return report
end

--
-- Determine if achievement has no previous achievements that are
-- still waiting to be completed, making this achievement the current
-- next to be achieved.
--
-- @return
--   (bool) true if this achievement is the next to be gained, false
--   otherwise.
function AOMRift.Achievement:is_current()
  local report = true
  if self.previous ~= nil then
    pre_achievement = AOMRift.Achievement:load(self.previous)
    if pre_achievement.complete == false then
      report = false
    end
  end
  return report
end
