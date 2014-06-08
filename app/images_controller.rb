# it's all implemented in this class
#
# notes, warnings: - I'm delegating both scoll views to this class, this needs refactor

class UIView
  
end

class ImagesController< UIViewController
  
  attr_reader :dir
  
  def initWithImagesDir(dir)
    @dir = dir
    
    view = image_scroll_view
    
    self.view.addSubview view
    
    draw_status
    update_status
    
    init
  end
  
  def draw_status
    font_size = 13
    @status = UILabel.alloc.init
    # position it to the bottom_right
    width = 46
    y = UIScreen.mainScreen.bounds.size.width  - font_size - 30
    x = UIScreen.mainScreen.bounds.size.height - width     
    @status.frame = CGRectMake(x, y, width, font_size+10)
    # @status.bottomRight = self.view.bottomRight (todo: look at readme.md, implement the methods in UIView or in a subclass and remove the code above)
    @status.font = @status.font.fontWithSize font_size
    self.view.addSubview @status
  end
  
  def update_status
    @status.text = "#{@current_page} / #{images_count}"
  end
  
  def self.image_width
    1024
  end
  
  def images_count
    #20
    186 # zero based
  end
  
  # image view(s)
  
  def image_view(image)
    imageView = UIImageView.alloc.initWithImage image
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    imageView.contentMode = UIViewContentModeScaleAspectFit # UIViewContentModeScaleToFill
    imageView.userInteractionEnabled = true
    imageView
  end
  
  def load_image(image_num)
    path = "#{dir}/#{"%03d" % image_num}"
    path = NSBundle.mainBundle.pathForResource path, ofType: "jpg"
    image = UIImage.imageWithContentsOfFile path
    raise "Image not found: '#{path}', num: #{num}" unless image
    image
  end
  
  # loaded / debounced images
  
  def decorate_mainscroll(mainScroll)
    mainScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    mainScroll.showsVerticalScrollIndicator   = false
    mainScroll.showsHorizontalScrollIndicator = false
    mainScroll.pagingEnabled = true
    mainScroll.backgroundColor = UIColor.whiteColor
    #deleg = WeakRef.new self
    mainScroll.delegate = self
    mainScroll
  end
  
  def image_scroll_view
    # frame = UIApplication.sharedApplication.keyWindow.bounds
    frame = UIScreen.mainScreen.bounds
    mainScroll = UIScrollView.alloc.initWithFrame frame
    mainScroll = decorate_mainscroll mainScroll
    @mainScroll = mainScroll
    
    total_width = UIScreen.mainScreen.bounds.size.height * images_count
    size = CGSizeMake total_width, UIScreen.mainScreen.bounds.size.width
    mainScroll.contentSize = size

    @page_scrollviews = []

    @current_page = 0
    
    # fire = Proc.new do
    #   add_child_page 0
    # end
    # NSTimer.scheduledTimerWithTimeInterval(5, target: fire, selector: 'call:', userInfo: nil, repeats: false)
    
    
    # sleep 4
    
    # add_view_if_necessary 0, mainScroll
    # puts "load"
    add_child_page 0
    
    mainScroll
  end
  
  # scroll view
  
  def page_scroll_view(page_num)
    frame = @mainScroll.bounds
    frame.origin.x = frame.size.width * page_num
  
    pageScroll = UIScrollView.alloc.initWithFrame frame
    pageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    pageScroll.scrollEnabled = false
    pageScroll.clipsToBounds = true
    pageScroll.minimumZoomScale = 1.0
    pageScroll.maximumZoomScale = 2.0
    #deleg = WeakRef.new self     # not needed
    #pageScroll.delegate = deleg  #
    pageScroll.delegate = self
    def pageScroll.idx
      @idx
    end
    def pageScroll.idx=(idx)
      @idx = idx
    end
    pageScroll.idx = page_num
    pageScroll
  end
  
  def add_child_page(page_num)
    # puts "adding #{page_num}"
    
    pageScroll = page_scroll_view page_num 
    
    image = load_image page_num
    imageView = image_view image
    imageView.alpha = 0
    imageView.frame = pageScroll.bounds
    pageScroll.addSubview imageView
    @page_scrollviews << WeakRef.new(pageScroll)
    @mainScroll.addSubview pageScroll
    
    fade_in imageView
    
    #puts "add child: #{page_num}"
  end
  
  def fade_in(view)
    UIView.beginAnimations "Fade In", context: nil
    UIView.setAnimationDuration 0.35
    view.alpha = 1
    UIView.commitAnimations
  end
  
  def add_view_if_necessary(page_num, scrollView)
    return if page_num < 0 || @current_page >= images_count
    
    return if @page_scrollviews.map{ |sv| sv.idx }.include? page_num
    
    
    scrollView.scrollEnabled = false
    add_child_page page_num
    queue = Dispatch::Queue.new "img_unload"
    queue.async do
      sleep 0.1
      scrollView.scrollEnabled = true
    end
  end
  
  def remove_stale_views
    scroll_views = @page_scrollviews.select do |scrollview|
      scrollview.idx < (@current_page - 2) || scrollview.idx > (@current_page + 1)
    end  
    scroll_views.each do |scrollView|
      
      #puts "removing stale views: #{scrollView.idx}, scrollview: #{@page_scrollviews.map{ |sv| sv.idx }}"
      
      @page_scrollviews.delete scrollView 
      for subview in scrollView.subviews
        #subview.removeFromSuperview # optional?
        subview.image = nil
        #subview = nil # optional?
      end
      #scrollView.removeFromSuperview # optional?
      
    end
  end
  
  def update_views_for_page(page_num, scrollView)
    return if @current_page == page_num
    
    add_view_if_necessary page_num - 1, scrollView
    add_view_if_necessary page_num    , scrollView
    #add_view_if_necessary page_num + 1, scrollView
    
    @current_page = page_num
  end
  
  def update_views_for_current_page(scrollView)
    offset = scrollView.contentOffset.x
    width = UIScreen.mainScreen.bounds.size.height
    image_num =  (offset / width + 0.5).to_i 
    
    update_views_for_page image_num, scrollView
  end
  
  include ScrollDelegate # mainScroll delegate
  include ZoomDelegate   # pageScroll delegate

  # autorotation
  
  def shouldAutorotateToInterfaceOrientation(orientation)
    true
  end
  
end