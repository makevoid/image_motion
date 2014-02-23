# it's all implemented in this class
#
# notes, warnings: - I'm delegating both scoll views to this class, this needs refactor

class ImagesController< UIViewController
  
  attr_reader :dir
  
  def initWithImagesDir(dir)
    @dir = dir
    
    view = image_scroll_view
    
    self.view.addSubview view
    
    init
  end
  
  def images_count
    49
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
    raise "Image not found: #{path}" unless image
    image
  end
  
  # loaded / debounced images
  
  def image_scroll_view
    mainScroll = UIScrollView.alloc.initWithFrame UIScreen.mainScreen.bounds
    mainScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    mainScroll.showsVerticalScrollIndicator   = false
    mainScroll.showsHorizontalScrollIndicator = false
    mainScroll.pagingEnabled = true
    mainScroll.backgroundColor = UIColor.whiteColor
    #deleg = WeakRef.new self
    mainScroll.delegate = self
    @mainScroll = mainScroll
    
    total_width = UIScreen.mainScreen.bounds.size.height * images_count
    size = CGSizeMake total_width, UIScreen.mainScreen.bounds.size.width
    mainScroll.contentSize = size

    @page_scrollviews = []

    @current_page = 0
    add_child_page 0
    add_child_page 1
    
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
    deleg = WeakRef.new self
    pageScroll.delegate = deleg
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
    pageScroll = page_scroll_view page_num 
    
    image = load_image page_num
    imageView = image_view image
    imageView.alpha = 0
    imageView.frame = pageScroll.bounds
    pageScroll.addSubview imageView
    @page_scrollviews << WeakRef.new(pageScroll)
    @mainScroll.addSubview pageScroll
    
    fade_in imageView
    
    puts "add child: #{page_num}"
  end
  
  def fade_in(view)
    UIView.beginAnimations "Fade In", context: nil
    UIView.setAnimationDuration 0.35
    view.alpha = 1
    UIView.commitAnimations
  end
  
  
  def add_view_if_necessary(page_num)
    return if page_num < 0 || @current_page >= images_count
    
    return if @page_scrollviews.map{ |sv| sv.idx }.include? page_num
    
    add_child_page page_num
  end
  
  
  UNLOAD_QUEUE = Dispatch::Queue.new "img_unload"
  
  def remove_stale_views
    scroll_views = @page_scrollviews.select do |scrollview|
      scrollview.idx < (@current_page - 1) || scrollview.idx > (@current_page + 1)
    end  
    scroll_views.each do |scrollView|

      UNLOAD_QUEUE.async do
        @page_scrollviews.delete scrollView
        for subview in scrollView.subviews
          subview.removeFromSuperview
          subview.image = nil
          subview = nil
        end
        scrollView.removeFromSuperview
        puts "removed stale views: #{scrollView.idx}, scrollview: #{@page_scrollviews.map{ |sv| sv.idx }}"
      end
      
      
    end
  end
  
  def update_views_for_page(page_num)
    
    return if @current_page == page_num
    
    # add_view_if_necessary page_num - 1
    add_view_if_necessary page_num
    # add_view_if_necessary page_num + 1
    
    remove_stale_views
    
    @current_page = page_num
  end
  
  def update_views_for_current_page(scrollView)
    offset = scrollView.contentOffset.x
    width = UIScreen.mainScreen.bounds.size.height
    image_num =  (offset / width + 0.5).to_i 
    
    update_views_for_page image_num
  end
  
  # mainScroll delegate (scroll)
  
  # def scrollViewDidEndDecelerating(scrollView)
  def scrollViewDidScroll(scrollView)
    update_views_for_current_page scrollView
  end
  
  # def scrollViewWillScroll(scrollView)
  #   update_views_for_current_page scrollView
  # end
  
  # pageScroll delegate (zoom)
  
  def viewForZoomingInScrollView(scrollView)
    scrollView.subviews.first
  end

  def scrollViewDidZoom(scrollView)
    if scrollView.zoomScale != 1.0
      scrollView.scrollEnabled = true
    else
      scrollView.scrollEnabled = false
    end
  end
  
  # autorotation
  
  def shouldAutorotateToInterfaceOrientation(orientation)
    true
  end
  
end