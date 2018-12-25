//
//  FHGuessYouWantView.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "FHSuggestionListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHGuessYouWantView : UIView

@property (nonatomic, assign)   CGFloat       guessYouWangtViewHeight; // 默认是128，2行
@property (nonatomic, strong)   NSArray<FHGuessYouWantResponseDataDataModel>       *guessYouWantItems;

- (NSArray<FHGuessYouWantResponseDataDataModel>       *)firstLineGreaterThanSecond:(NSString *)firstText array:(NSArray<FHGuessYouWantResponseDataDataModel> *)array count:(NSInteger)count;

@end

@interface FHGuessYouWantButton : UIButton

@property (nonatomic, strong)   UILabel       *label;

@end

NS_ASSUME_NONNULL_END
