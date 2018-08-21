//
//  WDPostQuestionDefine.h
//  Article
//
//  Created by 延晋 张 on 16/7/22.
//
//

#pragma once

extern CGFloat const kWDPostQuestionMargin;

typedef NS_ENUM(NSInteger, WDPostQuestionStatus)
{
    WDPostQuestionInitStatus = -1,
    WDPostQuestionInputTitle = 0,
    WDPostQuestionInputDesc,
    WDPostQuestionDone,
};

typedef NS_ENUM(NSUInteger, WDQuestionReviewStatus)
{
    WDQuestionNormal = 0,
    WDQuestionBeReviewd,
    WDQuestionSuggestionModify,
    WDQuestionDeleted,
};
