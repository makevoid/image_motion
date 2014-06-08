# ImageMotion
### Image Album app (like Photos official app)

Double ScrollView (swiping, zooming) based RubyMotion app, loads local image files.


Rework of https://github.com/makevoid/up_gallery 
Unfortunately it's still early to create a gallery in a webview yet, but as devices will become more powerful I will switch back to good old HTML

### Implememtation notes

to try

extend UIView or use custom views

use this code to align UIViews 

    def bottom_right
      returnPoint    = self.frame.origin
      returnPoint.y += self.frame.size.height
      returnPoint.x += self.frame.size.width
      returnPoint
    end

    def set_bottom_right
      newRect = self.frame
      newRect.origin.x = bottomRight.x - self.frame.size.width
      newRect.origin.y = bottomRight.y - self.frame.size.height
      self.frame = newRect
    end

taken from https://github.com/valentinradu/UIViewEasyPositioning/blob/master/UIViewEasyPositioning/UIView%2BVRAlign.m


but also consider
https://github.com/clayallsopp/geomotion

---

### notes:

    rake device install_only=1