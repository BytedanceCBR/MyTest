//
//  WDListAnswerCellBottomView.h
//  AKWDPlugin
//
//  Created by 张元科 on 2019/6/14.
//

#import <UIKit/UIKit.h>
#import "WDUIHelper.h"
#import "TTRoute.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "TTImageView.h"
#import <KVOController/NSObject+FBKVOController.h>
#import <TTUIWidget/TTIndicatorView.h>
#import "WDWendaListCell.h"
#import "WDAnswerEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WDListAnswerCellBottomView : UIView

@property (nonatomic, strong) WDAnswerEntity *ansEntity;
@property (nonatomic, copy) NSDictionary *gdExtJson;
@property (nonatomic, copy) NSDictionary *apiParams;

@end

@interface WDListAnswerCellBottomButton : UIButton

@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign)   BOOL       followed;

@end

NS_ASSUME_NONNULL_END
