//
//  SharedUtils.m
//  LH2GO
//
//  Created by Himani Bathla on 12/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import "SharedUtils.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "SBJson.h"
#import "EventLog.h"
#import "BLEManager.h"


@implementation SharedUtils
@synthesize activeDataConnection,delegate;
static SharedUtils *instance = nil;

+(id)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = nil;
        instance = [[SharedUtils alloc]init];
        // instance.delegate = self;
    });
    
    return instance;
}
#pragma mark- CLoud API Call

-(void)makePostCloudAPICall : (NSMutableDictionary *)dataDict andURL : (NSString *)apiUrl
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:apiUrl];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSData *myData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:myData];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *token = [PrefManager token];
    [urlRequest setValue:token forHTTPHeaderField:@"token"];
    
    NSLog(@"Data Request");
    __block NSURLSessionDataTask * dataTask;
     dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                   if(error == nil)
                                                                   {
                                                                       NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                                       DLog(@"Response:%@ %@\n", dict, error);
                                                                       if(dict != NULL)
                                                                       {
                                                                           BOOL status = [[dict objectForKey:@"status"] boolValue];
                                                                           NSString *str = [dict objectForKey:@"status"];
                                                                           
                                                                    if ([str isMemberOfClass: [NSString class]] == YES )
                                                                    {
                                                                            NSLog(@"Success");
                                                                    }else
                                                                    {
                                                                        str = @"";
                                                                    }
                                                                           
                                                                    if(status || [str isEqualToString:@"Success"]){
                                                                        if ([self.delegate respondsToSelector:@selector(requestDidFinishWithResponseData:andDataTaskObject:)]) {
                                                                                   [self.delegate requestDidFinishWithResponseData:dict andDataTaskObject:[NSString stringWithFormat:@"%@",dataTask.originalRequest.URL]];
                                                                            }
                                                                        }
                                                                           else{
                                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                               
                                                                               if(error !=nil)
                                                                                   [AppManager handleError:error withOpCode:(long)[httpResponse statusCode] showMessageStatus:NO];
                                                                               else{
                                                                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                                   DLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                                                                   if([httpResponse statusCode] == kTokenExpCode){
                                                                                       [AppManager handleSessionExpiration];
                                                                                   }
                                                                                   else{
                                                                                       
                                                                                       if([[dict objectForKey:@"message"] isEqualToString:@"Session expired, Please login to continue..!"])
                                                                                       {
                                                                                               [AppManager handleSessionExpiration];
                                                                                       }
                                                                                       if ([self.delegate respondsToSelector:@selector(requestDidFinishWithResponseData:andDataTaskObject:)]) {
                                                                                           [self.delegate requestDidFinishWithResponseData:dict andDataTaskObject:[NSString stringWithFormat:@"%@",dataTask.originalRequest.URL]];
                                                                                       }
                                                                                    }
                                                                               }
                                                                           }
                                                                       }
                                                                   }
                                                                   else
                                                                   {
                                                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                       DLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                                                       if ([self.delegate respondsToSelector:@selector(requestFail:)]) {
                                                                           [self.delegate requestFail:error];
                                                                       }
                                                                       [AppManager handleError:error withOpCode:(long)[httpResponse statusCode] showMessageStatus:NO];
                                                                   }
                                                               }];
    [dataTask resume];
    [defaultSession finishTasksAndInvalidate];
    if (!_activeDataSessionTask) {
        _activeDataSessionTask = [[NSMutableArray alloc] init];
        if (dataTask.state != NSURLSessionTaskStateCompleted) {
            [_activeDataSessionTask addObject:dataTask];
            NSLog(@"Active Data Session Tasks Are %@",_activeDataSessionTask);
        }
    }else
    {
        if (dataTask.state != NSURLSessionTaskStateCompleted) {
            [_activeDataSessionTask addObject:dataTask];
            NSLog(@"ELSE Active Data Session Tasks Are %@",_activeDataSessionTask);
        }
    }
    if (_activeDataSessionTask.count>1) {
        
        NSMutableArray *copyArray = [_activeDataSessionTask mutableCopy];
        
        [_activeDataSessionTask enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (idx != [_activeDataSessionTask count]-1) {
                NSURLSessionDataTask * dataTask = [copyArray objectAtIndex:idx];
                [dataTask suspend];
                [copyArray removeObjectAtIndex:idx];
            }
        }];
        
        _activeDataSessionTask = [copyArray mutableCopy];
        NSLog(@"Active data session task count before deleting are %lu",(unsigned long)_activeDataSessionTask.count);
    }
}

