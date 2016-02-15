return function (base, options)
  local container = lc:build("linear", {direction = "v", width = options.width, height = options.height, backgroundColor = {0,0,255,255}})  
  container:addChild( lc:build( "image", {file = options.file, width="wrap", height="wrap", layoutGravity = "center" } ))
  container:addChild( lc:build( "text", {text = options.text, width="wrap", height="wrap", backgroundColor = {255,0,0,255}, textColor={0,255,0,255}, paddingLeft = 5, paddingRight = 5, paddingTop = 5, paddingBottom = 5}) )
  return container
end