//
//  FHUGCVotePublishTypeSelectViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/14.
//

#import "FHUGCVotePublishTypeSelectViewController.h"
#import <WDDefines.h>
#import <FHCommonDefines.h>
#import "Masonry.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>

#define PADDING 20

@interface FHUGCVotePublishVoteTypeSelectCell: UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *selectedButton;
+ (NSString *)reusedIdentifier;
@end

@implementation FHUGCVotePublishVoteTypeSelectCell

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UIButton *)selectedButton {
    if(!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setImage:[UIImage imageNamed:@"fh_ugc_vote_publish_type_normal"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"fh_ugc_vote_publish_type_selected"] forState:UIControlStateSelected];
        _selectedButton.userInteractionEnabled = NO;
    }
    return _selectedButton;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.selectedButton];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(PADDING);
            make.top.bottom.equalTo(self.contentView);
        }];
        
        [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-PADDING);
            make.width.height.mas_offset(20);
            make.centerY.equalTo(self.titleLabel);
        }];
    }
    return self;
}

+ (NSString *)reusedIdentifier {
    return NSStringFromClass(self.class);
}
@end

@implementation FHUGCVotePublishVoteTypeModel
@end

@interface FHUGCVotePublishTypeSelectViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UITableView *voteTypeTableView;
@property (nonatomic, strong) NSMutableArray<FHUGCVotePublishVoteTypeModel *> *dataSource;

@property (nonatomic, copy) void (^resultBlock)(FHUGCVotePublishVoteTypeModel *);
@property (nonatomic, assign) VoteType selectedVoteType;
@end

@implementation FHUGCVotePublishTypeSelectViewController

- (NSMutableArray<FHUGCVotePublishVoteTypeModel *> *)dataSource {
    if(!_dataSource) {
        _dataSource = [NSMutableArray array];
        
        FHUGCVotePublishVoteTypeModel *singlSelect = [FHUGCVotePublishVoteTypeModel new];
        singlSelect.title = @"单选";
        singlSelect.type = VoteType_SingleSelect;
        singlSelect.isSelected = (self.selectedVoteType == VoteType_SingleSelect);
        
        FHUGCVotePublishVoteTypeModel *multiSelect = [FHUGCVotePublishVoteTypeModel new];
        multiSelect.title = @"多选";
        multiSelect.type = VoteType_MultipleSelect;
        multiSelect.isSelected = (self.selectedVoteType == VoteType_MultipleSelect);
        
        [_dataSource addObject:singlSelect];
        [_dataSource addObject:multiSelect];
    }
    return _dataSource;
}

- (UITableView *)voteTypeTableView {
    if(!_voteTypeTableView) {
        _voteTypeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, self.view.bounds.size.height - kNavigationBarHeight) style:UITableViewStylePlain];
        _voteTypeTableView.delegate = self;
        _voteTypeTableView.dataSource = self;
        [_voteTypeTableView registerClass:[FHUGCVotePublishVoteTypeSelectCell class] forCellReuseIdentifier:[FHUGCVotePublishVoteTypeSelectCell reusedIdentifier]];
        _voteTypeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _voteTypeTableView.backgroundColor = [UIColor themeGray7];
    }
    return _voteTypeTableView;
}

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.resultBlock = paramObj.allParams[@"resultBlock"];
        self.selectedVoteType = (VoteType)[paramObj.allParams[@"voteType"] integerValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configNavigation];

    [self.view addSubview:self.voteTypeTableView];
}

- (void)configNavigation {
    
    [self setupDefaultNavBar:YES];
    
    [self setTitle:@"投票类型"];
    // 标题
    self.navigationItem.titleView = self.titleLabel;
    
    // 取消按钮
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn]];
    
    // 发布按钮
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.completeBtn]];
}


// MARK: UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource enumerateObjectsUsingBlock:^(FHUGCVotePublishVoteTypeModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(idx == indexPath.row) {
            model.isSelected = !model.isSelected;
        } else {
            model.isSelected = NO;
        }
        
    }];
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
// MARK: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCVotePublishVoteTypeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:[FHUGCVotePublishVoteTypeSelectCell reusedIdentifier] forIndexPath:indexPath];
    
    FHUGCVotePublishVoteTypeModel *model = self.dataSource[indexPath.row];
    cell.titleLabel.text = model.title;
    cell.selectedButton.selected = model.isSelected;
    
    return cell;
}
- (UIButton *)cancelBtn {
    if(!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_cancelBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(0, 0, 32, 44);
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"投票类型";
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

- (UIButton *)completeBtn {
    if(!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_completeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        _completeBtn.frame = CGRectMake(0, 0, 32, 44);
        [_completeBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

- (void)completeAction: (UIButton *)sender {
    WeakSelf;
    [self.dataSource enumerateObjectsUsingBlock:^(FHUGCVotePublishVoteTypeModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if(model.isSelected) {
            self.resultBlock(model);
            *stop = YES;
        }
    }];
    
    [self exitPage];
}

- (void)cancelAction: (UIButton *)sender {
    [self exitPage];
}

- (void)exitPage {
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
