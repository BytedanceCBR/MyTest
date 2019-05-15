//
//  TTWendaCellForwardUGCHelper.m
//  Article
//
//  Created by wangqi.kaisa on 2017/8/16.
//
//

#import "TTWendaCellForwardUGCHelper.h"
#import "TTRepostViewController.h"
#import "TTRepostOriginModels.h"
#import <AKWDPlugin/WDAnswerEntity.h>

@implementation TTWendaCellForwardUGCHelper

- (void)forwardUGCWithAnswerEntity:(WDAnswerEntity *)answerEntity {
    TTRepostOriginTTWendaAnswer *repostOriginWendaAnswer = [[TTRepostOriginTTWendaAnswer alloc] initWithAnswerEntity:answerEntity];
    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeWendaAnswer
                                                                originWendaAnswer:repostOriginWendaAnswer
                                                                  operationItemID:answerEntity.ansid
                                                                   repostSegments:nil];
}

@end
