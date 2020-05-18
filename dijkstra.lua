dofile "data"

-- prints the graph in a human-readable form
-- intend is optional, it is a number of spaces
function PrintGraph (graph, intend)
    intend = intend or 0
    for key, value in pairs(graph) do
        for i = 1, intend do
            io.write " "
        end
        if type(value) == "table" then
            print(key)
            PrintGraph(value,intend+2)
        else
            print(key,value)
        end
    end
end

-- returns a deep copy of passed value
-- does not copy the metatable
function DeepCopy (original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in next, original, nil do
            copy[key] = DeepCopy(value)
        end
    else
        copy = original
    end
    return copy
end

-- load the graph from file
-- the structure of the file is:
-- Nodes= { names separated with commas }
-- Connections = { {"city1", "city2", distance}, ... }
function LoadGraph (graph)
    for _, name in pairs(Nodes) do
        graph[name] = {}
    end
    for index, connection in pairs(Connections) do
        if not graph[connection[1]] or not graph[connection[2]] then
            print("Plik zdupcony", index)
        end
        table.insert(graph[connection[1]],connection)
        table.insert(graph[connection[2]],connection)
    end
end

-- extends the graph with fields needed for Dijkstra algorithm
-- adds distance field for every connection
-- and isChecked field for every city
-- sets all distances to infinity
-- unless the connection includes source city
-- marks source as checked
function InitDijkstraGraph (Graph, source)
    Graph[source].distance = 0
    for index, connection in ipairs(Connections) do
        local city1 = connection[1]
        local city2 = connection[2]
        local distance = connection[3]
        if city1 == source then
            Graph[city2].distance = distance
        elseif city2 == source then
            Graph[city1].distance = distance
        elseif not Graph[city1].distance then
            Graph[city1].distance = math.huge
        elseif not Graph[city2].distance then
            Graph[city2].distance = math.huge
        end
    end
    for city, data in pairs(Graph) do
        if city == source then
            data.isChecked = true
        else
            data.isChecked = false
        end
    end
end

-- returns the name of the city with the smallest distance to it
function FindNextCity(Graph)
    local min = math.huge
    local nextCity
    for city, data in pairs(Graph) do
        if not data.isChecked and data.distance < min then
            min = data.distance
            nextCity = city
        end
    end
    return nextCity
end

-- updates costs and make city checked
function UpdateDistances (currentCity, Graph)
    for index, connection in ipairs(Graph[currentCity]) do
        local targetCity
        if connection[1] == currentCity
        and not connection[2].isChecked then
            targetCity = connection[2]
        elseif connection[2] == currentCity
        and not connection[1].isChecked then
            targetCity = connection[1]
        end
        if targetCity then
            local newDistance = Graph[currentCity].distance + connection[3]
            local oldDistance = Graph[targetCity].distance
            if newDistance < oldDistance then
                Graph[targetCity].distance = newDistance
            end
        end
        Graph[currentCity].isChecked = true
    end
end

----------------------------------

Graph = {}
LoadGraph(Graph)
source = "Sibiu"
destination = "Bucharest"
InitDijkstraGraph(Graph, source)
repeat
    nextCity = FindNextCity(Graph)
    UpdateDistances(nextCity, Graph)
until nextCity == destination
PrintGraph(Graph)
print "done"
