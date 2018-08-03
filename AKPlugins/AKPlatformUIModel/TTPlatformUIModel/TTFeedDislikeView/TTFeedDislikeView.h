//
//  ExploreDislikeView.h
//  Article
//
//  Created by Chen Hong on 14/11/19.
//
//

#import "TTFeedPopupView.h"


NS_ASSUME_NONNULL_BEGIN

@class TTFeedDislikeView;

typedef void (^TTFeedDislikeBlock)(TTFeedDislikeView * view);

@interface TTFeedDislikeViewModel : NSObject

@property(nonatomic, copy, nullable) NSArray<NSDictionary *> *keywords;
@property(nonatomic, strong, nullable) NSString *groupID;
@property(nonatomic, copy, nullable) NSString *logExtra;
@property(nonatomic, copy, nullable) NSString *source;
@property(nonatomic, strong, nullable) NSDictionary *extrasDict;

@end

//------------------------------------------------------------------

@interface TTFeedDislikeView : TTFeedPopupView

- (void)refreshWithModel:(nullable TTFeedDislikeViewModel *)model;

- (nonnull NSArray<NSDictionary *> *)selectedWords;

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
       didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock;

+ (void)dismissIfVisible;

+ (void)enable;

+ (void)disable;

+ (BOOL)isFeedDislikeRefactorEnabled;

@end

NS_ASSUME_NONNULL_END
