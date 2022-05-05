-- This restores the 41.69 (nice) logic, where it doesn't stop when the first stack is full

ISInventoryPaneContextMenu.onConsolidateAll = function(drainable, consolidateList, player)
  ISTimedActionQueue.add(ISConsolidateDrainableAll:new(player, drainable, consolidateList, 90 * #consolidateList));
end
