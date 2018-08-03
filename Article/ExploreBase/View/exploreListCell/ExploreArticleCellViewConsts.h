//
//  ExploreArticleCellViewConsts.h
//  Article
//
//  Created by Chen Hong on 14-9-11.
//
//

#ifndef Article_ExploreArticleCellViewConsts_h
#define Article_ExploreArticleCellViewConsts_h

//长图下面的jagview
#define kJagViewLeftPadding           7

//view边距
#define kCellTopPadding             cellTopPadding()            //view上边距(纯文字、大图、多图、视频)
#define kCellTopPaddingWithRightPic cellTopPaddingWithRightPic()//view上边距(右图、右视频)
#define kCellBottomPadding          cellBottomPadding()         //view下边距(纯文字)
#define kCellBottomPaddingWithPic   cellBottomPaddingWithPic()  //view下边距(右图、右视频、大图、多图、视频)
#define kCellLeftPadding            cellLeftPadding()           //view左边距
#define kCellRightPadding           cellRightPadding()          //view右边距

//subview边距
#define kCellTitleBottomPaddingToInfo                   cellTitleBottomPaddingToInfo()      //titleLabel与infoBar的间距
#define kCellTitleRightPaddingToPic                     8.f                                 //titleLabel与右图的间距
#define kCellInfoBarTopPadding                          cellInfoBarTopPadding()             //infoBar与pic的间距
#define kCellGroupPicTopPadding                         cellGroupPicTopPadding()            //多图上边距
#define KCellLoopPicInnerPadding                        10.f                                //轮播图图片间距
#define kCellTypeLabelInnerPadding                      cellTypeLabelInnerPadding()         //类型标签内部间距
#define kCellTypelabelRightPaddingToInfoLabel           5.f                                 //类型标签与内容的间距
#define kCellUninterestedButtonRightPadding             cellUninterestedButtonRightPadding()//不喜欢按钮与右小图的间距
#define kCellAbstractVerticalPadding                    14.f                                //摘要垂直边距
#define kCellCommentTopPadding                          14.f//cellCommentTopPadding()             //评论上边距
#define kCellCommentViewVerticalPadding                 0//cellCommentViewVerticalPadding()    //评论框垂直边距
#define kCellCommentViewHorizontalPadding               0//cellCommentViewHorizontalPadding()  //评论框水平边距
#define kCellCommentViewInsidePadding                   0//8.f                                 //评论框内部间距
#define kCellEntityWordTopPadding                       cellEntityWordTopPadding()          //实体词上边距
#define kCellEntityWordViewVerticalPadding              cellEntityWordViewVerticalPadding() //实体词垂直边距
#define kCellEntityWordViewLeftPadding                  cellEntityWordViewLeftPadding()     //实体词左边距
#define kCellEntityWordViewHeartButtonHorizontalPadding 16.f                                //实体词关心水平边距
#define kCellEntityWordViewHeartButtonInsidePadding     6.f                                 //实体词关心内部间距(红心与关心字样间距)
#define kCellEntityWordViewRelatedButtonRightPadding    15.f                                //实体词关联button(右箭头)右边距
#define kCellPicLabelRightPadding                       4.f                                 //picLabel右间距
#define kCellPicLabelBottomPadding                      4.f                                 //picLabel下间距
#define kCellPicLabelHorizontalPadding                  6.f                                 //picLabel水平间距
#define kCellPicLabelPlayAndTimePadding                 2.f                                 //picLabel播放与时间之间的间距

//titleLabel设置
#define kCellTitleLabelMaxLine         2                       //titleLabel最大行数
#define kCellRightPicTitleLabelMaxLine 3                       //右小图titleLabel最大行数
#define kCellTitleLineHeight           cellTitleLineHeight()   //titleLabel行高
#define kCellTitleLabelFontSize        cellTitleLabelFontSize()//titleLabel字体大小
#define kCellTitleLabelFont            [UIFont boldSystemFontOfSize:kCellTitleLabelFontSize]//titleLabel字体

