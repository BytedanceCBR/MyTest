
#import "TTBaseCellEntity.h"
#import "Article.h"
#import "TTDetailModel.h"

@interface TTVideoFloatCellEntity : TTBaseCellEntity
@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, assign) BOOL startActivity;
@property (nonatomic, assign) float startY;//cell开始高度
@property (nonatomic, assign) float endY;//cell结束高度
@property (nonatomic, assign) BOOL showed;//已经发送过show事件了
@end
