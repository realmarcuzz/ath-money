# ath-money

#### Redm resource enabling money types to have its item representation (default `cash` and `bloodmoney`)

## WARNING!!! this will make money item authoritative to player data money amount, therefore reseting cash and bloodmoney for players
##### you can get current cash and bloodmoney values by running following query. Save the output if you want to re-add money to players

```sql
SELECT 
    citizenid,
    name,
    CONCAT(
        JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ',
        JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname'))
    ) AS character_name,
    JSON_UNQUOTE(JSON_EXTRACT(money, '$.cash')) AS cash,
    JSON_UNQUOTE(JSON_EXTRACT(money, '$.bloodmoney')) AS bloodmoney 
FROM players
```

### Installation

##### 1) ensure ath-money in server.cfg

```
ensure ath-money
```

##### 2) add currency items to `[framework]\rsg-core\shared\items.lua`

```lua
    --currency
    dollar = {name = 'dollar', label = 'Dollars', weight = 0, type = 'item', image = 'dollar.png', unique = false, useable = false, description = 'Money'},
    cent = {name = 'cent', label = 'Cents', weight = 0, type = 'item', image = 'cent.png', unique = false, useable = false, description = 'Money'},
  
    blood_dollar = {name = 'blood_dollar', label = 'Blood Dollars', weight = 0, type = 'item', image = 'blood_dollar.png', unique = false, useable = false, description = 'Blood money'},
    blood_cent = {name = 'blood_cent', label = 'Blood Cents', weight = 0, type = 'item', image = 'blood_cent.png', unique = false, useable = false, description = 'Blood money'},
```

##### 3) verify money configuration matches ath-money configuration
- rsg-core config

```lua
RSGConfig.Money = {}
RSGConfig.Money.MoneyTypes = { cash = 0, bank = 0, bloodmoney = 0 }
```
- ath-money config

```lua
Config = {
    Items = {
        cash = {
            dollar = 'dollar',
            cent = 'cent',
        },
        bloodmoney = {
            dollar = 'blood_dollar',
            cent = 'blood_cent',
        },
    }
}
```

#### 4) add synchronization export to rsg-core
- in `[framework]\rsg-core\server\player.lua` change `self.Functions.UpdatePlayerData()`

```lua
    function self.Functions.UpdatePlayerData()
        if self.Offline then return end
        self.PlayerData = exports['ath-money']:SynchronizeMoney(self.PlayerData) --add this line
        TriggerEvent('RSGCore:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('RSGCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end
```

#### 5) [OPTIONAL] change event in rsg-inventory shopping logic for correct inventory updating while shopping
- in `[framework]\rsg-inventory\server\main.lua` change event on line `352` in `rsg-inventory:server:attemptPurchase` callback

```lua
TriggerEvent('rsg-shops:server:UpdateShopItems', shop, itemInfo, amount) --remove this line
TriggerClientEvent('rsg-inventory:client:updateInventory', source) --replace with this line
```






