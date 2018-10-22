//
//  ChannelDataClassInfo.m
//  LH2GO
//
//  Created by Manoj Dixit on 17/05/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "ChannelDataClassInfo.h"

#define NumberOfParameterLengthVariableLength                   4

#define ParameterRange NSMakeRange(4,NumberOfParameterLengthVariableLength)

@implementation ChannelDataClassInfo

-(id)initWithChannelDataStringHavingEncryption:(NSString *)dataString withContentID:(NSString *)contentID isForOldPacketForFomat:(BOOL)isOldPacket
{
    if (self)
    {
        if (!isOldPacket)
        {
            // for New packet formet
       // NSLog(@"Data String is %@",dataString);

        if (![contentID isEqual:[NSNull null]] || ![contentID isEqualToString:@""]) {
            
            self.contentID = contentID;
            self.isBLEContent = NO;
        }else
        {
            self.contentID = @"";
            self.isBLEContent = YES;
        }
        
        int numberOfParameters = [[dataString substringWithRange:ParameterRange] intValue];
        [self methodToSaveInformationWithSTring:[dataString substringWithRange:NSMakeRange(3, dataString.length-3)]];
        }
        else
        {
            // for old packet format
            [self toHandleOldPacketData:dataString withContentID:contentID];
        }
    }
    return self;
}



-(void)methodToSaveInformationWithSTring:(NSString *)dataParam
{
    if (dataParam.length<4) {
        return;
    }
    int overAllNumberOfParameters = [[dataParam substringWithRange:NSMakeRange(0, 4)] intValue]/2;
    
//    int LengthOfParameters =
    
    NSMutableArray *arrayOfParam = [[NSMutableArray alloc] init];
    NSString *stringOfParamIndex = [dataParam substringWithRange:NSMakeRange(4,overAllNumberOfParameters*2)];
    for (int i = 0; i < overAllNumberOfParameters; i++) {
        [arrayOfParam addObject:[stringOfParamIndex substringWithRange:NSMakeRange(2*i, 2)]];
    }
    // print the array of Param
    DLog(@"Array Of Param %@",arrayOfParam);
    
    NSMutableArray *arrayOfParamLengths = [[NSMutableArray alloc] init];
    NSString *stringOfParamLengthIndex = [dataParam substringWithRange:NSMakeRange(4+overAllNumberOfParameters*2,overAllNumberOfParameters*2)];
    
    for (int i = 0; i < overAllNumberOfParameters; i++) {
        [arrayOfParamLengths addObject:[stringOfParamLengthIndex substringWithRange:NSMakeRange(2*i, 2)]];
    }
    
    // print the array of Param Lengths
    // print the array of Param
    DLog(@"Array Of Param Lengths %@",arrayOfParamLengths);
    
    int numberOfTimeRunningOfLoop = 0;
    int alreadyPassedIndex = 0;
    for (NSString *paramType in arrayOfParam) {
     
    DLog(@"Type Of Param is %@",paramType);
        
        NSString *lengthOfAssociateParam  = [arrayOfParamLengths objectAtIndex:numberOfTimeRunningOfLoop];

        NSString *valueOfCentrainParam =[dataParam substringWithRange:NSMakeRange(4+overAllNumberOfParameters*4 +alreadyPassedIndex,[lengthOfAssociateParam intValue])];
        
        [self paramTypeOfParamType:paramType andValue:valueOfCentrainParam];
        alreadyPassedIndex  = alreadyPassedIndex + [[arrayOfParamLengths objectAtIndex:numberOfTimeRunningOfLoop] intValue];
        
        numberOfTimeRunningOfLoop++;
    }
    NSString *stringHavingInformationOFData = [dataParam substringWithRange:NSMakeRange(4+overAllNumberOfParameters*4 +alreadyPassedIndex,dataParam.length-(4+overAllNumberOfParameters*4 +alreadyPassedIndex))];
    [self methodToSaveInFormationInDataBasewithDataString:stringHavingInformationOFData];
    
}

