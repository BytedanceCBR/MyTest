//
//  FHFeedOperationOption.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/16.
//

#import "FHFeedOperationOption.h"
#import "FHFeedOperationWord.h"
#import "FHFeedOperationView.h"
#import "TTBaseMacro.h"

@implementation FHFeedOperationOption

+ (FHFeedOperationOptionType)optionTypeForKeyword:(FHFeedOperationWord *)keyword {
    return (FHFeedOperationOptionType)keyword.type;
}

@end
