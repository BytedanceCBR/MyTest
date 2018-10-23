//
//  TTCommentDefines.h
//  Article
//
//  Created by Jiyee Sheng on 04/01/2018.
//
//

@class TTGroupModel;
@class SSThemedView;

#define iconfont           @"ask_icon"
#define ask_arrow_right    @"\U0000E610"

#define kAccountBindingMobileNotification  @"kAccountBindingMobileNotification"

#define TTCommentDefaultLoadMoreFetchCount 20
#define TTCommentDefaultLoadMoreOffsetCount 20

//最大可以输入的长度
#define kCommentMaxLength   2000
#define kCommentMaxEssayPublishLength 300
#define kCommentMaxtAtNum 20

#define kCommentNoLoginTip                     NSLocalizedString(@"请先绑定一个账号", nil)
#define kCommentNoNetworkConnectedTip          NSLocalizedString(@"没有网络连接", nil)
#define kCommentInputContentTooShortTip        NSLocalizedString(@"请输入评论", nil)
#define kCommentInputContentTooLongTip         NSLocalizedString(@"发送内容不可以超过%d个字", nil)
#define kCommentBanCommentTip                  NSLocalizedString(@"该文章暂不支持评论", nil)
#define kCommentInputContentAtTooManyTip       NSLocalizedString(@"已超过@用户数上限，请调整后再发", nil)
#define kCommentInputContentTooManyTip         NSLocalizedString(@"字数限制为最多2000字，请调整后再发。", nil)
#define kCommentInputPlaceHolder               NSLocalizedString(@"优质评论将会被优先展示", nil)
#define kCommentSending                        NSLocalizedString(@"发送中...", nil)
#define kCommentSendDone                       NSLocalizedString(@"发送成功", nil)
#define kCommentOK                             NSLocalizedString(@"确定", nil)
#define kCommentCancel                         NSLocalizedString(@"取消", nil)
#define kCommentSend                           NSLocalizedString(@"发送", nil)

/**
 *  取到评论数据后的操作，如数据model化
 */
typedef void (^TTCommentLoadFinishBlock)(NSDictionary * _Nonnull results, NSError * _Nullable error, BOOL isStickComment);

typedef NS_ENUM(NSInteger, TTCommentLoadMode)
{
    TTCommentLoadModeRefresh,
    TTCommentLoadModeLoadMore
};

typedef NS_ENUM(NSInteger, TTCommentCategory)
{
    TTCommentCategoryHot = 0,
    TTCommentCategoryTimeLine
};

typedef NS_ENUM(NSInteger, TTCommentFoldModel)
{
    TTCommentFoldModelNone = 0,   //不获取折叠相关信息
    TTCommentFoldModelNormal,     //正常评论数据, 增加fold_comment_count
    TTCommentFoldModelFold        //获取折叠区评论数据
};

typedef NS_OPTIONS(NSUInteger, TTCommentLoadOptions) {

    TTCommentLoadOptionsFold = 1 << 0,
    TTCommentLoadOptionsStick = 1 << 1
};

typedef NS_ENUM(NSInteger, TTCommentsGroupType) {
    TTCommentsGroupTypeArticle = 0,
    TTCommentsGroupTypeThread = 2,
};

#pragma mark - TTCommentDataSource

@protocol TTCommentDataSource <NSObject>

/**
 *  更新列表后的UI操作，如loadMore之后停止动画
 */
typedef void (^TTCommentLoadCompletionHandler)(NSError* _Nullable error);

@required


@optional
/**
 *  获取评论列表。组件内部触发及UI响应，外部根据业务调服务端接口
 *
 *  @param loadMode    refresh或loadMore
 *  @param offset      loadMore模式下的偏移量
 *  @param finishBlock 获取到数据后回调组件刷新UI
 */
- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode
        possibleLoadMoreOffset:(nullable NSNumber *)offset
                       options:(TTCommentLoadOptions)options
                   finishBlock:(nullable TTCommentLoadFinishBlock)finishBlock;

/**
 *  评论列表header，如浮层
 *
 */
- (nullable SSThemedView *)tt_commentHeaderView;

/**
 *  评论所需外部核心数据
 *
 */
- (nonnull TTGroupModel *)tt_groupModel;

/**
 *  转载的评论数
 *
 */
- (NSInteger)tt_zzComments;

/**
 *  评论所属的thread
 *
 */
- (nonnull NSString *)tt_primaryID;

/**
 *  评论列表是否放出删除评论。大开关，如果返回true，每个cell都一定放出
 *
 */
- (BOOL)tt_shouldShowDeleteComments;

/**
 埋点额外参数
 */
- (NSDictionary *)extraTrackParams;

@end

