

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"


@interface AFAppDotNetAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
