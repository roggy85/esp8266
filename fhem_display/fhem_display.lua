-- get infos from fhem

--fhem_server = "http://192.168.100.5:8083"

-- Connections:
--   ESP  --  OLED
--   3v3  --  VCC
--   GND  --  GND
--   D3   --  SDA
--   D4   --  SCL

sda = 3   -- OLED SDA -> ESP D3
sdl = 4   -- OLED SDL -> ESP D4

function init_OLED(sda,scl) --Set up the u8glib lib
   sla = 0x3C
   i2c.setup(0, sda, scl, i2c.SLOW)
   disp = u8g.ssd1306_128x64_i2c(sla)
   disp:setFont(u8g.font_6x10)

   disp:setFontRefHeightExtendedText()
   disp:setDefaultForegroundColor()
   disp:setFontPosTop()
   --disp:setRot180()           -- Rotate Display if needed
end

function print_OLED()
 disp:firstPage()
 repeat
   disp:drawFrame(2,2,126,62)
--   disp:setScale2x2()
--   disp:setFont(u8g.font_10x20)
   disp:drawStr(15, 15, room)
   disp:undoScale()
--   disp:setFont(u8g.font_6x10)
   disp:drawStr(10, 30, "Temp: "..temperature.."°C")
   disp:drawStr(10, 40, "LF  : "..humidity.."%")
   disp:drawStr(10, 50, "TPkt: "..dewpoint.."°C")
   --disp:drawCircle(18, 47, 14)
 until disp:nextPage() == false
end

function print_OLED_init()
 disp:firstPage()
 repeat
   disp:drawFrame(2,2,126,62)
   disp:drawStr(10, 10, "Initialisiere....")
 until disp:nextPage() == false
end

init_OLED(sda,sdl)

print_OLED_init()

function get_values_from_fhem()
  http.get("http://192.168.100.5:8083/fhem?cmd=jsonlist2%20TYPE=LaCrosse%20alias%20temperature%20humidity%20dewpoint&XHR=1", nil, function(code, data)
    print ("Getting new Values from FHEM.......")
    t = cjson.decode(data)
    return_values = t.totalResultsReturned      
  end)
end

return_values = nil
counter = 0


get_values_from_fhem()

tmr.create():alarm(3000, tmr.ALARM_AUTO, function(cb_timer)
    if return_values == nil then
        print("Waiting for values...")
    else
        cb_timer:unregister()
        
        tmr.create():alarm(5000, tmr.ALARM_AUTO, function(ticker)
          counter = counter + 1
          room = t.Results[counter].Attributes.alias
          temperature = t.Results[counter].Readings.temperature.Value
          humidity = t.Results[counter].Readings.humidity.Value
          dewpoint = t.Results[counter].Readings.dewpoint.Value
          print (room..":")
          print ("Temperatur      : "..temperature.."°C")
          print ("Luftfeuchtigkeit: "..humidity.."%")
          print ("Taupunkt: "..dewpoint.."°C")
          print_OLED(room,temperature,humidity,dewpoint)
          if counter == return_values then
            counter = 0
            get_values_from_fhem()
          end
        end)
     end
end)

