//
//  Country.h
//  
//
//  Created by Parul Mankotia on 31/10/18.
//

#import <CoreData/CoreData.h>

@interface Country : NSManagedObject

@property (nonatomic, retain) NSString *countryName;
@property (nonatomic, retain) NSArray *cityNames;

+ (Country*)countryName:(NSString *)countryName forCityList:(NSArray*)cityListArray shouldInsert:(BOOL)insert;

+(NSArray*)getAllCountry_CityList;

@end