#define kCellTitleLabelTextColor       kColorText1             //titleLabel字体颜色
//问答的为14号字
#define kCellWenDaAbstractViewLineHeight cellWenDaAbstractViewLineHeight()//摘要行高
#define kCellWenDaAbstractViewFontSize   cellWenDaAbstractViewFontSize()  //摘要字体大小

//infoBar设置
#define kCellSourceImageViewSide      16
#define kCellInfoBarHeight            cellInfoBarHeight()    //infoBar高度
#define kCellTypeLabelWidth           15.f                   //类型标签宽度(单字)
#define kCellTypeLabelWidthTwo        26.f                   //类型标签宽度2(双字)
#define kCellTypeLabelHeight          ( [TTDeviceHelper isPadDevice]? 18 : 14 )                  //类型标签高度
#define kCellTypeLabelFontSize        cellTypeLabelFontSize()//类型标签字体大小
#define kCellTypeLabelCornerRadius    3.f                    //类型标签圆角半径
#define kCellInfoLabelFontSize        cellInfoLabelFontSize()//内容字体大小
#define kCellInfoLabelTextColor       kColorText3            //内容字体颜色
#define kCellUninterestedButtonWidth  17.f                   //不喜欢按钮宽度
#define kCellUninterestedButtonHeight 12.f                   //不喜欢按钮高度
#define KCellADLocationIconWidth      9.f                    //广告位置icon宽度
#define KCellADLocationIconHeight     12.f                    //广告位置icon高度

#define kCellTypeLabelTextRed  kColorText4//类型标签红色字
#define kCellTypeLabelLineRed  kColorLine4//类型标签红色线
#define kCellTypeLabelTextBlue kColorText6//类型标签蓝色字
#define kCellTypeLabelLineBlue kColorLine5//类型标签蓝色线
#define kCellTypeLabelTextGrey kColorText3//类型标签灰色字
#define kCellTypeLabelLineGrey kColorLine7//类型标签灰色线

//图集设置
#define kCellGroupPicPadding         cellGroupPicPadding()//多图之间的间距
#define kCellGroupPicBorderColor     kColorLine1          //多图描边颜色
#define kCellGroupPicBackgroundColor kColorBackground2    //多图背景颜色

//摘要设置
#define kCellAbstractViewLineHeight cellAbstractViewLineHeight()//摘要行高
#define kCellAbstractViewFontSize   cellAbstractViewFontSize()  //摘要字体大小
#define kCellAbstractViewTextColor  kColorText3                 //摘要字体颜色

//评论框设置
#define kCellCommentViewMaxLine         3                          //评论框最大行数
#define kCellCommentViewBackgroundColor kColorBackground4          //评论框背景颜色
#define kCellCommentViewBorderColor     kColorLine1                //实体词描边颜色
#define kCellCommentViewLineHeight      cellCommentViewLineHeight()//评论框行高
#define kCellCommentViewFontSize        cellCommentViewFontSize()  //评论框字体大小
#define kCellCommentViewTextColor       kColorText2                //评论框内容字体颜色
#define kCellCommentViewUserTextColor   kColorText5                //评论框用户字体颜色

//实体词设置
#define kCellSixteenWordFontSize                        cellSixteenWordFontSize() //16号字设置特大中小
#define kCellEntityWordViewHeight                       cellEntityWordViewHeight()  //实体词高度
#define kCellEntityWordViewBackgroundColor              kColorBackground3           //实体词背景颜色
#define kCellEntityWordViewBorderColor                  kColorLine1                 //实体词描边颜色
#define kCellEntityWordViewFontSize                     cellEntityWordViewFontSize()//实体词字体大小
#define kCellEntityWordViewTextColor                    kColorText1                 //实体词字体颜色
#define kCellEntityWordViewHighlightTextColor           kColorText5                 //实体词高亮字体颜色
#define kCellEntityWordViewHeartButtonTextColor         kColorText3                 //实体词关心字体颜色
#define kCellEntityWordViewHeartButtonSelectedTextColor kColorText4                 //实体词关心选中字体颜色
#define kCellEntityWordViewSeparatorLineColor           kColorLine10                //实体词分割线颜色

