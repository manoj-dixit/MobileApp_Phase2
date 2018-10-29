//
//  SERVICES.h
//  CBTutorial
//
//  Created by Orlando Pereira on 10/16/13.
//  Copyright (c) 2013 Mobile tuts. All rights reserved.
//  Edited : @raj (may,2015)

#ifndef  CBTutorial_SERVICES_h
#define CBTutorial_SERVICES_h

#define TRANSFER_SERVICE_UUID  @"CBDA" //@"0095aad6-8719-11e7-bb31-be2e44b06b34"  //@"CBDA"

#define TRANSFER_CHARACTERISTIC_SONAR_UUID     @"54CB75F1-086E-4DC4-9929-A77FD02653C1"
#define TRANSFER_CHARACTERISTIC_WRITE_UUID     @"38E4C000-9D8C-2964-70B3-2CFD9E63774A"
#define TRANSFER_CHARACTERISTIC_UPDATE_UUID    @"18591F7E-DB16-467E-8758-72F6FAEB03D8"
//#define TRANSFER_CHARACTERISTIC_READ_UPDATE_CONNECTED_IDS    @"4a8cc23a-c13b-11e7-abc4-cec278b6b50a"
//#define TRANSFER_CHARACTERISTIC_READ_PERIPHERAL_ID    @"7d5996a2-71b1-47d9-8450-48119463c7e7"
//#define TRANSFER_CHARACTERISTIC_WRITE_ID              @"727925a6-739b-42ad-ae08-8929cafc9d7e"


#define NOTIFY_MTU_MIN  100.0
#define NOTIFY_MTU_MAX  150.0

extern NSUInteger currentRSSIValue;

#define EOM        @"EOM"
#define BOM        @"BOM"
#define CMS        @"CMS"
#define USERID     @"USERID"
#define BOUD       @"BOUD"
#define EOUD       @"EOUD"

static NSString *kEditUserProfile     = @"UserProfileedited";

static inline NSInteger EOMLength() {
    NSData *data = [EOM dataUsingEncoding:NSUTF8StringEncoding];
    return data.length;
}

static inline NSData* EOMData() {
    NSData *data = [EOM dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

static inline NSData *EOUDData(){
    NSData *data = [EOUD dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

static inline NSInteger BEGLength() {
    NSData *data = [BOM dataUsingEncoding:NSUTF8StringEncoding];
    return data.length;
}

static inline NSInteger UserIDLength() {
    NSData *data = [USERID dataUsingEncoding:NSUTF8StringEncoding];
    return data.length;
}

static inline NSInteger CMSLength() {
    NSData *data = [CMS dataUsingEncoding:NSUTF8StringEncoding];
    return data.length;
}

static inline NSData* BOMData() {
    NSData *data = [BOM dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

static inline NSData* BOUDData() {
    NSData *data = [BOUD dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

static inline NSInteger BOUDLength() {
    NSData *data = [BOUD dataUsingEncoding:NSUTF8StringEncoding];
    return data.length;
}


static inline float getRandomForAdv()
{
    float min_value=0;
    float max_value=0;
    min_value = 7.0;
    max_value = 9.0;

    float randomValue = min_value + ((float)arc4random() / UINT32_MAX) * (max_value - min_value);
    NSLog(@"random number for Adv ######### is %f", randomValue);
    return randomValue;
}

static inline float getRandomforScan()
{
    float min_value=0;
    float max_value=0;
    min_value = 5.0;
    max_value = 6.0;
    
    float randomValue = min_value + ((float)arc4random() / UINT32_MAX) * (max_value - min_value);
    NSLog(@"random number for scan ######### is %f", randomValue);
    return randomValue;
}

static inline float getRandomforDiscardDuplicateConnection()
{
    float min_value=0;
    float max_value=0;
    min_value = 7.1;
    max_value = 19.9;
    
   float randomValue = min_value + ((float)arc4random() / UINT32_MAX) * (max_value - min_value);
    DLog(@"random number for Disconnection ++ ######### is %f", randomValue);
    return randomValue;
}

#endif
