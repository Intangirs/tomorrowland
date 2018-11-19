# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def install_pods
  pod "Alamofire", "~> 4.7"
  pod "KeychainSwift", "~> 12.0.0"
  pod "ActiveLabel"
  pod "Kingfisher", "~> 4.0"
  pod "Kiri", :git => "https://github.com/junkpiano/Kiri.git", :branch => 'master'
  pod "MMKV"
end

target 'TomorrowLand' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TomorrowLand
  install_pods

  target 'TomorrowLandTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TomorrowLandUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

plugin 'cocoapods-keys', {
  :project => "TomorrowLand",
  :keys => [
      'MASTODON_CLIENT_ID',
      'MASTODON_CLIENT_SECRET',
      'MASTODON_REDIRECT_URI',
      'MASTODON_SCOPE'
  ]}