-(void)paramTypeOfParamType:(NSString *)paramTypeV andValue:(NSString *)valueOfParam
{
    int paramType = [paramTypeV intValue];
    
    //'00' => 'Packet_Revision',
    //'01' => 'Channel_Id',
    //'02' => 'Feed_Id',
    //'03' => 'Push_Timestamp',
    //'04' => 'App_Display_time',
    //'05' => 'Account_Id',
    //'06' => 'Feed_Created_Timestamp',
    //'07' => 'Feed_Expired_Timestamp',
    //'08' => 'Ble_Custom_Alert'
    switch (paramType) {
        case 0:
            // packet version
            self.packetVersion = valueOfParam;
            break;
        case 1:
            // channel ID
            self.channelID =  valueOfParam;
            break;
        case 2:
            // feed ID
            self.feedID = valueOfParam;
            break;
        case 3:
            // push timestamp
            self.pushTimeStamp = valueOfParam;
            break;
        case 4:
            // app display time
            self.appDisplayTime = valueOfParam;
            
            if ([self.appDisplayTime intValue] == k_ForeverFeed_AppDisplayTime){
                self.isForeverFeed = YES;
            }else
               self.isForeverFeed = NO;
    
            break;
        case 5:
            // account id
            self.account_ID  =  valueOfParam;
            break;
        case 6:
            // feed created timestamp
            self.feedCreatedTime = valueOfParam;
            break;
        case 7:
            // feed expired time
            self.feedExpiredTime  = valueOfParam;
            break;
        case 8:
            // ble custom alert
            
            self.bleCustomAlert  =  [[NSString alloc]
                                     initWithData:[[NSData alloc]
                                                   initWithBase64EncodedString:valueOfParam options:0] encoding:NSUTF8StringEncoding];
            break;
        default:
            break;
    }
}

-(void)methodToSaveInFormationInDataBasewithDataString:(NSString *)dataString
{
    NSString *resultingString = dataString;
    NSString *msgType = [resultingString substringWithRange:NSMakeRange(0, 4)];
    
    // save the msg type of String
    self.msgType = msgType;
    NSString *msgl = [resultingString substringWithRange:NSMakeRange(4, 28)];
    NSString *textL=  [msgl substringToIndex:7];
    NSString *actualTxtL = [NSString stringWithFormat:@"%d", [textL intValue]];
    
    NSString *imageL= [msgl substringWithRange:NSMakeRange(7, 7)];
    NSString *actualImgL = [NSString stringWithFormat:@"%d", [imageL intValue]];
    
    NSString *audioL= [msgl substringWithRange:NSMakeRange(14, 7)];
    NSString *actualAudioL = [NSString stringWithFormat:@"%d", [audioL intValue]];
    
    NSString *videoL= [msgl substringWithRange:NSMakeRange(21, 7)];
    NSString *actualVideoL = [NSString stringWithFormat:@"%d", [videoL intValue]];
    
//    if (!(resultingString.length >  (4+ 3 + [actualTxtL integerValue] + [actualImgL integerValue] + [actualAudioL integerValue] + [actualVideoL integerValue]))) {
//        return;
//    }
    
    NSString *mediaPath;
    
    if (resultingString.length  < 32 + [actualTxtL integerValue]) {
        return;
    }
    
    NSString *decodedText = [resultingString substringWithRange:NSMakeRange(32, [actualTxtL integerValue])];
    NSString *decodedString;
    NSData *decodedData;
    
    StringEncryption *encryption = [[StringEncryption alloc] init];
    int numberValueToDivide = 2;
    if (numberValueToDivide==1) {
        
        decodedData = [[NSData alloc] initWithBase64EncodedString:decodedText options:0];
        
        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        DLog(@"Decrypt Text is %@",decodedString);
    }else
    {
        //decodedData = [encryption decryptCipherTextWith:decodedText key:@"MRMVIBITMRMVIBITMRMVIBITMRMVIBIT"
       //                                       iv:[PrefManager iv]];
        
        decodedData = [encryption decryptCipherTextWith:decodedText key:[PrefManager key]
                                                          iv:[PrefManager iv]];

        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        DLog(@"Decrypt Text is %@",decodedString);
    }
    
    // save the message
    self.textMessage =  decodedString;
    
    if (resultingString.length  < 32 + [actualTxtL integerValue] + [actualImgL integerValue]) {
        return;
    }
    
    NSString *EOMSTR = [resultingString substringWithRange:NSMakeRange((32+[actualTxtL integerValue]), 3)];
    
    UIImage *image;
    
    if(![EOMSTR isEqualToString:@"EOM"])
    {
        //Image
        NSString *decodedImageText = [resultingString substringWithRange:NSMakeRange((32+[actualTxtL integerValue]), [actualImgL integerValue])];
        
        NSData *decodedImageData;
        
        if (numberValueToDivide==1) {
            
            decodedImageData = [[NSData alloc] initWithBase64EncodedString:decodedImageText options:0];
            DLog(@"File size is : %.2f KB",(float)decodedImageData.length/1024.0f);
            
            image = [UIImage imageWithData:decodedImageData];
        }
        else
        {
           // decodedImageData = [encryption decryptCipherTextWith:decodedImageText key:@"MRMVIBITMRMVIBITMRMVIBITMRMVIBIT"
          //                                             iv:[PrefManager iv]];
            
            decodedImageData = [encryption decryptCipherTextWith:decodedImageText key:[PrefManager key]
                                                                         iv:[PrefManager iv]];
            
            image = [UIImage imageWithData:decodedImageData];
        }
        
        // save the image Data
        self.imgData = decodedImageData;
        // save the image
        self.image = image;
        
        NSLog(@"File size is : %.2f KB",(float)decodedImageData.length/1024.0f);
        
        
        self.sizeOFImageData = (int)decodedImageData.length/1024.0f;
        
//        NSString *str;// = [dateFormatterb stringFromDate:[NSDate date]];
//
//        if([msgType isEqualToString:@"TIXX"] || [msgType isEqualToString:@"XIXX"]){
//            NSString *str1= [str stringByAppendingString:@".png"];
//            //mediaPath = [self saveDataToFile:decodedImageData withFileName:str1];
//        }
//        else if([msgType isEqualToString:@"TGXX"] || [msgType isEqualToString:@"XGXX"]){
//            NSString *str1= [str stringByAppendingString:@".gif"];
//            //  gifData = decodedImageData;
//            //mediaPath = [self saveDataToFile:decodedImageData withFileName:str1];
//        }
//        else if([msgType isEqualToString:@"TXXX"]){
//            mediaPath = @"";
//        }
//        else
//        {
//            mediaPath = @"";
//            NSLog(@"Something is wrong as did not get the proper message Type");
//        }
//    }
    
    /*
    if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+3) {
        
        NSString *EOMSTR1 = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]), 3)];
        
        if(![EOMSTR1 isEqualToString:@"EOM"])
        {
            
            //Audio
            NSString *decodedAudioText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]), [actualAudioL integerValue])];
            
            NSData *decodedAudioData = [[NSData alloc] initWithBase64EncodedString:decodedAudioText options:0];
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            NSString *str1= [str stringByAppendingString:@".m4a"];
            mediaPath = [self saveDataToFile:decodedAudioData withFileName:str1];
            
        }
    }
    
    if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]+3) {
        
        
        NSString *EOMSTR2 = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]), 3)];
        
        
        if(![EOMSTR2 isEqualToString:@"EOM"])
        {
            //Video
            
            NSString *decodedVideoText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]), [actualVideoL integerValue])];
            
            NSData *decodedVideoData = [[NSData alloc] initWithBase64EncodedString:decodedVideoText options:0];
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            NSString *str1= [str stringByAppendingString:@".mov"];
            mediaPath = [self saveDataToFile:decodedVideoData withFileName:str1];
            
        }
     */
    }
}

