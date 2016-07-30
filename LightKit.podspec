Pod::Spec.new do |s|

  s.name         = "LightKit"
  s.version      = "0.0.1"
  s.summary      = "MacBook Light Sensor and Display/Keyboard brightness control"
  s.homepage     = "https://github.com/maxmouchet/LightKit"
  s.license      = "BSD"
  s.description  = <<-DESC
  Ambient Light Sensor, Display, and Keyboard brightness control in Swift.
                   DESC

  s.author = { "Maxime Mouchet" => "max@maxmouchet.com" }
  s.social_media_url = "http://twitter.com/maxmouchet"

  s.platform      = :osx, "10.9"
  s.source        = { git: "https://github.com/maxmouchet/LightKit.git", tag: s.version.to_s }
  s.source_files  = "LightKit", "LightKit/**/*.{h,m}"
  s.exclude_files = "LightKit/Exclude"

end
