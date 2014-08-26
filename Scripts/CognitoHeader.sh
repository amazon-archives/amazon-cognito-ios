echo "correct the way to import framework's headers"
find . -name '*.h' | xargs perl -pi -e 's/#import "Cognito/#import <AWSCognitoSync\/Cognito/g'
find . -name '*.h' | xargs perl -pi -e 's/#import "AWSCognito/#import <AWSCognitoSync\/AWSCognito/g'
find . -name '*.h' | xargs perl -pi -e 's/"Mantle.h"/<Mantle\/Mantle.h>/g'
find . -name '*.h' | xargs perl -pi -e 's/"Bolts.h"/<Bolts\/Bolts.h>/g'
find . -name '*.h' | xargs perl -pi -e 's/"TMCache.h"/<TMCache\/TMCache.h>/g'
find . -name '*.h' | xargs perl -pi -e 's/#import "/#import <AWSiOSSDKv2\//g'
find . -name '*.h' | xargs perl -pi -e 's/h"/h>/g'