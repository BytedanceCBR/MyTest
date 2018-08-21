//
//  TTArticleMomentDigUsersViewController.m
//  Article
//
//  Created by zhaoqin on 27/12/2016.
//
//

#import "TTArticleMomentDigUsersViewController.h"
#import "ArticleMomentModel.h"
#import "TTArticleMomentDigUsersView.h"
#import "SSNavigationBar.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTAlphaThemedButton.h"
#import "NSObject+FBKVOController.h"
#import "TTViewWrapper.h"


#define TTEdgeHeight self.titleView.height

@interface TTArticleMomentDigUsersViewController ()
@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) TTViewWrapper *viewWrapper;
@property (nonatomic, assign) NSInteger diggCount;
@end

@implementation TTArticleMomentDigUsersViewController

+ (void)load {
    RegisterRouteObjWithEntryName(@"comment_digg_list");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _gid = [paramObj.allParams tt_stringValueForKey:@"group_id"];
        _categoryName = [paramObj.allParams tt_stringValueForKey:@"category_id"];
        _fromPage = [paramObj.allParams tt_stringValueForKey:@"from_page"];
        _commentID = [paramObj.allParams tt_stringValueForKey:@"comment_id"];
        _diggCount = [paramObj.allParams tt_integerValueForKey:@"digg_count"];

        _needRefresh = YES;
        _sourceFrom = TTArticleMomentDigUserSourceCommentDetail;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title;
    if (self.sourceFrom == TTArticleMomentDigUserSourceCommentRepostDetail) {
        title = @"赞过的人";
    }
    else {
        title = [NSString stringWithFormat:@"%ld人赞过", (long)self.diggCount];
    }
    self.title = title;
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:title];
    
    self.diggUserView = [[TTArticleMomentDigUsersView alloc] initWithFrame:self.view.bounds commentID:self.commentID];
    self.diggUserView.isBanShowAuthor = self.isBanShowAuthor;
    self.diggUserView.categoryName = self.categoryName;
    self.diggUserView.groupId = self.gid;
    self.diggUserView.fromPage = self.fromPage;
    self.diggUserView.backgroundColorThemeKey = kColorBackground4;
    self.diggUserView.listView.backgroundColorThemeKey = kColorBackground4;
    
    self.viewWrapper = [TTViewWrapper viewWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) targetView:self.diggUserView];
    self.viewWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.viewWrapper.backgroundColorThemeKey = kColorBackground3;
    
    [self.view addSubview:self.viewWrapper];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}



#pragma mark - TTArticleDigUsersViewDelegate
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    wrapperTrackEvent(@"update_detail", @"enter_diggers");
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        self.viewWrapper.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        self.diggUserView.frame = CGRectMake([TTUIResponderHelper paddingForViewWidth:self.view.width], 0, self.view.width - [TTUIResponderHelper paddingForViewWidth:self.view.width] * 2, self.view.height);
    }
}

- (UIScrollView *)tt_scrollView {
    return self.diggUserView.listView;
}

#pragma mark - Utils
- (UIView *)innerTransitionView {
    for (UIView *subview in self.navigationController.view.subviews) {
        if ([subview isMemberOfClass:NSClassFromString(@"UINavigationTransitionView")]) {
            return subview;
        }
    }
    return nil;
}

@end
