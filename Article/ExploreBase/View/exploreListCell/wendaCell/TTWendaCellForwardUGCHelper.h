//
//  TTWendaCellForwardUGCHelper.h
//  Article
//
//  Created by wangqi.kaisa on 2017/8/16.
//
//

#import <Foundation/Foundation.h>

/*
 * 8.16 问答转发到UGC的帮助类
 */

@class WDAnswerEntity;

@interface TTWendaCellForwardUGCHelper : NSObject

- (void)forwardUGCWithAnswerEntity:(WDAnswerEntity *)answerEntity;

@end
