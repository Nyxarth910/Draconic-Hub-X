function CreateBillboardESP(Name, Part, Color, TextSize)
  if not Part or Part:FindFirstChild(Name) then return nil end

  local BillboardGui = Instance.new("BillboardGui")
  local TextLabel = Instance.new("TextLabel")
  local TextStroke = Instance.new("UIStroke")

  BillboardGui.Parent = Part
  BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  BillboardGui.Name = Name
  BillboardGui.AlwaysOnTop = true
  BillboardGui.LightInfluence = 1
  BillboardGui.Size = UDim2.new(0, 200, 0, 50)
  BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
  BillboardGui.MaxDistance = 1000

  TextLabel.Parent = BillboardGui
  TextLabel.BackgroundTransparency = 1
  TextLabel.Size = UDim2.new(1, 0, 1, 0)
  TextLabel.TextScaled = false
  TextLabel.Font = Enum.Font.SourceSans
  TextLabel.TextSize = TextSize or 14
  TextLabel.TextColor3 = Color or Color3.fromRGB(255, 255, 255)

  TextStroke.Parent = TextLabel
  TextStroke.Thickness = 1
  TextStroke.Color = Color3.new(0, 0, 0)

  return BillboardGui
end

function UpdateBillboardESP(Name, Part, NameText, Color, TextSize, PartPosition)
  if not Part then return false end

  local esp = Part:FindFirstChild(Name)
  if esp and esp:FindFirstChildOfClass("TextLabel") then
    local label = esp:FindFirstChildOfClass("TextLabel")
    
    if Color then
      label.TextColor3 = Color
    end
    
    if TextSize then
      label.TextSize = TextSize
    end
    
    if PartPosition then
      local Pos 
      if typeof(PartPosition) == "Instance" and PartPosition:IsA("BasePart") then
        Pos = PartPosition.Position
      elseif typeof(PartPosition) == "Vector3" then
        Pos = PartPosition
      end

      if Pos then
        local distance = math.floor((Pos - Part.Position).Magnitude)
        local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
        label.Text = string.format("%s - [ %d M ]", name, distance)
      end
    else
      local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
      label.Text = name
    end    
    return true
  end
  return false
end

function DestroyBillboardESP(Name, Part)
  if not Part then return false end
  
  local esp = Part:FindFirstChild(Name)
  if esp then
    esp:Destroy()
    return true
  end
  
  return false
end
