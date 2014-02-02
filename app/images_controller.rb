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
  
  def load_image_dequeued(image_num, page_scrollview)
    @@page_scrollviews.unshift page_scrollview
    image = load_image image_num
    unload_old_images
    puts "loading #{image_num}"
    image
  end
  
  def unload_old_images
    @@page_scrollviews = @@page_scrollviews[0..3]
  end
  
  # loaded / debounced images
  
  @@placeholder   = nil
  @@page_scrollviews   = []
  
  # scroll view
  
  def image_scroll_view
    # rotate img
    #image = UIImage.alloc.initWithCGImage image.CGImage, scale: 1.0, orientation: UIImageOrientationLeft
    
    mainScroll = UIScrollView.alloc.initWithFrame UIScreen.mainScreen.bounds
    mainScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    mainScroll.showsVerticalScrollIndicator   = false
    mainScroll.showsHorizontalScrollIndicator = false
    mainScroll.pagingEnabled = true
    mainScroll.backgroundColor = UIColor.whiteColor
    mainScroll.delegate = self
    
    # load placeholder image to set size and dequeue
    image = load_image 1
    @@placeholder = image
    imageView = image_view image
    total_width = UIScreen.mainScreen.bounds.size.height * images_count
    size = CGSizeMake total_width, UIScreen.mainScreen.bounds.size.width
    mainScroll.contentSize = size
    
    rect = mainScroll.bounds
    
    1.upto(images_count) do |image_num|
      pageScroll = UIScrollView.alloc.initWithFrame rect
      pageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      pageScroll.scrollEnabled = false
      pageScroll.clipsToBounds = true
      pageScroll.minimumZoomScale = 1.0
      pageScroll.maximumZoomScale = 2.0
      pageScroll.zoomScale = 0.3
      pageScroll.delegate = self
      
      image = if image_num <= 3 
        load_image_dequeued image_num, pageScroll
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
    end
    
    mainScroll
  end
  
  # mainScroll delegate (scroll)
  
  # QUEUE = Dispatch::Queue.new('scroll')

  def scrollViewDidScroll(scrollView)
    # QUEUE.async do 
      offset = scrollView.contentOffset.x
      width = UIScreen.mainScreen.bounds.size.height
      image_num =  (offset / width).to_i + 1
      
      puts "scrolling #{image_num}: #{offset}, #{width}"
      
      unless @@page_scrollviews.include? scrollView
        
        image = load_image_dequeued image_num, scrollView
        imageView = image_view image
        imageView.frame = scrollView.bounds
        for subview in scrollView.subviews
          subview.removeFromSuperview
        end
        scrollView.addSubview imageView
        
      end
      
      # # primes - uses cpu so i can test if the function is throttled
      # p=[];(2..a).each{|n| p.any?{|l|n%l==0}?nil:p.push(n)};p
      
    # end
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