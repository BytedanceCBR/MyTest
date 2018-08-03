//
//  ArticleMomentDigUsersViewController.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-28.
//
//

#import "ArticleMomentDigUsersViewController.h"
#import "ArticleMomentDigUsersView.h"
#import "SSNavigationBar.h"
#import "ArticleMomentGroupModel.h"
#import <TTUIWidget/TTFoldableLayout.h>

@interface ArticleMomentDigUsersViewController ()
@property (nonatomic, strong) ArticleMomentModel *model;
@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@end

@implementation ArticleMomentDigUsersViewController

- (id)initWithMomentModel:(ArticleMomentModel *)model {
    self = [super init];
    if (self) {
        self.model = model;
        self.needRefresh = YES;
    }
    return self;
}

- (instancetype)initWithCommentModel:(id<TTCommentModelProtocol>)commentModel {
    self = [super init];
    if (self) {
        _commentModel = commentModel;
        self.needRefresh = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.commentModel) {
        self.diggUserView = [[ArticleMomentDigUsersView alloc] initWithFrame:self.view.bounds commentModel:self.commentModel];
    } else {
        self.diggUserView = [[ArticleMomentDigUsersView alloc] initWithFrame:self.view.bounds momentModel:self.model];
    }
    [self.view addSubview:_diggUserView];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"赞过的人", nil)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.diggUserView.frame = self.view.bounds;
}

- (void)refreshIfNeedWithMoment:(ArticleMomentModel *)model {
    [_diggUserView refreshWithMomentModel:model];
    _model = model;
}
@end
