//
//  SharedUtils.h
//  LH2GO
//
//  Created by Himani Bathla on 12/07/16.
//  Copyright © 2016 Kiwitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APICallProtocolDelegate <NSObject>

@optional

/**
 *  Method of WebServicesCall when the response is received after calling API
 *
 *  @param data NSData is set to parse after getting json response
 */
- (void)requestDidFinishWithResponseData:(NSDictionary *)responseDict andDataTaskObject:(NSString *)dataTaskURL;

- (void)requestFail:(NSError *)errorCode ;

@end


@interface SharedUtils : NSObject
{
    
    // String containing the url of current API
    NSString   *currentURL;
    NSDate *datedateFetchedFromString;
}
/**
 *  @brief Delegates of Webservice Class
 */
@property (nonatomic, weak) id <APICallProtocolDelegate> delegate;

/**
 *  @brief Mutable Data containing response data of API
 */
@property (nonatomic, retain) NSMutableData   *activeDataConnection;


@property (nonatomic,strong) NSMutableArray *activeDataSessionTask;

/**
 *  @brief URL Connection Object for API
 */
@property (nonatomic, retain) NSURLConnection *apiConnection;

/**
 *  Method to make any Post API Call to cloud
 *  @param dict   input parameter to be sent
 *  @param apiUrl api url
 */
-(void)makePostCloudAPICall : (NSMutableDictionary *)dict andURL : (NSString *)apiUrl;

+(void)makeEventLogAPICall : (NSString *)apiUrl;

-(void)cancelAllCurrentlyTask;

@end

