-- Override the original logic. 
-- No point keeping+calling the original: if it's ever updated or other mods change the logic somehow, stuff would most likely break anyway.

ISConsolidateDrainableAll.stop = function (self)
  -- original logic:
  self.drainable:setJobDelta(0.0)

  for _,i in pairs(self.consolidateList) do
      i:setJobDelta(0.0)
  end

  ISBaseTimedAction.stop(self)

  -- additional logic to perform partial consolidations:
  local delta = self:getJobDelta()
  local n = math.floor(delta * #self.consolidateList)

  print(string.format("[Consolidate All] Stopped @ %.1f%% progress (time=%d/maxTime=%d) --> perform %d consolidations (out of the original %d).", delta*100, self.action:getCurrentTime(), self.maxTime, n, #self.consolidateList))

  if n > 0 then
    -- generate a subset of the original consolidateList.
    -- Note: we include the self.drainable in the list, no need for duplicate logic.
    --local partialConsolidateList = { self.drainable, table.unpack(self.consolidateList, 1, n) }
    local partialConsolidateList = { self.drainable }
    
    for i = 1, n do
      table.insert(partialConsolidateList, self.consolidateList[i])
    end

    -- Mimic the the original ISConsolidateDrainableAll.perform() logic
    local isTaintedWater = false
    local totalDelta = 0

    -- get combined useDelta of items
    for _,i in pairs(partialConsolidateList) do
      totalDelta = totalDelta + i:getUsedDelta()

      if i:isTaintedWater() then
        isTaintedWater = true -- if any of the items has tainted water, consider all tainted
      end
    end

    -- set useDelta of items, and use up items which are at zero
    for _,i in pairs(partialConsolidateList) do
      i:setTaintedWater(isTaintedWater)
      i:setUsedDelta(math.min(1, totalDelta))
      totalDelta = totalDelta - math.min(1, totalDelta)

      if i:getUsedDelta() <= 0.0001 then
        i:Use()
      end
    end
  end

end
