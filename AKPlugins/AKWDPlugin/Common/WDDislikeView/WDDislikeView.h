//
//  WDDislikeView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/10/17.
//

#import <TTPlatformUIModel/TTFeedPopupView.h>
#import <TTPlatformUIModel/TTFeedDislikeWord.h>

/*
 * 10.17 问答业务中的dislikeview
 */

@class WDDislikeView;

typedef void (^WDDislikeClickBlock)(WDDislikeView * view);

@interface WDDislikeViewModel : NSObject

@property(nonatomic, copy) NSArray<NSDictionary *> *keywords;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, copy) NSString *logExtra;

@end

@interface WDDislikeView : TTFeedPopupView

- (void)refreshWithModel:(WDDislikeViewModel *)model;

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
    didDislikeBlock:(WDDislikeClickBlock)didDislikeBlock;

- (NSArray<TTFeedDislikeWord *> *)selectedWords;

+ (void)dismissIfVisible;

+ (void)enable;

+ (void)disable;

@end
