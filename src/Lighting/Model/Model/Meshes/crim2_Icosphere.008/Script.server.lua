sphere = script.Parent --This means that you have to have the script in the sphere part
a = 0
 repeat
  sphere.Rotation = Vector3.new( 0, a, 0) --The second value of vector3 is a,
  wait(.01) -- we wait .01 seconds,
  a = a+3 --a's value increases
 until pigs == 1 --Just make sure you never have pigs' value to 1, and it'll spin forever
