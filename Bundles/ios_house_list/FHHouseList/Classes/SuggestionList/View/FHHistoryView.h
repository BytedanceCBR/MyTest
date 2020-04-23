//
//  FHGuessYouWantView.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "FHSuggestionListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FHHistoryItemClick)(FHSuggestionSearchHistoryResponseDataDataModel *model, NSInteger index);

// 数据结构体
@interface FHHistoryFirstWords : NSObject

@property (nonatomic, assign)   NSInteger       wordLine;
@property (nonatomic, assign)   CGFloat       wordLength;

@end

@interface FHHistoryView : UIView

@property (nonatomic, copy)     FHHistoryItemClick       clickBlk;
@property (nonatomic, assign)   CGFloat       historyViewHeight; // 默认是128，2行
@property (nonatomic, strong)   NSArray<FHSuggestionSearchHistoryResponseDataDataModel>       *historyItems;
@property (nonatomic, copy)     dispatch_block_t       delClick;
@property (nonatomic, copy)     dispatch_block_t       moreClick;
@end

@interface FHHistoryButton : UIButton

@property (nonatomic, strong)   UILabel       *label;

@end

@interface NSArray (FHSort)

- (NSArray *)fh_randomArray;

@end


NS_ASSUME_NONNULL_END
