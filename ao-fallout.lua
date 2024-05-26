Players = Players or {}

local fruits = {"apple", "banana", "cherry"}

local function gridToString(grid)
    local str = ""
    for i = 1, #grid do
        for j = 1, #grid[i] do
            str = str .. grid[i][j] .. " "
        end
        str = str .. "\n"
    end
    return str
end

local function generateFruitGrid(size, fruitCount)
    local grid = {}
    for i = 1, size do
        grid[i] = {}
        for j = 1, size do
            grid[i][j] = fruits[math.random(fruitCount)]
        end
    end
    return grid
end

local function initPlayer(playerId)
    local size = 3
    local fruitCount = 2
    local grid = generateFruitGrid(size, fruitCount)
    local target = {x = math.random(size), y = math.random(size)}
    Players[playerId] = {
        level = 1,
        grid = grid,
        target = target
    }
    return grid, target
end

local function getPlayerInfo(playerId)
    return Players[playerId]
end

local function handleGuess(playerId, guessFruit)
    local playerInfo = getPlayerInfo(playerId)
    local target = playerInfo.target
    local grid = playerInfo.grid

    if grid[target.x][target.y] == guessFruit then
        playerInfo.level = playerInfo.level + 1
        local newSize = 3 + playerInfo.level - 1
        local newFruitCount = math.min(#fruits, 2 + playerInfo.level - 1)
        playerInfo.grid = generateFruitGrid(newSize, newFruitCount)
        playerInfo.target = {x = math.random(newSize), y = math.random(newSize)}
        return true, "Correct! You've advanced to level " .. playerInfo.level
    else
        return false, "Incorrect! Try again."
    end
end

Handlers.add(
    "Join",
    Handlers.utils.hasMatchingTag("Action", "Join"),
    function(msg)
        local playerId = msg.From
        print("Player " .. playerId .. " joined the game.")

        local grid, target
        if not Players[playerId] then
            grid, target = initPlayer(playerId)
        else
            local playerInfo = getPlayerInfo(playerId)
            grid = playerInfo.grid
            target = playerInfo.target
        end

        local gridString = gridToString(grid)
        ao.send({Target = playerId, Data = "Game started. Here is the grid:\n" .. gridString .. "\nYou will be asked to guess the fruit at a specific coordinate in 5 seconds."})

    end
)

Handlers.add(
        "Start",
        Handlers.utils.hasMatchingTag("Action", "Start"),
        function(msg)
            local playerId = msg.From
            print("Player " .. playerId .. " started the game.")

            local grid, target
            if not Players[playerId] then
                grid, target = initPlayer(playerId)
            else
                local playerInfo = getPlayerInfo(playerId)
                grid = playerInfo.grid
                target = playerInfo.target
            end

            ao.send({Target = playerId, Data = "Game started. Here is the grid:\n" .. 22 .. "\nYou will be asked to guess the fruit at a specific coordinate in 5 seconds."})
        end
)

Handlers.add(
    "Guess",
    Handlers.utils.hasMatchingTag("Action", "Guess"),
    function(msg)
        local playerId = msg.From
        local guessFruit = msg.Data

        local correct, response = handleGuess(playerId, guessFruit)
        ao.send({Target = playerId, Data = response})

        if correct then
            local playerInfo = getPlayerInfo(playerId)
            ao.send({Target = playerId, Data = "New level: " .. playerInfo.level .. ". Guess the fruit at coordinate (" .. playerInfo.target.x .. ", " .. playerInfo.target.y .. ")."})
        end
    end
)

Handlers.add(
    "Reset",
    Handlers.utils.hasMatchingTag("Action", "Reset"),
    function(msg)
        local playerId = msg.From
        local grid, target = initPlayer(playerId)
        ao.send({Target = playerId, Data = "Your game has been reset. Guess the fruit at coordinate (" .. target.x .. ", " .. target.y .. ")."})
    end
)
