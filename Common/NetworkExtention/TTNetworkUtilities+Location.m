//
//  TTFantasyWindowManager.m
//  Article
//
//  Created by chenren on 2018/02/06.
//

#import "TTNetworkUtilities.h"
#import "TTLocationManager.h"
#import "NSDataAdditions.h"
#import "NSString+URLEncoding.h"

@implementation TTNetworkUtilities (Location)

+ (void)load
{
    method_exchangeImplementations(class_getClassMethod([self class], @selector(commonURLParameters)),
                                   class_getClassMethod([self class], @selector(tt_commonURLParameters)));
}

+ (NSDictionary *)tt_commonURLParameters
{
    NSDictionary *originalRes = [self tt_commonURLParameters];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:originalRes];
    
    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    if(placemarkItem.coordinate.longitude > 0) {
        NSMutableDictionary *posParameters = [NSMutableDictionary dictionaryWithCapacity:3];
        [posParameters setValue:@(placemarkItem.coordinate.latitude) forKey:@"latitude"];
        [posParameters setValue:@(placemarkItem.coordinate.longitude) forKey:@"longitude"];
        [posParameters setValue:[TTLocationManager sharedManager].city forKey:@"city"];
        
        NSString *info = [posParameters tt_base64StringWithFingerprintType:TTFingerprintTypeXOR];
        if (!isEmptyString(info)) {
            info = [info URLEncodedString];
            [dic setValue:info forKey:@"pos"];
        }
    }

    return dic;
}

@end
