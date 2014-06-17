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
  app.version = "1.0"
  # app.frameworks << "CoreGraphics"

  app.sdk_version = "7.0" # rake device install_only=1
  
  app.icons = [72, 76, 152, 1024].map{ |px| "icon_#{px}" }
  
  app.device_family = :ipad # universal?
  app.interface_orientations = [:landscape_left, :landscape_right]
  
  app.identifier = "com.makevoid.upandcoming"
  app.device_family = [:ipad]
  # app.prerendered_icon = true # removes glossy effect
  
  app.codesign_certificate = "iPhone Distribution: makevoid inc"
  app.provisioning_profile = '/Users/makevoid/Library/MobileDevice/Provisioning Profiles/08B035E7-610F-416A-8CE0-14D8FFE8F2F2.mobileprovision'
  
  
  # distribution 
  # app.deployment_target = '5.1.1'
  
end

