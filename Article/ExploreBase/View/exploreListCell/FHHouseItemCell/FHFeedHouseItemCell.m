//
//  FHFeedHouseItemCell.m
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "FHFeedHouseItemCell.h"
#import "TTRoute.h"
#import "FHExploreHouseItemData.h"
#import "ExploreOrderedData+TTBusiness.h"

@implementation FHFeedHouseItemCell

+ (Class)cellViewClass {
    return [FHFeedHouseItemCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@interface FHFeedHouseItemCellView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *houseTableView;

@end


@implementation FHFeedHouseItemCellView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildupView];
    }
    return self;
}

- (void)buildupView {

    // add by zjing for test
    self.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.houseTableView];
    
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    NSParameterAssert([data isKindOfClass:[ExploreOrderedData class]]);
    
    self.orderedData = data;

    [self.houseTableView reloadData];
}

- (void)willAppear {

}

- (void)didDisappear {
    
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    
//    TTExploreLoadMoreTipData *model = self.orderedData.loadmoreTipData;
//    if (model == nil || ![model isKindOfClass:[TTExploreLoadMoreTipData class]]) {
//        return;
//    }
//    NSURL *openURL = [NSURL URLWithString:model.openURL];
//    [[TTRoute sharedRoute] openURLByViewController:openURL userInfo:nil];
    

}


+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    return 65.0f + 105 * 3 + 48.f;
}

#pragma mark - tableView dataSource & delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.orderedData.houseItemsData.items.count < 1) {
        return 0;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.orderedData.houseItemsData.items.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    TTCommentReplyModel *model;
//    if (indexPath.row < _replyArr.count) {
//        model = _replyArr[indexPath.row];
//    }
//    else {
//        NSString *moreReplyText = [NSString stringWithFormat:@"查看全部%lld条回复", [_toComment.replyCount longLongValue]];
//        TTCommentReplyModel *moreReplyModel = [TTCommentReplyModel replyModelWithDict:@{@"user_name":moreReplyText} forCommentID:_toComment.commentID.stringValue];
//        moreReplyModel.notReplyMsg = YES;
//        model = moreReplyModel;
//    }
//    [cell refreshWithModel:model width:self.width];
//
//    __weak typeof(self) wself = self;
//    [cell handleUserClickActionWithBlock:^(TTCommentReplyModel *replyModel) {
//        if (wself.replyUserBlock) {
//            wself.replyUserBlock(replyModel);
//        }
//    }];
    
    return cell;
    
}

#pragma mark - lazy load

-(UITableView *)houseTableView {
    
    if (!_houseTableView) {
        
        _houseTableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _houseTableView.dataSource = self;
        _houseTableView.delegate = self;
    }
    return _houseTableView;
}

@end

