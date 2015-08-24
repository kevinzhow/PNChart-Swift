Pod::Spec.new do |s|
  s.name      = 'PNChartSwift'
  s.version   = '0.0.2'
  s.license   = 'MIT'
  s.summary   = 'A simple and beautiful chart lib written in Swift for iOS'
  s.homepage  = 'https://github.com/kevinzhow/PNChart-Swift'
  s.author    = { "kevinzhow" => "kevinchou.c@gmail.com" }
  s.source    = { :git => 'https://github.com/kevinzhow/PNChart-Swift.git' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PNChartSwift/**/*.swift'

  s.requires_arc = true
end
