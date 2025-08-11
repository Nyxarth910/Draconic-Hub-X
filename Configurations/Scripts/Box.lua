function CreateBoxESP(Name, Part, Color, Size)
  if not Part or Part:FindFirstChild(Name) then return end

  local BoxGui = Instance.new("BillboardGui")
  BoxGui.Name = Name
  BoxGui.Adornee = Part
  BoxGui.Size = UDim2.new(Size or 4, 0, Size or 5, 0)
  BoxGui.AlwaysOnTop = true
  BoxGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  BoxGui.Parent = Part

  local Frame = Instance.new("Frame")
  Frame.Size = UDim2.new(1, 0, 1, 0)
  Frame.BackgroundTransparency = 1
  Frame.BorderSizePixel = 2
  Frame.BorderColor3 = Color or Color3.fromRGB(255, 255, 255)
  Frame.Parent = BoxGui

  return BoxGui
end

function UpdateBoxESP(Name, Part, Color, BaseSize, ViewPos)
  if not Part then return false end
  
  local BoxGui = Part:FindFirstChild(Name)
  if not BoxGui then return false end

  local Frame = BoxGui:FindFirstChildOfClass("Frame")
  if Frame and Color then
    frame.BorderColor3 = Color
  end

  if ViewPos then
    local pos
    if typeof(ViewPos) == "Instance" and ViewPos:IsA("BasePart") then
      pos = ViewPos.Position
    elseif typeof(ViewPos) == "Vector3" then
      pos = ViewPos
    end

    if pos then
      local distance = (pos - Part.Position).Magnitude
      local scale = math.clamp(distance / 25, 1, 10)

      BoxGui.Size = UDim2.new((BaseSize or 4) * scale, 0, (BaseSize or 5) * scale, 0)
    end
  end

  return true
end

function DestroyBoxESP(Name, Part)
  if not Part then return false end

  local BoxGui = Part:FindFirstChild(Name)
  if BoxGui then
    BoxGui:Destroy()
    return true
  end
  return false
end
