function toBits(num)
    local result = {};
    local count = 8;

    for i = count, 1, -1 do
        result[i] = num % 2;
        num = (num - result[i]) / 2;
    end
    
    return result
end   

function toDecimal (bitTable)
    local bits = bitTable;
    local result = 0;
    local powers = { 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 };

    --print("Converting the following 12-bit number: " .. dump(bits))
    
    for j in pairs(bitTable) do
        print(result .. ' ' .. powers[j] .. ' ' .. bits[j])
        result = result + (powers[j] * bits[j]);
        print(result)
    end

    return result
end        

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function getCelsius()
    -- force a conversion process to start on thermocoupler
    gpio.write(csPin, gpio.LOW);
    tmr.delay(1000);
    
    gpio.write(csPin, gpio.HIGH);
    tmr.delay(1000);
    
    gpio.write(csPin, gpio.LOW);
    tmr.delay(50000);
    
    -- read 2 bytes, which is 16 bits, which is what it should be putting out
    local temp = spi.recv(1, 2);
    
    local firstString  = string.byte(temp, 1);
    local secondString = string.byte(temp, 2);
    
    --print('Received: ' .. firstString .. ' ' .. secondString);
    
    local firstBits  = toBits(firstString);
    local secondBits = toBits(secondString); 
    
    local tempBits = { firstBits[2], firstBits[3], firstBits[4], firstBits[5], firstBits[6], firstBits[7], firstBits[8], secondBits[1], secondBits[2], secondBits[3], secondBits[4], secondBits[5] };

    return toDecimal(tempBits) / 4;
end

print("Setting up SPI");

-- pin 8 = CS force CS to LOW to get the first bit of data
csPin = 8;
spi.setup(1, spi.MASTER, spi.CPOL_HIGH, spi.CPHA_HIGH, spi.DATABITS_8, 0);
gpio.mode(csPin, gpio.OUTPUT);

print(getCelsius());