Pod::Spec.new do |s|

  s.name         = 'AWSCognitoSync'
  s.version      = '1.0.1'
  s.summary      = 'Amazon Cognito SDK for iOS'

  s.description  = 'Amazon Cognito offers multi device data synchronization with offline access'

  s.homepage     = 'http://aws.amazon.com/cognito'
  s.license      = 'Amazon Software License'
  s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://github.com/aws/amazon-cognito-ios.git',
                     :tag => s.version}
  s.library      = 'sqlite3'

  s.dependency 'AWSiOSSDKv2'

  s.requires_arc = true

  s.subspec 'CognitoSyncService' do |cognitosync|
    cognitosync.source_files = 'CognitoSyncService/*.{h,m}'
  end

  s.subspec 'CognitoSyncClient' do |cognito|
    cognito.dependency 'AWSCognitoSync/CognitoSyncService'
    cognito.source_files = 'Cognito/**/*.{h,m}'
    cognito.public_header_files = "Cognito/*.h"
  end
end
