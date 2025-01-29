local RSGCore = exports['rsg-core']:GetCoreObject()

local function handleAddMoney(src, moneytype, amount) 
    local player = RSGCore.Functions.GetPlayer(src)
    if not player or not Config.Items[moneytype] then return end

    local dollars = math.floor(amount)
    local cents = math.floor((amount - dollars) * 100)

    if dollars > 0 then player.Functions.AddItem(Config.Items[moneytype].dollar, dollars) end
    if cents > 0 then player.Functions.AddItem(Config.Items[moneytype].cent, cents) end
    
    if Player(src).state.inv_busy then 
        TriggerClientEvent('rsg-inventory:client:updateInventory', src) 
    end
end

local function handleRemoveMoney(src, moneytype, amount) 
    local player = RSGCore.Functions.GetPlayer(src)
    if not player or not Config.Items[moneytype] then return end

    local centsToSpend = math.floor(amount * 100)
    local centName = Config.Items[moneytype].cent
    local dollarName = Config.Items[moneytype].dollar

    local function removeItems(itemName, amountToRemove)
        for _, item in ipairs(player.Functions.GetItemsByName(itemName) or {}) do
            if amountToRemove <= 0 then break end
            local removeAmount = math.min(item.amount, amountToRemove)
            player.Functions.RemoveItem(item.name, removeAmount, item.slot)
            amountToRemove = amountToRemove - removeAmount
        end
        return amountToRemove
    end

    centsToSpend = removeItems(centName, centsToSpend)

    if centsToSpend > 0 then
        local dollarsToSpend = math.floor(centsToSpend / 100)
        local remainingCents = centsToSpend % 100

        centsToSpend = removeItems(dollarName, dollarsToSpend) * 100 + remainingCents

        if centsToSpend > 0 then
            local dollarsNeeded = math.ceil(centsToSpend / 100)
            local remainingCentsAfterConversion = 100 - (centsToSpend % 100)

            if removeItems(dollarName, dollarsNeeded) == 0 then
                player.Functions.AddItem(centName, remainingCentsAfterConversion)
            end
        end
    end

    if Player(src).state.inv_busy then 
        TriggerClientEvent('rsg-inventory:client:updateInventory', src)
    end
end

local function handleSetMoney(src, moneytype, amount) 
    local player = RSGCore.Functions.GetPlayer(src)
    if not player or not Config.Items[moneytype] then return end

    local function removeAllItems(itemName)
        for _, item in ipairs(player.Functions.GetItemsByName(itemName) or {}) do
            player.Functions.RemoveItem(item.name, item.amount, item.slot)
        end
    end

    removeAllItems(Config.Items[moneytype].cent)
    removeAllItems(Config.Items[moneytype].dollar)

    local dollars, cents = math.modf(amount)
    cents = math.floor(cents * 100)

    if dollars > 0 then player.Functions.AddItem(Config.Items[moneytype].dollar, dollars) end
    if cents > 0 then player.Functions.AddItem(Config.Items[moneytype].cent, cents) end

    if Player(src).state.inv_busy then 
        TriggerClientEvent('rsg-inventory:client:updateInventory', src) 
    end
end

local moneyHandlers = {
    add = handleAddMoney,
    remove = handleRemoveMoney,
    set = handleSetMoney,
}

AddEventHandler('RSGCore:Server:OnMoneyChange', function(src, moneytype, amount, operation, reason)
    local handler = moneyHandlers[operation]
    if handler then 
        handler(src, moneytype, amount) 
        TriggerClientEvent('hud:client:OnMoneyChange', src, moneytype, amount, false)
    end
end)

local function SynchronizeMoney(playerData) 
    local money = {d = 0, c = 0, bd = 0, bc = 0}

    for _, item in pairs(playerData.items) do
        if item then
            if item.name == 'dollar' then
                money.d = money.d + item.amount
            elseif item.name == 'cent' then
                money.c = money.c + item.amount
            elseif item.name == 'blood_dollar' then
                money.bd = money.bd + item.amount
            elseif item.name == 'blood_cent' then
                money.bc = money.bc + item.amount
            end
        end
    end

    local dollars = 0
    local cents = 0
    dollars = money.d + math.floor(money.c / 100)
    cents = money.c % 100
    playerData.money.cash = tonumber(string.format("%.2f", dollars + (cents / 100)))

    local blood_dollars = 0
    local blood_cents = 0
    blood_dollars = money.bd + math.floor(money.bc / 100)
    blood_cents = money.bc % 100
    playerData.money.bloodmoney = tonumber(string.format("%.2f", blood_dollars + (blood_cents / 100)))

    return playerData
end
exports('SynchronizeMoney', SynchronizeMoney)