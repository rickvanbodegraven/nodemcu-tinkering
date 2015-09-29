function toBits(num)
    local result = {};
    local count = 8;

    for i = count, 1, -1 do
        result[i] = num % 2;
        num = (num - result[i]) / 2;
    end
    
    return result
end   

function toDecimal(bitTable)
    local bits = bitTable;
    local result = 0;
    local powers = { 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 };

    for key,bitValue in pairs(bitTable) do
        result = result + (powers[key] * bitValue);
    end

    return result
end        

function dump(object)
   if type(object) == 'table' then
     local s = '{ ';
      
     for k,v in pairs(object) do
       if type(k) ~= 'number' then 
	     k = '"' .. k .. '"' 
	   end
         
	   s = s .. '[' .. k .. '] = ' .. dump(v) .. ',';
     end
      
     return s .. '} ';
   else
     return tostring(object);
   end
end

function getRawTemperature()
    gpio.write(csPin, gpio.HIGH);
    tmr.delay(300000); -- wait 0.3 sec (300 ms) to convert
    
    gpio.write(csPin, gpio.LOW);
    tmr.delay(2000); -- wait 0.02 sec (2ms) to retrieve
    
    -- read 2 bytes, which is 16 bits, which is what it should be putting out
    local temp = spi.recv(1, 2);
    
    local firstString  = string.byte(temp, 1);
    local secondString = string.byte(temp, 2);
    
    local firstBits  = toBits(firstString);
    local secondBits = toBits(secondString); 
    
    local tempBits = { firstBits[2], firstBits[3], firstBits[4], firstBits[5], firstBits[6], firstBits[7], firstBits[8], 
                       secondBits[1], secondBits[2], secondBits[3], secondBits[4], secondBits[5] };

    return toDecimal(tempBits);
end

function getCalibratedCelsius()
    local raw = getRawTemperature();

    -- calibration seems to indicate a temp of 56 while room is 22 degrees
    return (raw / 4) * 0.53; -- calibration factor since boiling water was 100 degrees?
end

print("Setting up SPI");

-- pin 8 = CS, force CS to LOW to get the first bit of data
csPin = 8;

-- TODO: move this to its own function

spi.setup(1, spi.MASTER, spi.CPOL_HIGH, spi.CPHA_HIGH, spi.DATABITS_8, 0);
gpio.mode(csPin, gpio.OUTPUT);

print(getCalibratedCelsius());

-- TODO: write some test code for my functions

-- TODO: write code to probe the temp and dump it to the server every x seconds or so

-- perform a temperature reading every 2.5 seconds
--tmr.alarm(0, 2500, 1, function() 
--  print(getCalibratedCelsius());
  -- json encode stuff ?
  -- send temp to back-end
--end);
