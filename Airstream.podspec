Pod::Spec.new do |s|
  s.name          = 'Airstream'
  s.version       = '0.1.0'
  s.summary       = 'Stream audio from one Apple device to another, using AirPlay.'
  s.homepage      = 'https://github.com/qasim/Airstream'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.authors       = { 'Qasim Iqbal' => 'me@qas.im' }
  s.source        = { :git => 'https://github.com/qasim/Airstream.git', :tag => s.version }
  s.source_files  = '*.{h,m}'
  s.frameworks    = 'Foundation', 'AudioToolbox'
  s.exclude_files = 'Examples'
end
