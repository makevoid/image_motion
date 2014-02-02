class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.makeKeyAndVisible
    
    images_ctrl = ImagesController.alloc.initWithImagesDir "issue"
    
    @window.rootViewController = images_ctrl
    #@window.rootViewController.wantsFullScreenLayout = true

    true
  end
end