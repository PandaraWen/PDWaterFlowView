//
//  PDWaterFlowView.h
//  PDWaterFlowView
//
//  Created by pandara on 13-9-30.
//  Copyright (c) 2013年 pandara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDWaterFlowViewCell.h"
#import "SRRefreshView.h"

struct WaterFlowCellInfo {
    CGRect cellFrame;
    int cellIndex;
};

@class PDWaterFlowView;

@protocol PDWaterFlowViewDelegate <NSObject>

@required
- (NSInteger)numberOfCellInWaterFlowView:(PDWaterFlowView *)waterFlowView;
- (NSInteger)numberOfColumnInWaterFlowView:(PDWaterFlowView *)waterFlowView;
- (CGFloat)waterFlowView:(PDWaterFlowView *)waterFlowView highForCellAtIndex:(NSInteger)cellIndex;
- (PDWaterFlowViewCell *)waterFlowView:(PDWaterFlowView *)waterFlowView cellForIndex:(NSInteger)cellIndex;

@optional
- (void)waterFlowView:(PDWaterFlowView *)waterFlowView didSelectCellAtIndex:(NSInteger)cellIndex;
- (void)waterFlowViewPullToRefresh:(PDWaterFlowView *)waterFlowView;
- (void)waterFlowViewLiftToLoadMore:(PDWaterFlowView *)waterFlowView;

@end

@interface PDWaterFlowView : UIView <UIScrollViewDelegate, PDWaterFlowViewCellDelegate, SRRefreshDelegate> {
    NSMutableArray *_columns;//存放每列的cell array
    NSMutableArray *_reuseQueue;
    NSMutableArray *_allCellInfos;//共column个元素，每个元素为该列的WaterFlowCellInfo array
                                //initWithFrame 中初始化  setData中被设置
    UIScrollView *_scrollView;
    NSInteger _columnNum;
    
    SRRefreshView *_slimeView;
    UIActivityIndicatorView *_juhuaView;
}

@property (strong, nonatomic) id <PDWaterFlowViewDelegate> delegate;

- (PDWaterFlowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)reuseID;
- (void)reloadData;
- (void)doneRefresh;
- (void)doneLoadMore;

@end
