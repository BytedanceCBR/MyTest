//
//  FHUIAdaptation.h
//  FHHouseDetail
//
//  Created by liuyu on 2019/12/2.
//

#ifndef FHUIAdaptation_h
#define FHUIAdaptation_h
#define AdaptOffset(x)  [UIScreen mainScreen].bounds.size.width/375 *x
#define AdaptFont(x) [UIScreen mainScreen].bounds.size.width < 375 ? (x-2) : x
#endif /* FHUIAdaptation_h */
