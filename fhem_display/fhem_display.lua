-- get infos from fhem

fhem_server = "server.home"

-- http.get("http://172.20.10.4:8083/fhem", nil, function(code, data)
--    if (code < 0) then
--      print("HTTP request failed")
--    else
--      print(code, data)
--    end
--  end)

data = [[
{
  "Arg":"az.TF temperature humidity dewpoint",
  "Results": [
  {
    "Name":"az.TF",
    "Internals": { },
    "Readings": {
      "dewpoint": { "Value":"10.8", "Time":"2017-02-24 14:52:24" },
      "humidity": { "Value":"52", "Time":"2017-02-24 14:53:21" },
      "temperature": { "Value":"21.3", "Time":"2017-02-24 14:53:21" }
    },
    "Attributes": { }
  }  ],
  "totalResultsReturned":1
}
]]


t = cjson.decode(data)

print (t.Results[1].Readings.temperature.Value)
print (t.Results[1].Readings.humidity.Value)
print (t.Results[1].Readings.dewpoint.Value)
