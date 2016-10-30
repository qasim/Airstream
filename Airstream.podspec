Pod::Spec.new do |spec|
  spec.name         = 'Airstream'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/qasim/Airstream'
  spec.authors      = { 'Qasim Iqbal' => 'me@qas.im' }
  spec.summary      = 'Stream audio from one Apple device to another, using AirPlay.'
  spec.source       = { :git => 'https://github.com/qasim/Airstream.git', :tag => '0.1.0' }
  spec.source_files = 'Airstream.{h,m}'
  spec.frameworks   = 'AudioToolbox', 'AudioUnit'
end
