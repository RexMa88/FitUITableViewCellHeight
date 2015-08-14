//
//  XHMJ_FooterMarkNoPictureCell.h
//  chinapainting
//
//  Created by 新华视讯 on 15/8/4.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum replyNoPictureStyle{
    footMarkReplyNoPictureStyleJustWord,
    footMarkReplyNoPictureStyleJustPraise,
    footMarkReplyNoPictureStyleWordAndPraise,
    footMarkReplyNoPictureStyleNone
}footMarkNoPictureReplyStyle;

@class XHMJ_FootMarkModel;

@interface XHMJ_FooterMarkNoPictureCell : UITableViewCell<UITableViewDelegate, UITableViewDataSource>

//足迹的Model
@property (strong, nonatomic) XHMJ_FootMarkModel *model;
//评论和点赞手势
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UITapGestureRecognizer *praiseGesture;
@property (strong, nonatomic) UITapGestureRecognizer *commentGesture;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContentLableHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;//评论和点赞图片
//删除按钮
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

//评论点赞栏
@property (weak, nonatomic) IBOutlet UIView *commentPraiseView;
@property (weak, nonatomic) IBOutlet UIImageView *praiseBtn;
@property (weak, nonatomic) IBOutlet UIImageView *commentBtn;

//评论以及点赞列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//判断评论种类(三种:只点赞、只评论、点赞和评论)
@property (assign, nonatomic) footMarkNoPictureReplyStyle replyStyle;
//tableView的高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

//计算点赞在UILabel中的高度
- (CGFloat)heightToPraiseWithArray:(NSArray *)praiseArr;
//删除方法
- (IBAction)deleteMethod:(UIButton *)sender;

@end
