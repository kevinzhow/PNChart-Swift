Pod::Spec.new do |s|
  s.name      = 'PNChartSwift'
  s.version   = '0.0.3'
  s.license   = 'MIT'
  s.summary   = 'A simple and beautiful chart lib written in Swift for iOS'
  s.homepage  = 'https://github.com/kevinzhow/PNChart-Swift'
  s.author    = { "kevinzhow" => "kevinchou.c@gmail.com" }
  s.source    = { :git => "https://github.com/kevinzhow/PNChart-Swift", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PNChartSwift/*'
  s.module_name = 'PNChartSwift'
  s.preserve_path = 'PNChartSwift/PNChartSwift.modulemap'
  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/PNChartSwift/**' }

  s.requires_arc = true
end
