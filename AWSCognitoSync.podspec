Pod::Spec.new do |s|

  s.name         = 'AWSCognitoSync'
  s.version      = '1.0.5'
  s.summary      = 'Amazon Cognito SDK for iOS'

  s.description  = 'Amazon Cognito offers multi device data synchronization with offline access'

  s.homepage     = 'http://aws.amazon.com/cognito'
  s.license      = 'Amazon Software License'
  s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://github.com/aws/amazon-cognito-ios.git',
                     :tag => s.version}
  s.dependency 'AWSiOSSDKv2'
  s.requires_arc = true

  s.subspec 'Cognito' do |cognito|
    cognito.source_files = 'Cognito/*.{h,m}', 'Cognito/**/*.{h,m}', 'CognitoSync/*.{h,m}', 'CognitoSync/**/*.{h,m}'
    cognito.public_header_files = 'Cognito/*.h, 'CognitoSync/*.h'
    cognito.resources = ['CognitoSync/Resources/*.json']
  end
end
