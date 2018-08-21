//
//  TTVDetailCarCard.m
//  Article
//
//  Created by pei yun on 2017/8/25.
//
//

#import "TTVDetailCarCard.h"

@implementation TTVDetailCarCard

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    TTVDetailCarCard *card = nil;
    return @{
             @keypath(card, card_type) : @"card_type",
             @keypath(card, cover_url) : @"cover_url",
             @keypath(card, price) : @"price",
             @keypath(card, series_name) : @"series_name",
             @keypath(card, open_url) : @"open_url",
             };
}

@end
