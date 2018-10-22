//
//  DisplayPresenceList.m
//  LH2GO
//
//  Created by Manoj Dixit on 03/10/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

#import "DisplayPresenceList.h"

@implementation DisplayPresenceList

//aging_Count
//device_ID
//device_Role
//dp_Interval
//hope_Count
//interface
//seq_NO
//timestamp

@dynamic aging_Count;
@dynamic device_ID;
@dynamic device_Role;
@dynamic seq_NO;
@dynamic dp_Interval;
@dynamic hope_Count;
@dynamic interface;
@dynamic timestamp;



+(void)insertOrUpdateTheDevicePresenceValue:(NSMutableDictionary *)dictData
{
    //DisplayPresenceList *displayPresenceList;
    
    //aging_Count
    //device_ID
    //device_Role
    //dp_Interval
    //hope_Count
    //interface
    //seq_NO
    //timestamp
    
    // query to get the entry of the Device ID if exist.
    __block NSArray *arr;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        arr   = [DBManager entitiesForScheduled:@"DisplayPresenceList" pred:[NSString stringWithFormat:@"device_ID = \"%@\"",[dictData objectForKey:@"device_ID"]] descr:nil isDistinctResults:YES];

    });
    sleep(0.5);
    //NSLog(@"database entries are %@",arr);
    
    if(arr.count>=1)
    {
        // already Entry there
        // Need to update the entry
        DisplayPresenceList *displayPresenceList = [arr objectAtIndex:0];

        [self updateTheDevicePresenceValue:dictData andArrayValue:displayPresenceList];
    }else
    {
        // Need to add the new entry
        [self insertTheDevicePresenceValue:dictData];
    }
}

+(void)updateTheDevicePresenceValue:(NSMutableDictionary *)dictData andArrayValue:(DisplayPresenceList *)displayPresenceList
{
//    __block NSArray *arr;
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        arr   = [DBManager entitiesForScheduled:@"DisplayPresenceList" pred:nil descr:nil isDistinctResults:YES];
//
//    });
//    sleep(2);
    
    // Aging Count
    if ([dictData objectForKey:@"aging_Count"]) {
        displayPresenceList.aging_Count =  [NSString stringWithFormat:@"%@",[dictData objectForKey:@"aging_Count"]];
    }
    
    // device_ID
    if ([dictData objectForKey:@"device_ID"]) {
        displayPresenceList.device_ID = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"device_ID"]];
    }
    
    // device_Role
    if ([dictData objectForKey:@"device_Role"]) {
        displayPresenceList.device_Role = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"device_Role"]];
    }
    
    // device_Role
    if ([dictData objectForKey:@"device_Role"]) {
        displayPresenceList.dp_Interval = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"dp_Interval"]];
    }
    
    // interface
    if ([dictData objectForKey:@"interface"]) {
        displayPresenceList.interface = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"interface"]];
    }
    
    // hope_Count
    if ([dictData objectForKey:@"hope_Count"]) {
        displayPresenceList.hope_Count = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"hope_Count"]];
    }
    
    // seq_NO
    if ([dictData objectForKey:@"seq_NO"]) {
        displayPresenceList.seq_NO = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"seq_NO"]];
    }
    
    // timestamp
    if ([dictData objectForKey:@"timestamp"]) {
        displayPresenceList.timestamp = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"timestamp"]];
    }
    // save the data into the core data base
    [CoreDataManager saveContext];
}

+(void)insertTheDevicePresenceValue:(NSMutableDictionary *)dictData
{
    DisplayPresenceList *displayPresenceList;
    
    displayPresenceList =  [NSEntityDescription insertNewObjectForEntityForName:@"DisplayPresenceList" inManagedObjectContext:[App_delegate xyz]];
    
    // Aging Count
    if ([dictData objectForKey:@"aging_Count"]) {
        displayPresenceList.aging_Count =  [NSString stringWithFormat:@"%@",[dictData objectForKey:@"aging_Count"]];
    }
    
    // device_ID
    if ([dictData objectForKey:@"device_ID"]) {
        displayPresenceList.device_ID = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"device_ID"]];
    }
    
    // device_Role
    if ([dictData objectForKey:@"device_Role"]) {
        displayPresenceList.device_Role = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"device_Role"]];
    }
    
    // device_Role
    if ([dictData objectForKey:@"device_Role"]) {
        displayPresenceList.dp_Interval = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"dp_Interval"]];
    }
    
    // interface
    if ([dictData objectForKey:@"interface"]) {
        displayPresenceList.interface = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"interface"]];
    }
    
    // hope_Count
    if ([dictData objectForKey:@"hope_Count"]) {
        displayPresenceList.hope_Count = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"hope_Count"]];
    }
    
    // seq_NO
    if ([dictData objectForKey:@"seq_NO"]) {
        displayPresenceList.seq_NO = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"seq_NO"]];
    }
    
    // timestamp
    if ([dictData objectForKey:@"timestamp"]) {
        displayPresenceList.timestamp = [NSString stringWithFormat:@"%@",[dictData objectForKey:@"timestamp"]];
    }
    
    // save the data into the core data base
    [CoreDataManager saveContext];
}

+(void)checkTheListToDeleteENtry
{
    // List of the Display Presence List
    __block NSArray *arr;
    
    
    // calculate the timestamp of the current date
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        arr   = [DBManager entitiesForScheduled:@"DisplayPresenceList" pred:nil descr:nil isDistinctResults:YES];
        
    });
    sleep(0.5);
   // NSLog(@"database entries are %@",arr);
    if(arr.count>=1)
    {
    for (int i=0; i<=arr.count; i++) {
       
        DisplayPresenceList *displayPresenceList = [arr objectAtIndex:i];
        
        // device presence value with current timestamp
        if([[displayPresenceList timestamp] intValue] >= [[AppManager timeStamp] intValue])
        {
            
        }else if ([[displayPresenceList timestamp] intValue] - [[AppManager timeStamp] intValue] > 5*PacketTimeInterval)
            {
                [DBManager deleteOb:displayPresenceList];
            }
        else
        {
            // we can decrease the aging count
        }
    }
    }else
    {
        
    }
}

+(void)deleteTheDevicePresenceValue:(NSMutableDictionary *)dictData
{
    DisplayPresenceList *displayPresenceList;
    
    NSArray *arr   = [DBManager entities:@"DisplayPresenceList" pred:[NSString stringWithFormat:@"device_ID = \"%@\" ",[dictData objectForKey:@"device_ID"]] descr:nil isDistinctResults:YES];
    
   // NSLog(@"database entries are %@",arr);
    
    if(arr.count>=1)
    {
        // delete the data as it already presence
        displayPresenceList = [arr objectAtIndex:0];
        [DBManager deleteOb:displayPresenceList];
    }else
    {
        // Data is not present in the Database
        
    }
}

@end
