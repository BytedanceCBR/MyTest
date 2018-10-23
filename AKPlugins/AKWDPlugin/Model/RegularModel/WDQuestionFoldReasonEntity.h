//
//  WDQuestionFoldReasonEntity.h
//  Article
//
//  Created by 延晋 张 on 2016/10/24.
//
//

#import "TTEntityBase.h"

@class WDAnswerFoldReasonStructModel;

@interface WDQuestionFoldReasonEntity : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *openURL;

- (instancetype)initWithModel:(WDAnswerFoldReasonStructModel *)model;

@end
