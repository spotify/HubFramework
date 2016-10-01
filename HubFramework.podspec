Pod::Spec.new do |s|

    s.name         = "HubFramework"
    s.version      = "2.0.1"
    s.summary      = "Spotify's component-driven UI framework for iOS"

    s.description  = <<-DESC
                        The Hub Framework is a toolkit for building native,
                        component-driven UIs on iOS. It is designed to enable
                        teams of any size to quickly build, tweak and ship new
                        UI features, in either new or existing apps. It also
                        makes it easy to build backend-driven UIs.
                     DESC

    s.ios.deployment_target     = "8.0"

    s.homepage          = "https://github.com/spotify/HubFramework"
    s.social_media_url  = "https://twitter.com/spotifyeng"
    s.license           = "Apache 2.0"
    s.author            = {
        "John Sundell" => "josu@spotify.com"
    }

    s.source                = { :git => "https://github.com/spotify/HubFramework.git", :tag => s.version }
    s.source_files          = "include/HubFramework/*.h", "HubFramework/*.{h,m}"
    s.public_header_files   = "include/HubFramework/*.h"
    s.frameworks            = "UIKit", "SystemConfiguration"
    s.xcconfig              = {
        "OTHER_LDFLAGS" => "-lObjC"
    }

end