-(void)cancelAllCurrentlyTask
{
    NSMutableArray *copyArray = [_activeDataSessionTask mutableCopy];
    
    [_activeDataSessionTask enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
            NSURLSessionDataTask * dataTask = [copyArray objectAtIndex:idx];
            [dataTask suspend];
            [copyArray removeObjectAtIndex:idx];
    }];
    _activeDataSessionTask = [copyArray mutableCopy];
}

+(void)makeEventLogAPICall : (NSString *)apiUrl
{
    // return;
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableArray *eventLogArr = [[NSMutableArray alloc] init];
    //[eventLogArr removeAllObjects];
    
    eventLogArr = [[NSUserDefaults standardUserDefaults] objectForKey:kEventLOG];
    
    NSURL * url = [NSURL URLWithString:apiUrl];
    
    NSMutableArray *arr = [NSMutableArray new];
    arr  = [eventLogArr mutableCopy];
    
    if (arr.count==0) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[Global shared].currentUser.user_id,@"user_id",arr,@"logs",nil];
    
    
    //    {"user_id":"4417","logs":[{"log_category":"Channel","timestamp":"12345","log_sub_category":"on_copy_text","details":{"channelContentId":"464","channelId":"1","text":"sonal"}}]
    //    }
    
    
    //    logs =     (
    //                {
    //                    logCat = Channel;
    //                    logSubCat = "on_access_channels";
    //                    text = "accessed_channels";
    //                    timeStamp = 1516356219;
    //                },
    
    // NSString *userIdInHexFormat = [AppManager convertAStringIntoHexString:[Global shared].currentUser.user_id];
    
    NSString *logStrInHexFormat = nil;
    NSString *bleStr = [[NSString alloc]init];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    logStrInHexFormat = [AppManager convertAStringIntoHexString:aStr];
    bleStr = [bleStr stringByAppendingString:logStrInHexFormat];
    
    if(![AppManager isInternetShouldAlert:NO])
    {
        [[BLEManager sharedManager] broadcastDataOverBbox:bleStr];
    }
    else{
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        NSData *myData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:myData];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *token = [PrefManager token];
        [urlRequest setValue:token forHTTPHeaderField:@"token"];
        
        
        __block NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                       DLog(@"Response:%@ %@\n", response, error);
                                                                       if(error == nil)
                                                                       {
                                                                           
                                                                           NSDictionary*dict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                                           if(dict != NULL)
                                                                           {
                                                                               DLog(@"responseDict is --- %@",dict);
                                                                               
                                                                               BOOL status = [[dict objectForKey:@"status"] boolValue];
                                                                               NSString *msgStr= [dict objectForKey:@"status"];
                                                                               if (status || [msgStr isEqualToString:@"Success"])
                                                                               {
                                                                                   [[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray new] forKey:kEventLOG];
                                                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                   
                                                                                   [DBManager deleteAllFromEntity:@"EventLog"];
                                                                                   
                                                                                   [[Global shared].currentUser setEventCount:0];
                                                                               }
                                                                               else
                                                                               {
                                                                               }
                                                                           }
                                                                       }
                                                                       else
                                                                       {
                                                                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                           NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
                                                                           // [AppManager handleError:error withOpCode:(long)[httpResponse statusCode] showMessageStatus:YES];
                                                                           if ([httpResponse statusCode] == kTokenExpCode)
                                                                           {
                                                                               [AppManager handleSessionExpiration];
                                                                           }
                                                                       }
                                                                   }];
        [dataTask resume];
        [defaultSession finishTasksAndInvalidate];
    }
}


@end
