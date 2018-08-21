//
//  WDQuestionFoldReasonEntity.m
//  Article
//
//  Created by 延晋 张 on 2016/10/24.
//
//

#import "WDQuestionFoldReasonEntity.h"
#import "WDDataBaseManager.h"
#import "WDDefines.h"

@implementation WDQuestionFoldReasonEntity

- (instancetype)initWithModel:(WDAnswerFoldReasonStructModel *)model
{
    self = [super init];
    if (self) {
        self.title = model.title;
        self.openURL = model.open_url;
    }
    return self;
}

@end
