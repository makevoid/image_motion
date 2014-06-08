module ScrollDelegate
  
  # mainScroll delegate (scroll)
  
  def scrollViewDidEndDecelerating(scrollView)
    update_views_for_current_page scrollView
    update_status
    
    offset_x = scrollView.contentOffset.x
    if offset_x % 1024 == 0 && offset_x > 0
      remove_stale_views 
    end
  end
  

  # keep in mind you can use other events like: scrollViewDidEndDecelerating, scrollViewDidScroll 
  # https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIScrollViewDelegate_Protocol/Reference/UIScrollViewDelegate.html
end