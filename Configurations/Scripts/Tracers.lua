local Tracers = {} -- fix

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

  Tracers[ID] = Line
  return Line
end

function UpdateTracerESP(Line, Props)
  local Line = Tracers[ID]
  if not Line or not Props then return end
  if Props.Color ~= nil then Line.ESPDATA.Color = Props.Color end
  if Props.Thickness ~= nil then Line.ESPDATA.Thickness = Props.Thickness end

  local Camera = workspace.CurrentCamera

  if Line.ESPDATA.Part and Line.ESPDATA.Part.Parent then
    local PartPos, OnScreen = Camera:WorldToViewportPoint(Line.ESPDATA.Part.Position)

    if OnScreen then
      Line.Color = Line.ESPDATA.Color
      Line.Thickness = Line.ESPDATA.Thickness

      local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
      Line.From = ScreenCenter
      Line.To = Vector2.new(PartPos.X, PartPos.Y)
      Line.Visible = true
    else
      Line.Visible = false
    end
  else
    Line.Visible = false
  end
end

function DestroyTracerESP(Line)
  if Line then
     Line.Visible = false
     Line:Remove()
  end
end
