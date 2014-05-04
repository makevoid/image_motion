module ZoomDelegate

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
  
end