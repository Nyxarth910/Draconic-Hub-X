function CreateTracerESP(Name, Part, Color, Thickness)
  if not Part then return false end

  local Line = Drawing.new("Line")
  Line.Color = Color or Color3.fromRGB(255, 255, 255)
  Line.Transparency = 1
  Line.Visible = true
  Line.ZIndex = 2

  Line.ESPDATA = {
    Part = Part,
    Color = Color or Color3.fromRGB(255, 255, 255),
    Thickness = Thickness or 1,
  }

  return Line
end

function UpdateTracerESP(Line, Props)
  if not Line or not Line.ESPDATA or not Line.ESPDATA.Part or not Line.ESPDATA.Part.Parent then
    if Line then Line.Visible = false end
    return
  end

  local Camera = workspace.CurrentCamera
  local PartPos, OnScreen = Camera:WorldToViewportPoint(Line.ESPDATA.Part.Position)

  if Props.Color ~= nil then Line.ESPDATA.Color = Props.Color end
  if Props.Thickness ~= nil then Line.ESPDATA.Thickness = Props.Thickness end
end

function DestroyTracerESP(Line)
  if Line then
     Line.Visible = false
     Line:Remove()
  end
end
