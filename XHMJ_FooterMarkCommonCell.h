//
//  XHMJ_FooterMarkCommonCell.h
//  chinapainting
//
//  Created by 新华视讯 on 15/8/4.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHMJ_FootMarkModel;

typedef enum replyStyle{
    footMarkReplyStyleJustWord,
    footMarkReplyStyleJustPraise,
    footMarkReplyStyleWordAndPraise,
    footMarkReplyStyleNone
}footMarkReplyStyle;

@interface XHMJ_FooterMarkCommonCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>

//设置model
@property (strong, nonatomic) XHMJ_FootMarkModel *model;
//设置三种手势（分别对应评论点赞图片、点赞图片、评论图片）
@property (strong, nonatomic) UITapGestureRecognizer *commentPraiseTapGesture;
@property (strong, nonatomic) UITapGestureRecognizer *praiseTapGesture;
@property (strong, nonatomic) UITapGestureRecognizer *commentTapGesture;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
//评论点赞视图
@property (weak, nonatomic) IBOutlet UIView *commentAndPraiseView;
@property (weak, nonatomic) IBOutlet UIImageView *praiseImg;
@property (weak, nonatomic) IBOutlet UIImageView *commentImg;
//评论列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//评论列表类型
@property (assign, nonatomic) footMarkReplyStyle replyStyle;
//删除按钮
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

//tableview的高度约束(根据Model动态变化高度)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;

//计算点赞在UILabel中的高度
- (CGFloat)heightToPraiseWithArray:(NSArray *)praiseArr;
//删除方法
- (IBAction)deleteMethod:(UIButton *)sender;


@end

