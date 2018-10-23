//
//  TTVVideoDetailNatantPGCViewController.m
//  Article
//
//  Created by lishuangyang on 2017/5/24.
//
//
#import "SSImpressionManager.h"
#import "TTMessageCenter.h"
#import "TTVVideoDetailNatantPGCViewController.h"
#import "TTVVideoDetailNatantPGCAuthorView.h"
@interface TTVVideoDetailNatantPGCModel ()

@property (nonatomic, strong)id<TTVArticleProtocol> article;
@end

@implementation TTVVideoDetailNatantPGCModel

@synthesize contentInfo = _contentInfo;

- (instancetype)initWithVideoArticle:(id<TTVArticleProtocol>)article{
    self = [super init];
    if ([article conformsToProtocol:@protocol(TTVArticleProtocol)]) {
        _article = article;
        self.itemId = article.itemID;
        self.groupIDStr = article.groupModel.groupID;
        self.videoSource = article.videoID;
        NSString *userDecoration = [article.detailUserInfo valueForKey:@"user_decoration"];
        if (!isEmptyString(userDecoration)) {
            userDecoration = [article.userInfo valueForKey:@"user_decoration"];
        }
        self.userDecoration = userDecoration;
        self.videoID = article.videoID;
        self.mediaUserID = article.mediaUserID;
    }
    return self;
}

- (NSDictionary *)contentInfo
{
    return self.article.userInfo;
}

- (void)setContentInfo:(NSDictionary *)contentInfo
{
    if (_contentInfo != contentInfo) {
        _contentInfo = contentInfo;
        if (self.updateFansCountBlock) {
            self.updateFansCountBlock([contentInfo valueForKey:@"fans_count"]);
        }
        if (![self.article conformsToProtocol:@protocol(TTVArticleProtocol)]) {
            return;
        }
        [self.article updateFollowed:[contentInfo ttgc_isSubCribed]];
        
    }
}

@end

@implementation TTVVideoDetailNatantPGCViewController 

- (instancetype)initWithInfoModel: (TTVVideoDetailNatantPGCModel *) PGCInfo andWidth:(float) width;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.authorView = [[TTVVideoDetailNatantPGCAuthorView alloc] initWithInfoModel:PGCInfo andWidth:width];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.height = self.authorView.height;
    [self.view addSubview:self.authorView];
    self.view.clipsToBounds = YES;
}

- (void)viewDidLayoutSubviews
{
    self.authorView.left = (self.view.width - self.authorView.width) / 2.0;
    [super viewDidLayoutSubviews];
}

@end
