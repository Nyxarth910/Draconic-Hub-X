
function CreateBoxESP(Name, Part, Color, Size)
    if not Part or Part:FindFirstChild(Name) then return end

    local BoxGui = Instance.new("BillboardGui")
    BoxGui.Name = Name
    BoxGui.Adornee = Part
    BoxGui.AlwaysOnTop = true
    BoxGui.Size = UDim2.new(Size or 4, 0, Size or 6, 0)
    BoxGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BoxGui.Parent = Part

    local color = Color or Color3.fromRGB(255, 255, 255)
  
    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.Size = UDim2.new(1, 0, 0, 2)
    Top.BackgroundColor3 = color
    Top.BorderSizePixel = 0
    Top.Position = UDim2.new(0, 0, 0, 0)
    Top.Parent = BoxGui

    local Bottom = Instance.new("Frame")
    Bottom.Name = "Bottom"
    Bottom.Size = UDim2.new(1, 0, 0, 2)
    Bottom.BackgroundColor3 = color
    Bottom.BorderSizePixel = 0
    Bottom.Position = UDim2.new(0, 0, 1, -2)
    Bottom.Parent = BoxGui
  
    local Left = Instance.new("Frame")
    Left.Name = "Left"
    Left.Size = UDim2.new(0, 2, 1, 0)
    Left.BackgroundColor3 = color
    Left.BorderSizePixel = 0
    Left.Position = UDim2.new(0, 0, 0, 0)
    Left.Parent = BoxGui
  
    local Right = Instance.new("Frame")
    Right.Name = "Right"
    Right.Size = UDim2.new(0, 2, 1, 0)
    Right.BackgroundColor3 = color
    Right.BorderSizePixel = 0
    Right.Position = UDim2.new(1, -2, 0, 0)
    Right.Parent = BoxGui

    return BoxGui
end

function UpdateBoxESP(Name, Part, Color, BaseSize, ViewPos)
    if not Part then return false end
    
    local BoxGui = Part:FindFirstChild(Name)
    if not BoxGui then return false end

    if Color then
        for _, frame in ipairs(BoxGui:GetChildren()) do
            if frame:IsA("Frame") then
                frame.BackgroundColor3 = Color
            end
        end
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
            BoxGui.Size = UDim2.new((BaseSize or 4) * scale, 0, (BaseSize or 6) * scale, 0)
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
