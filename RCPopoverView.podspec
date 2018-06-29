

Pod::Spec.new do |s|
  s.name             = 'RCPopoverView'
  s.version          = '0.1.0'
  s.summary          = 'Custom popover menu'

  s.homepage         = 'https://github.com/whyefa/RCPopoverView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'whyefa' => 'whyefa@163.com' }
  s.source           = { :git => 'https://github.com/whyefa/RCPopoverView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'RCPopoverView/Classes/**/*'

end