//隔断线设置
#define kCellBottomLineBackgroundColor kColorBackground3//隔断面颜色
#define kCellBottomLineColor           kColorLine1      //隔断线颜色
#define kCellBottomLineHeight          10.f             //隔断线高度

//其他设置
#define kCellPicLabelWidth           44.f                     //picLabel正常宽度
#define kCellPicLabelHeight          20.f                     //picLabel固定高度
#define kCellPicLabelCornerRadius    10.f                     //picLabel圆角半径
#define kCellPicLabelBackgroundColor kColorBackground15       //picLabel背景色
#define kCellPicLabelFontSize        10.f                     //picLabel字体大小
#define kCellPicLabelTextColor       kColorText12             //picLabel字体颜色
#define kCellPicIconViewWidth        6.f                      //icon的宽度
#define kCellPicIconViewHeight       8.f                      //icon的高度

#define kChannelFontSize             channelFontSize()        //未选中频道字体大小
#define kChannelSelectedFontSize     channelSelectedFontSize()//选中频道字体大小

#define kCellAbstractViewCorrect cellAbstractViewCorrect()//摘要修正
#define kCellCommentViewCorrect  cellCommentViewCorrect() //评论修正

#define kCellADInfoBgViewHeight     48.f                //广告栏高度

//view边距
extern CGFloat cellTopPadding();
extern CGFloat cellTopPaddingWithRightPic();
extern CGFloat cellBottomPadding();
extern CGFloat cellBottomPaddingWithPic();
extern CGFloat cellLeftPadding();
extern CGFloat cellRightPadding();
//subview边距
extern CGFloat cellTitleBottomPaddingToInfo();
extern CGFloat cellInfoBarTopPadding();
extern CGFloat cellGroupPicTopPadding();
extern CGFloat cellTypeLabelInnerPadding();
extern CGFloat cellUninterestedButtonRightPadding();
extern CGFloat cellCommentTopPadding();
extern CGFloat cellCommentViewVerticalPadding();
extern CGFloat cellCommentViewHorizontalPadding();
extern CGFloat cellEntityWordTopPadding();
extern CGFloat cellEntityWordViewVerticalPadding();
extern CGFloat cellEntityWordViewLeftPadding();
//titleLabel设置
extern CGFloat cellTitleLineHeight();
extern CGFloat cellTitleLabelFontSize();
//infoBar设置
extern CGFloat cellInfoBarHeight();
extern CGFloat cellTypeLabelFontSize();
extern CGFloat cellInfoLabelFontSize();
//摘要设置
extern CGFloat cellAbstractViewLineHeight();
extern CGFloat cellAbstractViewFontSize();
extern CGFloat cellWenDaAbstractViewLineHeight();
extern CGFloat cellWenDaAbstractViewFontSize();
//评论框设置
extern CGFloat cellCommentViewLineHeight();
extern CGFloat cellCommentViewFontSize();
//实体词设置
extern CGFloat cellEntityWordViewHeight();
extern CGFloat cellEntityWordViewFontSize();
//隔断线设置

//16号字体设置大中小
extern CGFloat cellSixteenWordFontSize();
//其他设置
extern CGFloat cellGroupPicPadding();
extern CGFloat channelFontSize();
extern CGFloat channelSelectedFontSize();

extern CGFloat cellAbstractViewCorrect();
extern CGFloat cellCommentViewCorrect();

#pragma mark - other
extern CGFloat cellPaddingY();

extern CGFloat cellInfoLabelFontSize();
extern BOOL    shouldShowInfoBar(CGFloat cellWidth);


//extern CGFloat cellGroupPicPaddingX();
//extern CGFloat cellGroupPicPaddingY();
extern CGFloat cellRightPicWidth(CGFloat cellWidth);
extern CGFloat cellRightPicHeight(CGFloat cellWidth);
extern CGFloat cellRightPicTop();
extern CGFloat cellPureTitleMinHeight1Line();
extern CGFloat cellPureTitleMinHeight2Line();
extern CGFloat prefferedCellPureTitleHeightWithHeight(CGFloat height);

#define kCellInfoViewFontSize infoViewFontSize()
extern CGFloat infoViewFontSize();
#endif
