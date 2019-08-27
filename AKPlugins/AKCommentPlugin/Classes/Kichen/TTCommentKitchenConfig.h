//
//  TTCommentKitchenConfig.h
//  Article
//
//  Created by SongChai on 2018/3/19.
//
//

#import <TTKitchen/TTKitchen.h>

static NSString * kTTKUGCCommentRepostCheckBoxType = @"tt_hide_comment_check_box.comment_repost_check_box_type"; // 1表示弹起评论框总是勾选评论并转发，2表示总是不选，3表示记录上次&第一次勾选，4表示记录上次&第一次不选

static NSString * const kTTKCommentImageForbidenTips = @"tt_ugc_comment_image_forbiden_tips";

static NSString * const kTTKCommentImageIconHidden = @"tt_ugc_comment_image_hidden";

static NSString * const kTTKCommentRepostSelected = @"tt_ugc_repost_comment_selected"; //评论并转发，☑️是否默认勾选，会记录

static NSString * const kTTCommentReplyListFilterDisable = @"tt_reply_list_disable_filter";   //评论排序策略优化开关，为YES时不去重，为NO时去重

static NSString * const kTTCommentStyle = @"tt_comment_setting_data.new_comment_ui_type";   // 评论样式 0：老样式；1：转评赞样式无转赞文本；2：转评赞样式有转赞文本


static NSString * const kTTCommentHashTagHidden = @"tt_comment_setting_data.comment_hashtag_hidden"; //评论的hashtag按钮是否展示，为yes时隐藏，为no时显示

static NSString * const kTTCommentPublishRichSpanCountLimit = @"tt_comment_setting_data.comment_rich_span_count"; //评论发布时的富文本数量的限制，现在为hashtag+@人数量


static NSString * const kTTCommentWriteInputBoxStyle = @"tt_comment_setting_data.comment_input_box_style";  //评论区输入面积样式，0:老样式；1：扩大输入框的样式

static NSString * const kTTCommentDislike = @"tt_ugc_comment_dislike.comment";  //评论区dislike

// fps
static NSString * const kTTCommentFPSMonitorEnable = @"tt_comment_setting_data.fps_monitor_enable";  // 监控是否可用
static NSString * const kTTCommentFPSMonitorInterval = @"tt_comment_setting_data.fps_monitor_interval";  // 间隔时间
static NSString * const kTTCommentFPSMonitorMinCount = @"tt_comment_setting_data.fps_monitor_min_count";  // 最小统计数
static NSString * const kTTCommentFPSMonitorDuration = @"tt_comment_setting_data.fps_monitor_duration";  // 统计最长持续时间
static NSString * const kTTCommentFPSMonitorCommentDetailLastTime = @"tt_comment_setting_data.fps_monitor_comment_detail_last_time";  // 本地存取 评论详情页

static NSString * const kTTKCommentRepostFirstDetailText = @"tt_ugc_repost_comment_union.first_comment_region.title"; //文章、帖子评论☑️后文字

@interface TTKitchenManager (TTComment)

@end
