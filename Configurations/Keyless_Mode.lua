local KeylessMode = true

if os.date("*t").wday == 7 or os.date("*t").wday == 1 or os.date("*t").wday == 2 then
    KeylessMode = true
end

return KeylessMode
