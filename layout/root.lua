return function(looky)
  return {
    build = function(options)  
      local base = looky:makeBaseLayout(options)
      local baseOptions = {direction="h", width="fill", height="fill", background = options.background or {0,0,0,0}}
      local child = looky:build("linear", looky.mergeOptions(baseOptions, options))
      local root = {
        base = base,
        addChild = function(self, child, position)
          self.linear:addChild(child, position)
        end,
        setLinear = function(self,child)
          self.linear = child          
        end,
        addListener = function(self, listener, method)
          self.linear:addListener(listener, method)
        end,
        desiredWidth = function(self)
          return love.graphics.getWidth()
        end,
        desiredHeight = function(self)
          return love.graphics.getHeight()
        end,
        grantedWidth = function(self)
          return love.graphics.getWidth()
        end,
        grantedHeight = function(self)
          return love.graphics.getHeight()
        end,
        availableWidth = function(self)
          return love.graphics.getWidth() - self.padding.left - self.padding.right
        end,
        availableHeight = function(self)
          return love.graphics.getHeight() - self.padding.top - self.padding.bottom
        end,
        layoutingPass = function(self)
          self.linear:setDimensions( self:grantedWidth(), self:grantedHeight() )
          self.linear:layoutingPass()
        end,
        render = function(self)
          self.linear:render()
        end,
        update = function(self, dt)
          self.linear:update(dt)
        end,
        getChild = function(self, number)
          return self.linear:getChild(number)
        end,
        getChildren = function(self)
          return self.linear:getChildren()
        end,
        removeChild = function(self,target)
          self.linear:removeChild(target)
        end,
        removeAllchildren = function(self)
          self.linear:removeAllchildren()
        end,
        receiveOutsideSignal = function(self, signal, payload, coords)
          self.linear:receiveOutsideSignal(signal, payload, coords)
        end,
        receiveChildSignal = function(self, signal, payload, coords)
          self.linear:receiveChildSignal(signal, payload, coords)
        end,
      }
      root:setLinear(child)
      return root
    end,
    schema = looky:extendSchema("base", {width = false, height = false, direction = { required = false, schemaType="fromList", list = { "h", "v" }}})
  }
end