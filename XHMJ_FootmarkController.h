//
//  XHMJ_FootmarkController.h
//  chinapainting
//
//  Created by RexMa on 15/8/3.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import "BaseViewController.h"

@class XHMJ_CommentView;

@interface XHMJ_FootmarkController : BaseViewController

@property (strong, nonatomic) XHMJ_TableView *tableView;
@property (strong, nonatomic) NSString * artistID;
@property (strong, nonatomic) NSString *artistName;
//评论栏
@property (strong, nonatomic) XHMJ_CommentView *commentView;

- (CGFloat)autoAdjustedCellHeightAtIndexPath:(NSIndexPath *)indexPath inTableView:(XHMJ_TableView *)tableView;

@end
