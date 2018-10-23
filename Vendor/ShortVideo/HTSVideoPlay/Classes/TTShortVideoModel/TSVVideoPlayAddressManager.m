//
//  TSVVideoPlayAddressManager.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/12/18.
//

#import "TSVVideoPlayAddressManager.h"

@implementation TSVVideoPlayAddressManager

+ (void)saveVideoPlayAddress:(NSString *)address forGroupID:(NSString *)groupID
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[self videoPlayAddressDict]];
    [dict setValue:address forKey:groupID];
    [[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:@"kTSVShortVideoPlayAddressDict"];
}

+ (void)removeVideoPlayAddressForGroupID:(NSString *)groupID
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[self videoPlayAddressDict]];
    [dict setValue:nil forKey:groupID];
    [[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:@"kTSVShortVideoPlayAddressDict"];
}

+ (NSString *)videoPlayeAddressForGroupID:(NSString *)groupID
{
    return [[self videoPlayAddressDict] objectForKey:groupID];
}

+ (NSDictionary *)videoPlayAddressDict
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kTSVShortVideoPlayAddressDict"];
}

@end


