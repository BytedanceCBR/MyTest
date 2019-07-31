//
//  FHHouseDislikeView.h
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

//#import <UIKit/UIKit.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface FHHouseDislikeView : UIView
//
//@end
//
//NS_ASSUME_NONNULL_END

#import "TTFeedPopupView.h"
#import "FHHouseDislikeWord.h"


NS_ASSUME_NONNULL_BEGIN

@class FHHouseDislikeView;

typedef void (^FHHouseDislikeBlock)(FHHouseDislikeView * view);

@interface FHHouseDislikeViewModel : NSObject

@property(nonatomic, copy, nullable) NSArray<NSDictionary *> *keywords;
@property(nonatomic, strong, nullable) NSString *groupID;
@property(nonatomic, copy, nullable) NSString *logExtra;
@property(nonatomic, copy, nullable) NSString *source;
@property(nonatomic, strong, nullable) NSDictionary *extrasDict;

@end

//------------------------------------------------------------------

@interface FHHouseDislikeView : TTFeedPopupView

@property(nonatomic, strong)NSMutableArray *dislikeWords;

- (void)refreshWithModel:(nullable FHHouseDislikeViewModel *)model;

- (nonnull NSArray<NSDictionary *> *)selectedWords;

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
    didDislikeBlock:(FHHouseDislikeBlock)didDislikeBlock;

+ (void)dismissIfVisible;

+ (void)enable;

+ (void)disable;

@end

NS_ASSUME_NONNULL_END
