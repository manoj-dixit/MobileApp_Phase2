//
//  Country.m
//  
//
//  Created by Parul Mankotia on 31/10/18.
//

#import "Country.h"


@implementation Country
@synthesize countryName,cityNames;

+ (Country*)countryName:(NSString *)countryName forCityList:(NSArray*)cityListArray shouldInsert:(BOOL)insert{
    Country *country = [DBManager entityWithStr:@"Country" idName:countryName idList:cityListArray];
    if (!insert) return country;
    if (!country) {
        Country *country = [CoreDataManager insertObjectFor:@"Country"];
        country.countryName = countryName;
        country.cityNames = cityListArray;
        [CoreDataManager saveContext];
    }
    return country;
}

+(NSArray*)getAllCountry_CityList{
    NSArray *country = [DBManager entities:@"Country" pred:nil descr:nil isDistinctResults:YES];
    return country;
}


@end
