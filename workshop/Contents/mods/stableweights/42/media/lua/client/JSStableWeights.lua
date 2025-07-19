-- ! Event Functions ! --

--Just running through all active players and calling our stable weight function
function JSStableWeightsEveryTenMinutes()
  for i = 0, getNumActivePlayers() - 1 do
    local player = getSpecificPlayer(i);
    JSStableWeightsRunStableWeight(player);
  end
end

Events.EveryTenMinutes.Add(JSStableWeightsEveryTenMinutes);

-- ! Support Functions ! --

--This is where we store the last recorded weights for each player id, necessary to calculate a delta
local JSStableWeightsLastWeight = {};

--Simply, we're just checking the current weight vs. our last recorded weight to get the delta
--Then we're overriding the weight by our last recorded weight + our modified delta value.
--If we haven't yet recorded a weight for this player, we just let this minute pass as normal.
function JSStableWeightsRunStableWeight(player)
  local rateChangeIncrease = SandboxVars.StableWeightChange.rateChangeIncrease
  local rateChangeDecrease = SandboxVars.StableWeightChange.rateChangeDecrease

  local playerID = JSStableWeightsGetPlayerID(player);

  if (JSStableWeightsLastWeight[playerID]) then
    local weightDelta = player:getNutrition():getWeight() - JSStableWeightsLastWeight[playerID];

    local targetWeight = player.getNutrition():getWeight()

    if (weightDelta < 0) then
      targetWeight = JSStableWeightsLastWeight[playerID] + weightDelta * rateChangeDecrease;
    elseif (weightDelta > 0) then
      targetWeight = JSStableWeightsLastWeight[playerID] + weightDelta * rateChangeIncrease;
    end

    player:getNutrition():setWeight(targetWeight);
  end

  JSStableWeightsLastWeight[playerID] = player:getNutrition():getWeight();
end

--Use this to get player id, checking whether we're multiplayer or not
function JSStableWeightsGetPlayerID(player)
  if (isClient() or isServer()) then
    return player:getOnlineID();
  else
    return player:getID();
  end
end

