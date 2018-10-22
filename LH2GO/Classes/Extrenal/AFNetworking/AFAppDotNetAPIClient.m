
#import "AFAppDotNetAPIClient.h"

@implementation AFAppDotNetAPIClient

+ (instancetype)sharedClient {
    
    static AFAppDotNetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
   
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAppDotNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [_sharedClient.securityPolicy setValidatesDomainName:NO];
        [_sharedClient.securityPolicy setAllowInvalidCertificates:YES];
        _sharedClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
      
        
       
    });
    
    return _sharedClient;
}

@end
