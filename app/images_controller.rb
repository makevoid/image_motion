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
    path = "#{dir}/#{"%03d" % image_num}.jpg"
    image = UIImage.imageNamed path
    #return @@placeholder unless image
    raise "Image not found: #{path}" unless image
    image
  end
  
  # loaded / debounced images
  
  @@placeholder   = nil
  @@page_scrollviews   = []
  
  def scroll_view_for_page(page)
    # ...
  end
  
  # scroll view
  
  def page_scroll_view
    pageScroll = UIScrollView.alloc.initWithFrame rect
    pageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    pageScroll.scrollEnabled = false
    pageScroll.clipsToBounds = true
    pageScroll.minimumZoomScale = 1.0
    pageScroll.maximumZoomScale = 2.0
    pageScroll.zoomScale = 0.3
    pageScroll.delegate = self
    pageScroll
  end
  
  def image_scroll_view
    mainScroll = UIScrollView.alloc.initWithFrame UIScreen.mainScreen.bounds
    mainScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    mainScroll.showsVerticalScrollIndicator   = false
    mainScroll.showsHorizontalScrollIndicator = false
    mainScroll.pagingEnabled = true
    mainScroll.backgroundColor = UIColor.whiteColor
    mainScroll.delegate = self
    
    total_width = UIScreen.mainScreen.bounds.size.height * images_count
    size = CGSizeMake total_width, UIScreen.mainScreen.bounds.size.width
    mainScroll.contentSize = size

    rect = mainScroll.bounds
    
    @current_page = 0
    
      pageScroll = page_scroll_view
      
      image = if image_num <= 3 
        load_image image_num
      else
        @@placeholder
      end
      imageView = image_view image
      imageView.frame = pageScroll.bounds
      pageScroll.addSubview imageView
      
      mainScroll.addSubview pageScroll
      
      if image_num < images_count
        rect.origin.x += rect.size.width * 1.333
      end
    
    mainScroll
  end
  
  def add_view_if_necessary(page_num)
    image = load_image page_num
    imageView = image_view image
    imageView.frame = scrollView.bounds
    
  end
  
  def remove_stale_views(page_num)
    if @current_page < (page - 1) || @current_page > (page + 1)
    
      for subview in scrollView.subviews
        subview.removeFromSuperview
      end
      scrollView.addSubview imageView
      
    end
  end
  
  def update_views_for_page(page_num)
    
    return if @current_page == page_num
    
    add_view_if_necessary page_num
    
    remove_stale_views page_num
    
    @current_page = page_num
  end
  
  # mainScroll delegate (scroll)
  
  # def scrollViewDidEndDecelerating(scrollView)
  def scrollViewDidScroll(scrollView)
    offset = scrollView.contentOffset.x
    width = UIScreen.mainScreen.bounds.size.height
    image_num =  (offset / width + 0.5).to_i 
    
    update_views_for_page image_num
  end
  
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