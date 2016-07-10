local renderChildren = function(self) 
  self:renderBackground()

  local offset = 0
  
  for k, v in ipairs(self.children) do
    love.graphics.push()    
    love.graphics.translate(self.scaffold[v][1], self.scaffold[v][2])
    
    v:render()
    if debug then
      love.graphics.setColor(255,255,255,255)
      love.graphics.rectangle("line",0,0,v:availableWidth(),v:availableHeight())
    end
    
    love.graphics.pop()
  end
end

local horizontalLayout = function(parent, children)  
  local availableSize = parent:availableWidth()
  local fills = {}
  for k, v in ipairs(children) do
    if v:desiredWidth() == "fill" then
      table.insert(fills, v)
    else
      local height = v:desiredHeight()
      if height == "fill" then
        height = parent:availableHeight()
      end
      if v:desiredWidth() < availableSize then
        availableSize = availableSize - v:desiredWidth()            
        v:setDimensions(v:desiredWidth(), height)
      else
        v:setDimensions(availableSize, height)
        availableSize = 0
      end
    end
  end
  if availableSize > 0 then
    local sumWeight = 0
    for k, v in ipairs(fills) do
      sumWeight = sumWeight + v.weight
    end    
    for k, v in ipairs(fills) do
      local height = v:desiredHeight()
      if height == "fill" then
        height = parent:grantedHeight()
      end
      v:setDimensions(availableSize / sumWeight * v.weight, height)
    end
  end
  
  for k, v in ipairs(children) do    
    v:layoutingPass()
  end
end

local verticalLayout = function(parent, children)  
  local availableSize = parent:availableHeight()
  local fills = {}
  for k, v in ipairs(children) do
    if v:desiredHeight() == "fill" then
      table.insert(fills, v)
    else
      local width = v:desiredWidth()
      if width == "fill" then
        width = parent:availableWidth()
      end
      if v:desiredHeight() < availableSize then
        availableSize = availableSize - v:desiredHeight()            
        v:setDimensions(width, v:desiredHeight())
      else
        v:setDimensions(width, availableSize)
        availableSize = 0
      end
    end
  end
  if availableSize > 0 then
    local sumWeight = 0
    for k, v in ipairs(fills) do
      sumWeight = sumWeight + v.weight    
    end
    for k, v in ipairs(fills) do
      local width = v:desiredWidth()
      if width == "fill" then
        width = parent:availableWidth()
      end
      v:setDimensions(width, availableSize / sumWeight * v.weight)
    end
  end
  
  for k, v in ipairs(children) do    
    v:layoutingPass()
  end
end

local function containerWidth(self)  
  local width = 0
  for k, v in ipairs(self.children) do
    if v:desiredWidth() == "fill" then
      return "fill"
    else
      if self.direction == "v" then
        if v:desiredWidth() > width then
          width = v:desiredWidth()
        end
      else
        width = width + v:desiredWidth()
      end
    end
  end
  return width
end

local function containerHeight(self)
  local height = 0
  for k, v in ipairs(self.children) do
    if v:desiredHeight() == "fill" then
      return "fill"
    else
      if self.direction == "v" then
        height = height + v:desiredHeight()
      else
        if v:desiredHeight() > height then
          height = v:desiredHeight()
        end
      end
    end
  end
  return height
end

local function scaffoldViews(self)
    
  local offset = 0
  local transX, transY = 0,0

  for k, v in ipairs(self:getChildren()) do
    
    if self.direction == "v" then 
      transY = transY + offset          
      offset = offset + v:grantedHeight()
      if v.layoutGravity == "start" then
        transX = transX + v.margin.left
        transY = transY + v.margin.top            
      elseif v.layoutGravity == "end" then
        transX = transX + self:availableWidth() - v:grantedWidth() - v.margin.right
        transY = transY + v.margin.top                        
      elseif v.layoutGravity == "center" then
        transX = transX + (self:availableWidth() - v:grantedWidth()) /2 - (v.margin.left - v.margin.right) / 2
        transY = transY + v.margin.top                        
      end
    else
      transX = transX + offset
      offset = offset + v:grantedWidth()
      if v.layoutGravity == "start" then
        transX = transX + v.margin.left
        transY = transY + v.margin.top                        
      elseif v.layoutGravity == "end" then
        transX = transX + v.margin.left
        transY = transY + self:availableHeight() - v:grantedHeight() - v.margin.bottom
      elseif v.layoutGravity == "center" then
        transX = transX + v.margin.left
        transY = transY + (self:availableHeight() - v:grantedHeight()) /2 - (v.margin.top - v.margin.bottom) / 2          
      end
    end
    
    self.scaffold[v] = {transX, transY}    
    transX = 0
    transY = 0
  end    

end


local function clickedViews(self,x,y)
  local clicked = {}
  if x > 0 and x < self:grantedWidth()
  and y > 0 and y < self:grantedHeight() then
  
    for k, v in ipairs(self.children) do

      for _, deeperClicked in ipairs( v:clickedViews(x - self.scaffold[v][1], y - self.scaffold[v][2]) ) do
        table.insert( clicked, deeperClicked )
      end
    end    
    
    table.insert(clicked, self)    
  end
  return clicked
end

return function(lc)
  return {
    build = function (base, options)
      base.renderCustom = renderChildren
      base.direction = options.direction or "v"
      if base.direction == "v" then
        base.layoutingPass = function(self)           
          verticalLayout(self, self.children) 
          self:scaffoldViews()
        end  
      else
        base.layoutingPass = function(self)           
          horizontalLayout(self, self.children) 
          self:scaffoldViews()
        end  
      end
      base.contentWidth = containerWidth
      base.contentHeight = containerHeight
      base.clickedViews = clickedViews
      base.scaffoldViews = scaffoldViews
      base.scaffold = {}
      base.update = function(self, dt)
        for k, v in ipairs(self.children) do
          v:update(dt)
        end
      end
      return base
    end,
    schema = lc:extendSchema("base", {direction = { required = false, schemaType = "fromList", list = { "v", "h" } },})
  }
end