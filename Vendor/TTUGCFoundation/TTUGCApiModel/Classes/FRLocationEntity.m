//
//  FRLocationEntity.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/28.
//
//

#import "FRLocationEntity.h"
#import "FRApiModel.h"


@implementation FRLocationEntity

+ (FRLocationEntity *)genLocationFromStruct:(FRGeographyStructModel *)structModel
{
    if (!structModel) {
        return nil;
    }
    
    NSArray *locationComponents = [structModel.position componentsSeparatedByString:@" "];
    if (locationComponents.count != 2) {
        return nil;
    }
    
    FRLocationEntity * location = [[FRLocationEntity alloc] init];
    location.locationType = FRLocationEntityTypeNomal;
    location.latitude = structModel.latitude.doubleValue;
    location.longitude = structModel.longitude.doubleValue;
    location.city = locationComponents[0];
    location.locationName = locationComponents[1];
    location.locationAddress = nil;
    return location;
}

@end
