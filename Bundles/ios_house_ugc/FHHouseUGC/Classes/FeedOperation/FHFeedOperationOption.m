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
    switch (keyword.type) {
        case FHFeedOperationWordTypeOthers:
            return FHFeedOperationOptionTypeOther;
        case FHFeedOperationWordTypeReport:
            return FHFeedOperationOptionTypeReport;
        case FHFeedOperationWordTypeDelete:
            return FHFeedOperationOptionTypeDelete;
    }
}

@end