-(void)toHandleOldPacketData:(NSString *)dataString withContentID:(NSString *)contentID
{
    NSString *hexString = dataString;
    
    if (hexString.length<3) {
        return;
    }
    
    int numberValueToDivide = 1;
    if([[hexString substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"CMS"])
    {
        numberValueToDivide = 2;
    }
    else
    {
        numberValueToDivide = 1;
    }
    
    DLog(@"Range is %@",[hexString substringWithRange:NSMakeRange(0, 6/numberValueToDivide)]);
    
    
    if (hexString.length<6) {
        return;
    }
    
    NSString *stringForBLEData = [hexString substringWithRange:NSMakeRange(0, 6/numberValueToDivide)];
    
    NSString *begTxt;
    NSString *resultingString;
    NSData *datafromHexString;
    
    if(numberValueToDivide==1)
    {
        datafromHexString =  [AppManager dataFromHexString:hexString];
        resultingString = [[NSString alloc] initWithData:datafromHexString encoding:NSUTF8StringEncoding];
    }else
    {
        resultingString = hexString;
        begTxt = [resultingString substringToIndex:3];
    }
    if([begTxt isEqualToString:@"CMS"] || [stringForBLEData isEqualToString:@"434d53"])
    {
        if (resultingString.length<55) {
            return;
        }
        
    NSString *channelID = [resultingString substringWithRange:NSMakeRange(3, 4)];
    // save channel id
    self.channelID = channelID;
        
    NSString *extraBits = [resultingString substringWithRange:NSMakeRange(7, 6)];
    
    NSString *shoutId = [resultingString substringWithRange:NSMakeRange(13, 4)];
    
    NSString *appDisplayTime = [resultingString substringWithRange:NSMakeRange(17, 6)];
    // app display time
    self.appDisplayTime = appDisplayTime;
    
        if ([self.appDisplayTime intValue] == k_OLD_ForeverFeed_AppDisplayTime) {
            self.isForeverFeed = YES;
        }else
            self.isForeverFeed = NO;

   
        
    NSString *msgType = [resultingString substringWithRange:NSMakeRange(23, 4)];
    // msg type
    self.msgType = msgType;
    
    NSString *msgl = [resultingString substringWithRange:NSMakeRange(27, 28)];
    NSString *textL=  [msgl substringToIndex:7];
    NSString *actualTxtL = [NSString stringWithFormat:@"%d", [textL intValue]];
    
    NSString *imageL= [msgl substringWithRange:NSMakeRange(7, 7)];
    NSString *actualImgL = [NSString stringWithFormat:@"%d", [imageL intValue]];
    
    NSString *audioL= [msgl substringWithRange:NSMakeRange(14, 7)];
    NSString *actualAudioL = [NSString stringWithFormat:@"%d", [audioL intValue]];
    
    NSString *videoL= [msgl substringWithRange:NSMakeRange(21, 7)];
    NSString *actualVideoL = [NSString stringWithFormat:@"%d", [videoL intValue]];
    
    if (!(resultingString.length >  ([actualTxtL integerValue] + [actualImgL integerValue] + [actualAudioL integerValue] + [actualVideoL integerValue]))) {
        return;
    }
    
    NSString *mediaPath;
    NSString *decodedText = [resultingString substringWithRange:NSMakeRange(55, [actualTxtL integerValue])];
    NSString *decodedString;
    NSData *decodedData;
    
    StringEncryption *encryption = [[StringEncryption alloc] init];
    
    if (numberValueToDivide==1) {
        
        decodedData = [[NSData alloc] initWithBase64EncodedString:decodedText options:0];
        
        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        DLog(@"Decrypt Text is %@",decodedString);
        
    }else
    {
        decodedData = [encryption decryptCipherTextWith:decodedText key:[PrefManager iv]
                                              iv:[PrefManager iv]];
        decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        DLog(@"Decrypt Text is %@",decodedString);
    }
    
    // text message
    self.textMessage =  decodedString;
    
    NSString *EOMSTR = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]), 3)];
    
        
        
    if(![EOMSTR isEqualToString:@"EOM"])
    {
        //Image
        NSString *decodedImageText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]), [actualImgL integerValue])];
        
        NSData *decodedImageData;
        UIImage *image;
        if (numberValueToDivide==1) {
            
            decodedImageData = [[NSData alloc] initWithBase64EncodedString:decodedImageText options:0];
            DLog(@"File size is : %.2f KB",(float)decodedImageData.length/1024.0f);
            
            image = [UIImage imageWithData:decodedImageData];
            
        }
        else
        {
            
            decodedImageData = [encryption decryptCipherTextWith:decodedImageText key:[PrefManager iv]
                                                       iv:[PrefManager iv]];
            
            image = [UIImage imageWithData:decodedImageData];
        }
        // save the data of the image
        self.imgData = decodedImageData;
        // save the image
        self.image = image;
        self.sizeOFImageData = (int)decodedImageData.length/1024.0f;
        DLog(@"File size is : %.2f KB",(float)decodedImageData.length/1024.0f);
    }
        /*
        NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
        
        if([msgType isEqualToString:@"TIXX"] || [msgType isEqualToString:@"XIXX"]){
            NSString *str1= [str stringByAppendingString:@".png"];
            mediaPath = [self saveDataToFile:decodedImageData withFileName:str1];
        }
        else if([msgType isEqualToString:@"TGXX"] || [msgType isEqualToString:@"XGXX"]){
            NSString *str1= [str stringByAppendingString:@".gif"];
            //  gifData = decodedImageData;
            mediaPath = [self saveDataToFile:decodedImageData withFileName:str1];
        }
        else if([msgType isEqualToString:@"TXXX"]){
            mediaPath = @"";
        }
        else
        {
            mediaPath = @"";
            NSLog(@"Something is wrong as did not get the proper message Type");
        }
    }
    
    if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+3) {
        
        NSString *EOMSTR1 = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]), 3)];
        
        if(![EOMSTR1 isEqualToString:@"EOM"])
        {
            
            //Audio
            NSString *decodedAudioText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]), [actualAudioL integerValue])];
            
            NSData *decodedAudioData = [[NSData alloc] initWithBase64EncodedString:decodedAudioText options:0];
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            NSString *str1= [str stringByAppendingString:@".m4a"];
            mediaPath = [self saveDataToFile:decodedAudioData withFileName:str1];
            
        }
    }
    
    if (resultingString.length >=55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]+3) {
        
        
        NSString *EOMSTR2 = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]), 3)];
        
        
        if(![EOMSTR2 isEqualToString:@"EOM"])
        {
            //Video
            
            NSString *decodedVideoText = [resultingString substringWithRange:NSMakeRange((55+[actualTxtL integerValue]+[actualImgL integerValue]+[actualAudioL integerValue]), [actualVideoL integerValue])];
            
            NSData *decodedVideoData = [[NSData alloc] initWithBase64EncodedString:decodedVideoText options:0];
            NSString *str = [dateFormatterb stringFromDate:[NSDate date]];
            NSString *str1= [str stringByAppendingString:@".mov"];
            mediaPath = [self saveDataToFile:decodedVideoData withFileName:str1];
            
        }
         */
    }
}

@end

