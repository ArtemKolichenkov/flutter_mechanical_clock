## Mechanical clocks in Flutter (beta)

This is my attempt to build mechanical clock mechanism in Flutter using CustomPainter and some math. Done for Flutter Clock challenge.

Unfortunately it took much more time than I anticipated so a lot of things are not fully finished. The Gear Generator is a big part of this project and it took more time than assembling the actual clock. Still its way faster development time compared to any other framework. 

Nevertheless I submit it just for fun, it was great experience . :) 

I will refine code later and publish it here.
I will also release the Gear Generator as a separate dart package (will mention it in this README later). 

### To Do:

- Now the clock hands rotate via AnimationController - this might be problematic since I'm not sure if time will not drift away. Haven't tested how reliable animation timer is, but I guess I'd need to come up with some hybrid solution of Animation + Timer ticks.
- Gears are not really precise.
  - They are mostly for show now, although it is possible to configure them to become precise, but I need more time for it.
  - The rotation animation does not match the gear grinding really. You can see teeth going through each other and stuff. More time and math needed to combat this :)
  - I still haven't found the way to fill the path with paint. Usual fill doesn't really work since gear path is quite complex. I have idea to split gear into multiple `canvas.drawPath` calls that are easy to paint, but there are problems with that too. Not an easy task at the moment.
  - API is a bit clumsy now. There is a lot of room for optimization, I'd say I can easily cut 30-40 lines of code and make it more readable.