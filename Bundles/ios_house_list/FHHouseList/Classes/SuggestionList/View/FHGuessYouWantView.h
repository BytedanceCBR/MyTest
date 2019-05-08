//
//  FHGuessYouWantView.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "FHSuggestionListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FHGuessYouWantItemClick)(FHGuessYouWantResponseDataDataModel *model);

// 数据结构体
@interface FHGuessYouWantFirstWords : NSObject

@property (nonatomic, assign)   NSInteger       wordLine;
@property (nonatomic, assign)   CGFloat       wordLength;

@end

@interface FHGuessYouWantView : UIView

@property (nonatomic, copy)     FHGuessYouWantItemClick       clickBlk;
@property (nonatomic, assign)   CGFloat       guessYouWangtViewHeight; // 默认是128，2行
@property (nonatomic, strong)   NSArray<FHGuessYouWantResponseDataDataModel>       *guessYouWantItems;
// 猜你想搜前3个词计算:行数以及长度，外部限制3个吧
- (FHGuessYouWantFirstWords *)firstThreeWords:(NSArray *)array;
- (NSArray<FHGuessYouWantResponseDataDataModel>       *)firstLineGreaterThanSecond:(FHGuessYouWantFirstWords *)firstWords array:(NSArray<FHGuessYouWantResponseDataDataModel> *)array count:(NSInteger)count;

@end

@interface FHGuessYouWantButton : UIButton

@property (nonatomic, strong)   UILabel       *label;

@end

@interface NSArray (FHSort)

- (NSArray *)fh_randomArray;

@end


NS_ASSUME_NONNULL_END
