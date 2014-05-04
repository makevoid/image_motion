module ScrollDelegate
  
  # mainScroll delegate (scroll)

  # def scrollViewDidEndDecelerating(scrollView)
  # def scrollViewDidScroll(scrollView)
  
  def scrollViewDidEndDecelerating(scrollView)
    update_views_for_current_page scrollView
  end

  def scrollViewDidEndDecelerating(scrollView)
    update_views_for_current_page scrollView
    
    offset_x = scrollView.contentOffset.x
    if offset_x % 1024 == 0 && offset_x > 0
      remove_stale_views 
    end
  end
  
end