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

    --print("Converting the following 12-bit number: " .. dump(bits))
    
    for key,bitValue in pairs(bitTable) do
        --print(result .. ' ' .. powers[key] .. ' ' .. bitValue)
        result = result + (powers[key] * bitValue);
        print(result)
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
    -- force a conversion process to start on thermocoupler
    --gpio.write(csPin, gpio.LOW);
    --tmr.delay(1000);
    
    gpio.write(csPin, gpio.HIGH);
    tmr.delay(250000); -- 0.25 sec
    
    gpio.write(csPin, gpio.LOW);
    tmr.delay(500000); -- 0.5 sec
    
    -- read 2 bytes, which is 16 bits, which is what it should be putting out
    local temp = spi.recv(1, 2);
    
    local firstString  = string.byte(temp, 1);
    local secondString = string.byte(temp, 2);
    
    --print('Received: ' .. firstString .. ' ' .. secondString);
    
    local firstBits  = toBits(firstString);
    local secondBits = toBits(secondString); 
    
    local tempBits = { firstBits[2], firstBits[3], firstBits[4], firstBits[5], firstBits[6], firstBits[7], firstBits[8], 
                       secondBits[1], secondBits[2], secondBits[3], secondBits[4], secondBits[5] };

    return toDecimal(tempBits);
end

print("Setting up SPI");

-- pin 8 = CS, force CS to LOW to get the first bit of data
csPin = 8;

-- TODO: move this to its own function

spi.setup(1, spi.MASTER, spi.CPOL_HIGH, spi.CPHA_HIGH, spi.DATABITS_8, 0);
gpio.mode(csPin, gpio.OUTPUT);

print(getRawTemperature());

--


-- TODO: write some test code for my functions

print('test of toDecimal, should return 4095: ');
print(toDecimal({1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}));


--


print('test of toDecimal, should return 512: ');
print(toDecimal({0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0}));


--


print('test of toDecimal, should return 1025: ');
print(toDecimal({0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}));


--[[

-- TODO: write code to probe the temp and dump it to the server every x seconds or so

-- perform a temperature reading every 30 seconds
tmr.alarm(0, 30000, 1, function() 
  -- get temp
  -- json encode stuff ?
  -- send temp to back-end
end );

]]

