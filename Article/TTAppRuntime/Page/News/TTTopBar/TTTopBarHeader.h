//
//  TTTopBarHeader.h
//  Article
//
//  Created by fengyadong on 2018/1/3.
//

#ifndef TTTopBarHeader_h
#define TTTopBarHeader_h

#define kTopSearchButtonHeight (![TTDeviceHelper isPadDevice] ? 0 : 0.f)
#define kSelectorViewHeight 44

#define kMineIconLeft 10
#define kMineIconW  28
#define kMineIconH  34
#define kMineIconRightGap 13
//搜索框在背景图上左边距
#define kSearchFieldLeft (kMineIconLeft + kMineIconW + kMineIconRightGap)
#define kSearchFieldExtendLeft 15
#define kSearchFieldExtendRight 15
#define kLogoSearchFieldLeft (kTopBarIconWidth + kLogoIconRight + kLogoIconLeft)
//搜索label在搜索框上的左边距
#define kSearchLabelLeft 32
#define kMineIconButtonH 44
#define kNavBarHeight 44

#define kLogoIconLeft 12
#define kLogoIconRight 12

#define kTopBarIconWidth 82
#define kTopBarIconHeight 21

#define kPublishIconH  34
#define kPublishIconW  28
#define kPublishLeftOffset  13
#define kPublishRightOffset  10

#endif /* TTTopBarHeader_h */
