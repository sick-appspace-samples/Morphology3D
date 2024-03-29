
--Start of Global Scope---------------------------------------------------------

Script.serveEvent('Morphology3D.OnMessage1', 'OnMessage1', 'string')
Script.serveEvent('Morphology3D.OnMessage2', 'OnMessage2', 'string')

-- Create viewer for original and filtered 3D image

local viewer1 = View.create('viewer3D1') -- Will show in 3D viewer
local viewer2 = View.create('viewer3D2') -- Will show in 3D viewer

local DELAY = 2000

--End of Global Scope-----------------------------------------------------------

-- Start of Function and Event Scope--------------------------------------------

--@filteringImage(heightMap:Image, intensityMap:Image)
local function filteringImage(heightMap, intensityMap)
  -- MORPHOLOGY: A morphological transformation applied to grayscale images.
  -- The possible transformation types are: ERODE, DILATE, OPEN, CLOSE,
  -- GRADIENT, TOPHAT and BLACKHAT

  local hmDeco = View.ImageDecoration.create()
  local minR, maxR = Image.getMinMax(heightMap)
  hmDeco:setRange(minR, maxR)

  -- Visualize the input (original image)
  viewer1:clear()
  viewer1:addHeightmap({heightMap, intensityMap}, {hmDeco}, {'Reflectance'})
  viewer1:present()

  Script.notifyEvent('OnMessage1', 'Original image')

  -- Filter on heightMap
  -- The diameter of the circular structuring element/kernel in pixels. The value must be odd and between 3 and 51
  local diameterPix = 9
  local TRANSFORMATION = 'ERODE' -- ERODE, DILATE, OPEN, CLOSE, GRADIENT, TOPHAT, BLACKHAT
  heightMap:setMissingDataFlag(0)
  local erodeImage = heightMap:morphology(diameterPix, TRANSFORMATION) -- Morphology filtering
  local erodeIntensityMap = intensityMap:morphology(diameterPix, TRANSFORMATION)
  -- Visualize the output (median image)
  viewer2:clear()
  viewer2:addHeightmap({erodeImage, erodeIntensityMap}, {hmDeco}, {'Reflectance'})
  viewer2:present()

  Script.notifyEvent('OnMessage2', 'Morphology filter, diameter pixel: ' .. diameterPix .. ', transformation: ' .. TRANSFORMATION)
end

local function main()
  for i = 1, 1 do
    -- Load a json-image
    local data = Object.load('resources/image_' .. i .. '.json')

    -- Extract heightmap, intensity map and sensor data
    local heightMap = data[1]
    local intensityMap = data[2]
    local sensorData = data[3] --luacheck: ignore

    -- Filter image
    filteringImage(heightMap, intensityMap)

    Script.sleep(DELAY)
  end

  print('App finished')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
