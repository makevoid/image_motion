# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  #app.name = 'image_motion'
  app.name = "UACS#1 - Up-And-Coming Style"

  # app.frameworks << "CoreGraphics"

  app.sdk_version = "5.1" # rake device install_only=1
  
  app.icons = [76, 152, 1024].map{ |px| "icon_#{px}" }
  
  app.device_family = :ipad # universal?
  app.interface_orientations = [:landscape_left, :landscape_right]
  
  
  app.provisioning_profile = '/Users/makevoid/Library/MobileDevice/Provisioning Profiles/6DE0A495-7A05-4671-9067-FE007F2F0682.mobileprovision'
end

