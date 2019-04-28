//
//  ExploreArticleEssayCellView.h
//  Article
//
//  Created by Chen Hong on 14-9-16.
//
//

#import "ExploreArticleCellView.h"
#import "TTImageView.h"

typedef NS_ENUM(NSUInteger, EssayCellStyle) {
    EssayCellStyleList  = 0,
    EssayCellStyleDetail,
};

@interface ExploreArticleEssayCellView : ExploreArticleCellView

@property(nonatomic,strong)TTImageView *imageView;
@property(nonatomic,assign)BOOL hasImage;
@property (nonatomic, retain) EssayData *essayData;

@property (nonatomic, copy) NSString *trackEventName;
@property (nonatomic, copy) NSString *trackLabelPrefix;

@property (nonatomic, assign) EssayCellStyle from; // 1 : 列表页；2 : 详情页

- (void)layoutPic;

// used by essaydetailview
- (void)refreshWithEssayData:(EssayData *)essay;
- (void)refreshUIForEssayDetailView;
+ (CGFloat)heightWithActionButtonsForEssayData:(EssayData *)essay cellWidth:(CGFloat)width;

@end
