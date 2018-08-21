//
//  ArticleMomentDetailViewController.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "SSViewControllerBase.h"
#import "ArticleMomentModel.h"
#import "ArticleMomentManager.h"
#import "ExploreMomentListCellUserActionItemView.h"
#import "TTGroupModel.h"
#import "TTCommentModelProtocol.h"

@interface ArticleMomentDetailViewController : SSViewControllerBase

@property(nonatomic, strong)TTGroupModel *groupModel;
@property(nonatomic, strong)id<TTCommentModelProtocol> commentModel;
@property(nonatomic, strong)ArticleMomentModel *momentModel;
@property(nonatomic, strong)ArticleMomentCommentModel *replyMomentCommentModel;
@property(nonatomic, strong)NSString *itemID;
@property(nonatomic, strong)NSString *categoryID;
@property(nonatomic, assign)NSUInteger gtype;
@property(nonatomic, copy)  NSString *recommendReson;
@property(nonatomic, strong)NSNumber *recommendType;
@property(nonatomic, strong)NSNumber *following;
@property(nonatomic, assign)BOOL fromThread;
- (id)initWithMomentID:(NSString *)momentID;
- (id)initWithComment:(id<TTCommentModelProtocol>)commentModel groupModel:(TTGroupModel *)groupModel momentModel:(ArticleMomentModel *)momentModel delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate showWriteComment:(BOOL)show;
- (id)initWithMomentModel:(ArticleMomentModel *)momentModel;
- (id)initWithMomentModel:(ArticleMomentModel *)momentModel momentManager:(ArticleMomentManager *)momentManager;
- (id)initWithMomentModel:(ArticleMomentModel *)momentModel momentManager:(ArticleMomentManager *)momentManager sourceType:(ArticleMomentSourceType)sourceType;
@end
