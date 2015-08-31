//
//  XHMJ_FootmarkController.m
//  chinapainting
//
//  Created by RexMa on 15/8/3.
//  Copyright (c) 2015年 XinHuaTV. All rights reserved.
//

#import "XHMJ_FootmarkController.h"
#import "XHMJ_FootMarkDetailRequest.h"
#import "XHMJ_FooterMarkCommonCell.h"
#import "XHMJ_FooterMarkNoPictureCell.h"
#import "XHMJ_FootMarkModel.h"
#import "UIView+Extension.h"
#import "XHMJ_CommentView.h"
#import "XHMJ_FooterMarkReplyModel.h"
#import "XHMJ_FooterMarkCommentRequest.h"
#import "XHMJ_FooterMarkDeleteRequest.h"
#import "UIView+Extension.h"
#import "XHMJLoginViewController.h"
#import "XHMJ_FooterMarkDeleteCommentRequest.h"
#import "SendFooterMarkViewController.h"
#import "XHMJ_FootMarkPraiseRequest.h"
#import "XHMJ_FootMarkDePraiseRequest.h"
#import "XHMJ_FootMarkCheckComment.h"
#import "WorkDetailHeaderView.h"

#define tableViewBottomConstraint 9
#define deleteDynamicComment 0

//评论类型(评论还是回复)
typedef enum FootMarkCommentStyle {
    XHMJFootMarkCommentStyleNone,
    XHMJFootMarkCommentStyleReply,
    XHMJFootMarkCommentStyleComment
} XHMJFootMarkCommentStyle;

//删除评论类型
typedef enum FootMarkDeleteStyle{
    XHMJFootMarkDeleteStyleNone,
    XHMJFootMarkDeleteStyleNoPicture,
    XHMJFootMarkDeleteStyleCommon
}XHMJFootMarkDeleteStyle;

//点赞类型
typedef enum FootMarkPraiseStyle{
    XHMJFootMarkPraiseStyleNone,
    XHMJFootMarkPraiseStyleNoPicture,
    XHMJFootMarkPraiseStyleCommon
}XHMJFootMarkPraiseStyle;

typedef enum FootmarkDePraiseStyle{
    XHMJFootmarkDePraiseStyleNone,
    XHMJFootmarkDePraiseStyleNoPicture,
    XHMJFootmarkDePraiseStyleCommon
}XHMJFootmarkDePraiseStyle;

//cell种类
typedef enum FootMarkCellStyle{
    FootMarkCellStyleNone,
    FootMarkCellStyleNoPicture,
    FootMarkCellStyleCommon
}FootMarkCellStyle;

typedef enum FootMarkDeleteDynamicStyle{
    FootMarkDeleteDynamicStyleNone,
    FootMarkDeleteDynamicStyleNoPicture,
    FootMarkDeleteDynamicStyleCommon
}FootMarkDeleteDynamicStyle;

@interface XHMJ_FootmarkController ()<UITableViewDelegate,UITableViewDataSource,XHMJ_TableViewDelegate,UITextViewDelegate,XHMJ_CommentViewDelegate,UIScrollViewDelegate,XHMJ_FooterMarkCommentRequestDelegate,UIActionSheetDelegate,XHMJ_FooterMarkDeleteDynamicCommentDelegate,XHMJ_FooterMarkDynamicDeleteDelegate,XHMJ_FootMarkPraiseDelegate,XHMJ_FootMarkDePraiseDelegate,WorkDetailHeaderViewDelegate>

@property (strong, nonatomic) XHMJ_FootMarkRequest *footMarklistRequest;

@property (strong, nonatomic) XHMJ_FootMarkModel *commentModel;

@property (strong, nonatomic) XHMJ_FootMarkCommentModel *replyModel;//用来接收评论的Model

@property (strong, nonatomic) XHMJ_FooterMarkNoPictureCell *noPictureCell;//用来接收通知的cell

@property (strong, nonatomic) XHMJ_FooterMarkCommonCell *commonCell;//用来接收有图的cell

@property (strong, nonatomic) NSString *sendMessage;//发送内容

@property (strong, nonatomic) UIActionSheet *actionSheet;//删除已发评论

@property (strong, nonatomic) NSIndexPath *dealIndexPath;//操作获取的索引

@property (strong, nonatomic) WorkDetailHeaderView *photoDetailView;

@property (strong, nonatomic) NSMutableArray *photoArray;//图片数组

@property (strong, nonatomic) NSCache *heightCache;//高度缓存

@property (strong, nonatomic) NSCache *cellCache;

//增删改查策略
@property (assign, nonatomic) FootMarkCellStyle cellStyle;

@property (assign, nonatomic) XHMJFootMarkCommentStyle footmarkReplyStyle;

@property (assign, nonatomic) XHMJFootMarkDeleteStyle footmarkdeleteStyle;

@property (assign, nonatomic) XHMJFootMarkPraiseStyle footmarkPraiseStyle;

@property (assign, nonatomic) FootMarkDeleteDynamicStyle footmarkDeleteDynamicStyle;

@property (assign, nonatomic) XHMJFootmarkDePraiseStyle footmarkDePraiseStyle;

@end

@implementation XHMJ_FootmarkController{
    CGRect keyBoardFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"足迹";
    //评论栏
    self.commentView = [[XHMJ_CommentView alloc] initWithSendFrame:CGRectMake(0, kHeight, kWidth, 50)];
    self.commentView.commentDelegate = self;
    self.commentView.textView.delegate = self;
    [self setTableView];
    [self.view addSubview:self.commentView];
    [self initDeleteActionSheet];
    //初始化全局索引
    self.dealIndexPath = [[NSIndexPath alloc]init];
    //初始化图片数组
    self.photoArray = [[NSMutableArray alloc] init];
    //高度Cache初始化
    self.heightCache = [[NSCache alloc] init];
    //TableViewCell的缓存Cache
    self.cellCache = [[NSCache alloc] init];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.commentView.textView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //判断是否登录
    if (![[PersonInfo sharedPerson] isValidLogin]) {
        UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"GuideView" bundle:nil];
        XHMJLoginViewController *loginVC = [stroyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    //判断是否是自己的足迹
    if ([self.artistID integerValue] ==[[PersonInfo sharedPerson].userId integerValue]) {
        UIButton *footPrintBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        footPrintBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [footPrintBtn setTitle:@"足迹" forState:UIControlStateNormal];
        [footPrintBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [footPrintBtn addTarget:self action:@selector(SendArtistFootprints) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:footPrintBtn];
        self.navigationItem.rightBarButtonItem = rightBarItem;
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    //注册评论通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentViewAppear:)
                                                 name:@"commentViewAppear"
                                               object:nil];
    
    //注册回复通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentViewAppear:)
                                                 name:@"replyOtherPerson"
                                               object:nil];
    
    //点赞事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(praiseNotification:)
                                                 name:@"praiseFooterMark"
                                               object:nil];
    
    //删除动态事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteNotification:)
                                                 name:@"deleteDynamicNotification"
                                               object:nil];
    
    //删除动态评论事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteDynamicCommentNotification:)
                                                 name:@"deleteCommentNotification"
                                               object:nil];
    
    //点击相册事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photoCollectionViewClickNotification:)
                                                 name:@"photoCollectionViewClick"
                                               object:nil];
    
    [self registerKeyBoardNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --- 点击相册动态
- (void)photoCollectionViewClickNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[XHMJ_FooterMarkCommonCell class]]) {
        self.dealIndexPath = [notification.userInfo objectForKey:@"indexPath"];
        self.photoArray = [notification.userInfo objectForKey:@"picList"];
        self.photoDetailView = [[WorkDetailHeaderView alloc] initInFootMarkWithFrame:CGRectMake(0, 0, kWidth, kHeight) withScrollArray:[NSMutableArray arrayWithArray:self.photoArray]];
        self.photoDetailView.workDetailDelegate = self;
        [self.view addSubview:self.photoDetailView];
    }
}

#pragma mark --- WorkDetailHeaderViewDelegate

- (void)clickScrollViewAtIndex:(NSInteger)index{
    [self.photoDetailView removeFromSuperview];
    [self.photoArray removeAllObjects];
}

#pragma mark --- 删除动态评论事件

- (void)deleteDynamicCommentNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[XHMJ_FooterMarkNoPictureCell class]]) {
        self.cellStyle = FootMarkCellStyleNoPicture;
        self.footmarkdeleteStyle = XHMJFootMarkDeleteStyleNoPicture;
        self.replyModel = [[notification userInfo] objectForKey:@"commentModel"];
        self.dealIndexPath = [[notification userInfo] objectForKey:@"indexPath"];
        self.commentModel = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
    }else{
        self.cellStyle = FootMarkCellStyleCommon;
        self.footmarkdeleteStyle = XHMJFootMarkDeleteStyleCommon;
        self.replyModel = [[notification userInfo] objectForKey:@"commentModel"];
        self.dealIndexPath = [[notification userInfo] objectForKey:@"indexPath"];
        self.commentModel = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
    }
    [self.actionSheet showInView:self.view];
}

- (void)initDeleteActionSheet{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除本评论" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
}

- (void)deleteDynamicCommentWithDic:(NSDictionary *)dict{
    if ([dict[@"success"] integerValue] == [kSucessStr integerValue]) {
        [self.footMarklistRequest removeCommentWith:self.commentModel With:self.replyModel];
        [self calculateHeightInRow:self.dealIndexPath];
        NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
        [self.cellCache removeObjectForKey:cellKey];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[_dealIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == deleteDynamicComment) {
        XHMJ_FooterMarkDeleteCommentStatus *data = [[XHMJ_FooterMarkDeleteCommentStatus alloc] initWithCommentId:[NSString stringWithFormat:@"%ld",(long)self.replyModel.idIOS]];
        data.delegate = self;
        [data deleteDynamicCommentRequest];
    }
}

#pragma mark --- 点赞事件

- (void)praiseNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[XHMJ_FooterMarkNoPictureCell class]]) {
        BOOL isPraise = [[notification.userInfo objectForKey:@"isPraise"] boolValue];
        self.noPictureCell = [[notification userInfo] objectForKey:@"class"];
        self.dealIndexPath = [self.tableView indexPathForCell:self.noPictureCell];
        NSDictionary *dict = @{@"entityId":[NSNumber numberWithInteger:self.noPictureCell.model.idIOS]};
        if (isPraise) {
            self.footmarkPraiseStyle = XHMJFootMarkPraiseStyleNoPicture;
            XHMJ_FootMarkPraiseStatus *praiseData = [[XHMJ_FootMarkPraiseStatus alloc] initWithDic:dict];
            praiseData.delegate = self;
            [praiseData footMarkPraiseRequest];
        }else{
            self.footmarkDePraiseStyle = XHMJFootmarkDePraiseStyleNoPicture;
            XHMJ_FootMarkDePraiseStatus *dePraiseData = [[XHMJ_FootMarkDePraiseStatus alloc] initWithDic:dict];
            dePraiseData.delegate = self;
            [dePraiseData dePraiserequestStatus];
        }
    }else if ([notification.object isKindOfClass:[XHMJ_FooterMarkCommonCell class]]){
        BOOL isPraise = [[notification.userInfo objectForKey:@"isPraise"] boolValue];
        self.commonCell = [[notification userInfo] objectForKey:@"class"];
        self.dealIndexPath = [self.tableView indexPathForCell:self.commonCell];
        NSDictionary *dict = @{@"entityId":[NSNumber numberWithInteger:self.commonCell.model.idIOS]};
        if (isPraise) {
            self.footmarkPraiseStyle = XHMJFootMarkPraiseStyleCommon;
            XHMJ_FootMarkPraiseStatus *praiseData = [[XHMJ_FootMarkPraiseStatus alloc] initWithDic:dict];
            praiseData.delegate = self;
            [praiseData footMarkPraiseRequest];
        }else{
            self.footmarkDePraiseStyle = XHMJFootmarkDePraiseStyleCommon;
            XHMJ_FootMarkDePraiseStatus *dePraiseData = [[XHMJ_FootMarkDePraiseStatus alloc] initWithDic:dict];
            dePraiseData.delegate = self;
            [dePraiseData dePraiserequestStatus];
        }
    }
}

#pragma mark - XHMJ_FootMarkDePraiseDelegate

- (void)dePraiseStatus:(NSDictionary *)dict{
    if ([[dict objectForKey:@"success"] integerValue] == [kSucessStr integerValue]) {
//        XHMJ_FootMarkModel *model = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
        //无图足迹取消点赞
        if (self.footmarkDePraiseStyle == XHMJFootmarkDePraiseStyleNoPicture) {
            [self.noPictureCell.model.praiseList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XHMJ_FootMarkPraiseModel *praiseModel = obj;
                if ([praiseModel.userName isEqualToString:[PersonInfo sharedPerson].nickName]) {
                    [self.footMarklistRequest removePraiseWith:self.noPictureCell.model WithPraiseModel:praiseModel];
                }
            }];
            [self calculateHeightInRow:self.dealIndexPath];
            NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
            [self.cellCache removeObjectForKey:cellKey];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[self.dealIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }else if(self.footmarkDePraiseStyle == XHMJFootmarkDePraiseStyleCommon){
            [self.commonCell.model.praiseList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                XHMJ_FootMarkPraiseModel *praiseModel = obj;
                if ([praiseModel.userName isEqualToString:[PersonInfo sharedPerson].nickName]) {
                    [self.footMarklistRequest removePraiseWith:self.commonCell.model WithPraiseModel:praiseModel];
                }
            }];
            [self calculateHeightInRow:self.dealIndexPath];
            NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
            [self.cellCache removeObjectForKey:cellKey];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[self.dealIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - XHMJ_FootMarkPraiseDelegate

- (void)praiseStatus:(NSDictionary *)dict{
    if ([[dict objectForKey:@"success"] integerValue] == [kSucessStr integerValue]) {
        if (self.footmarkPraiseStyle == XHMJFootMarkPraiseStyleNoPicture) {
            NSDictionary *dict = @{@"creatDate":@"",
                                   @"entityId":[NSNumber numberWithInteger:self.noPictureCell.model.idIOS],
                                   @"id":@"",
                                   @"userId":[PersonInfo sharedPerson].userId,
                                   @"userName":[PersonInfo sharedPerson].nickName};
            XHMJ_FootMarkPraiseModel *praiseModel = [[XHMJ_FootMarkPraiseModel alloc] initWithDic:dict];
            [self.footMarklistRequest addPraiseWith:self.noPictureCell.model WithPraiseModel:praiseModel];
            [self calculateHeightInRow:self.dealIndexPath];
            NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
            [self.cellCache removeObjectForKey:cellKey];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[self.dealIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }else if(self.footmarkPraiseStyle == XHMJFootMarkPraiseStyleCommon){
            NSDictionary *dict = @{@"creatDate":@"",
                                   @"entityId":[NSNumber numberWithInteger:self.commonCell.model.idIOS],
                                   @"id":@"",
                                   @"userId":[PersonInfo sharedPerson].userId,
                                   @"userName":[PersonInfo sharedPerson].nickName};
            XHMJ_FootMarkPraiseModel *praiseModel = [[XHMJ_FootMarkPraiseModel alloc] initWithDic:dict];
            [self.footMarklistRequest addPraiseWith:self.commonCell.model WithPraiseModel:praiseModel];
            [self calculateHeightInRow:self.dealIndexPath];
            NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
            [self.cellCache removeObjectForKey:cellKey];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[self.dealIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark --- 注册键盘

- (void)registerKeyBoardNotification{
    //键盘出现事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark --- 键盘弹起与取消
- (void)commentViewAppear:(NSNotification *)notification{
    [self.commentView.textView becomeFirstResponder];
    if ([notification.name isEqualToString:@"replyOtherPerson"]) {
        self.footmarkReplyStyle = XHMJFootMarkCommentStyleReply;
        if ([notification.object isKindOfClass:[XHMJ_FooterMarkNoPictureCell class]]) {
            self.cellStyle = FootMarkCellStyleNoPicture;
            self.replyModel = [[notification userInfo] objectForKey:@"commentModel"];
            self.dealIndexPath = [[notification userInfo] objectForKey:@"indexPath"];
            self.commentModel = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
            self.commentView.textView.placeHolderLabel.text = self.replyModel.writerName;
        }else{
            self.cellStyle = FootMarkCellStyleCommon;
            self.replyModel = [[notification userInfo] objectForKey:@"commentModel"];
            self.dealIndexPath = [[notification userInfo] objectForKey:@"indexPath"];
            self.commentModel = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
            self.commentView.textView.placeHolderLabel.text = self.replyModel.writerName;
        }
    }else if ([notification.name isEqualToString:@"commentViewAppear"]){
        self.footmarkReplyStyle = XHMJFootMarkCommentStyleComment;
        if ([notification.object isKindOfClass:[XHMJ_FooterMarkNoPictureCell class]]) {
            self.cellStyle = FootMarkCellStyleNoPicture;
            self.dealIndexPath = [[notification userInfo] objectForKey:@"indexPath"];
            self.commentModel = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
        }else{
            self.cellStyle = FootMarkCellStyleCommon;
            self.dealIndexPath = [[notification userInfo] objectForKey:@"indexPath"];
            self.commentModel = [self.footMarklistRequest footMarkModelAtIndex:self.dealIndexPath.row];
        }
    }
}

- (void)cancelKeyboard:(UITapGestureRecognizer *)gesture{
    [self.commentView.textView resignFirstResponder];
}

#pragma mark --- 键盘通知方法

- (void)keyBoardWasShown:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    keyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat offsetHeight = keyBoardFrame.size.height + self.commentView.height + kNavAndStateBarHeight;
    
    [UIView animateWithDuration:duration animations:^{
        self.commentView.y = kHeight - offsetHeight;
    }];
}

- (void)keyBoardWillBeHidden:(NSNotification *)notification{
    [UIView animateWithDuration:0.2 animations:^{
        self.commentView.y = kHeight;
    }];
}

#pragma mark --- UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (TextValid(textView.text) && ([text isEqualToString:@"\n"])) {
        self.sendMessage = textView.text;
        [self.commentView.textView resignFirstResponder];
        self.commentView.textView.text = @"";
        if (self.footmarkReplyStyle == XHMJFootMarkCommentStyleReply) {
            
            NSDictionary *dic = @{@"content":self.sendMessage,
                                  @"writerName":[PersonInfo sharedPerson].nickName,
                                  @"dynamicId":[NSString stringWithFormat:@"%ld",(long)self.commentModel.idIOS],
                                  @"showPic":[PersonInfo sharedPerson].head_portraitUrl,
                                  @"parentId":[NSString stringWithFormat:@"%ld",(long)self.replyModel.idIOS]};
            XHMJ_FootMarkCommentData *data = [[XHMJ_FootMarkCommentData alloc] initWithDic:dic];
            data.delegate = self;
            [data footerMarkReplyInfoRequest];
        }else{
            NSDictionary *dic = @{@"content":textView.text,
                                  @"writerName":[PersonInfo sharedPerson].nickName,
                                  @"dynamicId":[NSString stringWithFormat:@"%ld",(long)self.commentModel.idIOS],
                                  @"showPic":[PersonInfo sharedPerson].head_portraitUrl,
                                  @"parentId":@"0"};
            XHMJ_FootMarkCommentData *data = [[XHMJ_FootMarkCommentData alloc] initWithDic:dic];
            data.delegate = self;
            [data footerMarkReplyInfoRequest];
        }
        return NO;
    }
    return YES;
}

#pragma mark --- XHMJ_XHMJ_FooterMarkCommentRequestDelegate

- (void)responseStatusWithDic:(NSDictionary *)dict {
    if ([dict[@"success"] intValue] == [kSucessStr intValue]) {
        NSDictionary *response = dict;
        //评论时发送信息
        if (self.footmarkReplyStyle == XHMJFootMarkCommentStyleComment) {
            NSDictionary *modelDict = @{@"commentDate":@"",
                                        @"context":self.sendMessage,
                                        @"deleteFlag":[NSNumber numberWithInteger:0],
                                        @"entityId":[NSNumber numberWithInteger:self.replyModel.entityId],
                                        @"flowId":[NSNumber numberWithInteger:0],
                                        @"flowName":@"",
                                        @"id":response[@"id"],
                                        @"parentId":[NSNumber numberWithInteger:0],
                                        @"pcontext":@"",
                                        @"pshowPic":@"",
                                        @"pwriterId":[NSNumber numberWithInteger:0],
                                        @"pwriterName":@"",
                                        @"readState":[NSNumber numberWithInteger:0],
                                        //                                       @"showPic":self.replyModel.showPic,
                                        @"showPic":[PersonInfo sharedPerson].head_portraitUrl,
                                        @"topNum":[NSNumber numberWithInteger:0],
                                        @"writerId":[PersonInfo sharedPerson].userId,
                                        //                                       @"writerId":[NSNumber numberWithInteger:self.replyModel.writerId],
                                        //                                       @"writerName":self.replyModel.writerName
                                        @"writerName":[PersonInfo sharedPerson].nickName
                                        };
            XHMJ_FootMarkCommentModel *model = [[XHMJ_FootMarkCommentModel alloc] initWithDic:modelDict];
            if (self.cellStyle == FootMarkCellStyleNoPicture) {
                [self.footMarklistRequest addCommentAtIndexPath:self.dealIndexPath WithCommentModel:model];
            }else{
                [self.footMarklistRequest addCommentAtIndexPath:self.dealIndexPath WithCommentModel:model];
            }
            [self calculateHeightInRow:self.dealIndexPath];
            NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
            [self.cellCache removeObjectForKey:cellKey];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[self.dealIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }else if(self.footmarkReplyStyle == XHMJFootMarkCommentStyleReply){
            NSDictionary *modelDict = @{@"commentDate":@"",
                                        @"context":self.sendMessage,
                                        @"deleteFlag":[NSNumber numberWithInteger:0],
                                        @"entityId":[NSNumber numberWithInteger:self.replyModel.entityId],
                                        @"flowId":[NSNumber numberWithInteger:0],
                                        @"flowName":@"",
                                        @"id":response[@"id"],
                                        @"parentId":[NSNumber numberWithInteger:0],
                                        @"pcontext":self.replyModel.context,
                                        @"pshowPic":self.replyModel.showPic,
                                        @"pwriterId":[NSNumber numberWithInteger:self.replyModel.writerId],
                                        @"pwriterName":self.replyModel.writerName,
                                        @"readState":[NSNumber numberWithInteger:0],
                                        //                                       @"showPic":self.replyModel.showPic,
                                        @"showPic":[PersonInfo sharedPerson].head_portraitUrl,
                                        @"topNum":[NSNumber numberWithInteger:0],
                                        @"writerId":[PersonInfo sharedPerson].userId,
                                        //                                       @"writerId":[NSNumber numberWithInteger:self.replyModel.writerId],
                                        //                                       @"writerName":self.replyModel.writerName
                                        @"writerName":[PersonInfo sharedPerson].nickName
                                        };
            XHMJ_FootMarkCommentModel *model = [[XHMJ_FootMarkCommentModel alloc] initWithDic:modelDict];
            if (self.cellStyle == FootMarkCellStyleNoPicture) {
                [self.footMarklistRequest addCommentAtIndexPath:self.dealIndexPath WithCommentModel:model];
            }else{
                [self.footMarklistRequest addCommentAtIndexPath:self.dealIndexPath WithCommentModel:model];
            }
            [self calculateHeightInRow:self.dealIndexPath];
            NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)self.dealIndexPath.section,(long)self.dealIndexPath.row];
            [self.cellCache removeObjectForKey:cellKey];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[_dealIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark --- XHMJ_CommentViewDelegate

- (void)sendComment:(NSString *)senderStr{
    if (TextValid(senderStr)) {
        self.sendMessage = self.commentView.textView.text;
        [self.commentView.textView resignFirstResponder];
        self.commentView.textView.text = @"";
        if (self.footmarkReplyStyle == XHMJFootMarkCommentStyleReply) {
            NSDictionary *dic = @{@"content":senderStr,
                                  @"writerName":[PersonInfo sharedPerson].nickName,
                                  @"dynamicId":[NSString stringWithFormat:@"%ld",(long)self.commentModel.idIOS],
                                  @"showPic":[PersonInfo sharedPerson].head_portraitUrl,
                                  @"parentId":[NSString stringWithFormat:@"%ld",(long)self.replyModel.idIOS]};
            XHMJ_FootMarkCommentData *data = [[XHMJ_FootMarkCommentData alloc] initWithDic:dic];
            data.delegate = self;
            [data footerMarkReplyInfoRequest];
        }else if(self.footmarkReplyStyle == XHMJFootMarkCommentStyleComment){
            NSDictionary *dic = @{@"content":senderStr,
                                  @"writerName":[PersonInfo sharedPerson].nickName,
                                  @"dynamicId":[NSString stringWithFormat:@"%ld",(long)self.commentModel.idIOS],
                                  @"showPic":[PersonInfo sharedPerson].head_portraitUrl,
                                  @"parentId":@"0"};
            XHMJ_FootMarkCommentData *data = [[XHMJ_FootMarkCommentData alloc] initWithDic:dic];
            data.delegate = self;
            [data footerMarkReplyInfoRequest];
        }
    }
    else{
        [self.commentView.textView resignFirstResponder];
    }
}

#pragma mark - 添加动态

- (void)SendArtistFootprints{
    SendFooterMarkViewController *sendFootMarkVC = [[SendFooterMarkViewController alloc] init];
    sendFootMarkVC.pushVCClass = self;
    
    [self.navigationController pushViewController:sendFootMarkVC animated:YES];
}

#pragma mark - 设置tableView

- (void)setTableView{
    self.tableView = [[XHMJ_TableView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight - kNavBarHeight - kStateBarHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableViewDelegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 1)];
    whiteLine.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = whiteLine;
    self.tableView.tableFooterView = whiteLine;
    [self.view addSubview:self.tableView];
    [self.tableView tableViewStartLoadingData];
}

#pragma mark - 下拉刷新

- (void)tableViewRefreshTaskWithTableView:(XHMJ_TableView *)tableView{
    self.footmarkPraiseStyle = XHMJFootMarkPraiseStyleNone;
    self.footmarkdeleteStyle = XHMJFootMarkDeleteStyleNone;
    self.footmarkReplyStyle = XHMJFootMarkCommentStyleNone;
    self.footmarkDePraiseStyle = XHMJFootmarkDePraiseStyleNone;
    self.cellStyle = FootMarkCellStyleNone;
    [self.heightCache removeAllObjects];
    [self.cellCache removeAllObjects];
    [self.tableView tableViewStartLoadingData];
}

#pragma mark - 上拉加载

- (void)tableViewLoadMoreTaskWithTableView:(XHMJ_TableView *)tableView{
    self.footmarkPraiseStyle = XHMJFootMarkPraiseStyleNone;
    self.footmarkdeleteStyle = XHMJFootMarkDeleteStyleNone;
    self.footmarkReplyStyle = XHMJFootMarkCommentStyleNone;
    self.footmarkDePraiseStyle = XHMJFootmarkDePraiseStyleNone;
    self.cellStyle = FootMarkCellStyleNone;
    [self.footMarklistRequest footMarkModelLoadMoreWithPage:self.tableView.page];
}

#pragma mark - XHMJ_TableViewDelegate

- (void)tableViewLoadingTaskWithTableView:(XHMJ_TableView *)tableView{
    self.footMarklistRequest = [[XHMJ_FootMarkRequest alloc] initWithartistID:self.artistID];
    [self.footMarklistRequest artistFootMarkInfoRequest];
}

- (void)tableViewCompleteTaskWithTableView:(XHMJ_TableView *)tableView{
    NSString *status = [self.footMarklistRequest footMarkStatus];
    [self stateJudgeTableView:self.tableView withState:status];
}

#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.footMarklistRequest footMarkListCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /**
     *  添加评论刷新
     */
    NSString *cellKey = [NSString stringWithFormat:@"cell-%ld-%ld",(long)indexPath.section,(long)indexPath.row];
    XHMJ_FootMarkModel *model = [self.footMarklistRequest footMarkModelAtIndex:indexPath.row];
    if (model.picList.count == 0) {
        XHMJ_FooterMarkNoPictureCell *cacheCell = [self.cellCache objectForKey:cellKey];
        if (!cacheCell) {
            XHMJ_FooterMarkNoPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterMarkNoPictureCell"];
            
            if (cell == nil) {
                cell = (XHMJ_FooterMarkNoPictureCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkTableViewCell" owner:nil options:nil] lastObject];
                if ([self.artistID integerValue] ==[[PersonInfo sharedPerson].userId integerValue]){
                    cell.deleteBtn.hidden = NO;
                }
            }
            if (self.dealIndexPath) {
                cell = (XHMJ_FooterMarkNoPictureCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkTableViewCell" owner:nil options:nil] lastObject];
                if ([self.artistID integerValue] ==[[PersonInfo sharedPerson].userId integerValue]){
                    cell.deleteBtn.hidden = NO;
                }
            }
            cell.indexPath = indexPath;
            cell.model = model;
            cell.nameLabel.text = self.artistName;
            [self.cellCache setObject:cell forKey:cellKey];
            
            return cell;
        }else{
            return cacheCell;
        }
    }else{
        XHMJ_FooterMarkCommonCell *cacheCell = [self.cellCache objectForKey:cellKey];
        
        if (!cacheCell) {
            XHMJ_FooterMarkCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterMarkCommonCell"];
            
            if (cell == nil) {
                cell = (XHMJ_FooterMarkCommonCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkCommonCell" owner:nil options:nil] lastObject];
                if ([self.artistID integerValue] ==[[PersonInfo sharedPerson].userId integerValue]){
                    cell.deleteBtn.hidden = NO;
                }
            }
            if (self.dealIndexPath) {
                cell = (XHMJ_FooterMarkCommonCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkCommonCell" owner:nil options:nil] lastObject];
                if ([self.artistID integerValue] ==[[PersonInfo sharedPerson].userId integerValue]){
                    cell.deleteBtn.hidden = NO;
                }
            }
            cell.indexPath = indexPath;
            cell.model = model;
            cell.nameLabel.text = self.artistName;
            [self.cellCache setObject:cell forKey:cellKey];
            
            return cell;
        }else{
            return cacheCell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self autoAdjustedCellHeightAtIndexPath:indexPath inTableView:self.tableView];
}

#pragma mark --- 自适应cellHeight

- (CGFloat)autoAdjustedCellHeightAtIndexPath:(NSIndexPath *)indexPath inTableView:(XHMJ_TableView *)tableView{
    NSString *heightKey = [NSString stringWithFormat:@"height-%ld-%ld",(long)indexPath.section,(long)indexPath.row];
    CGFloat cellHeight = [[self.heightCache objectForKey:heightKey] floatValue];
    
    if (cellHeight) {
        return cellHeight;
    }
    
    XHMJ_FootMarkModel *model = [self.footMarklistRequest footMarkModelAtIndex:indexPath.row];
    if (model.picList.count == 0) {
        XHMJ_FooterMarkNoPictureCell *cell = (XHMJ_FooterMarkNoPictureCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkTableViewCell" owner:nil options:nil] lastObject];
        cell.model = model;
        cell.nameLabel.text = self.artistName;
        
        //让cell进行layout
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        if (cell.replyStyle == footMarkReplyStyleJustPraise) {
            CGFloat height = CGRectGetMaxY(cell.tableView.frame) + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
            return height;
        }
        
        if (cell.replyStyle == footMarkReplyNoPictureStyleNone) {
            CGFloat height = cell.commentImageView.y + cell.commentImageView.height + cell.commentAndPraiseBottomConstraint.constant;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
            return height;
        }
        else{
            CGFloat height = CGRectGetMaxY(cell.tableView.frame) + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
            return height;
        }
    }else{
        XHMJ_FooterMarkCommonCell *cell = (XHMJ_FooterMarkCommonCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkCommonCell" owner:nil options:nil] lastObject];
        
        cell.model = model;
        cell.nameLabel.text = self.artistName;
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        if (cell.replyStyle == footMarkReplyStyleJustPraise) {
            CGFloat height = CGRectGetMaxY(cell.tableView.frame) + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
            return height;
        }
        
        if (cell.replyStyle == footMarkReplyNoPictureStyleNone) {
            CGFloat height = cell.commentImageView.y + cell.commentImageView.height + cell.commentViewBottomConstraint.constant;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
            return height;
        }else{
            CGFloat height = CGRectGetMaxY(cell.tableView.frame) + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
            return height;
        }
    }
}

- (void)calculateHeightInRow:(NSIndexPath *)indexPath{
    NSString *heightKey = [NSString stringWithFormat:@"height-%ld-%ld",(long)indexPath.section,(long)indexPath.row];
    
    XHMJ_FootMarkModel *model = [self.footMarklistRequest footMarkModelAtIndex:indexPath.row];
    if (model.picList.count == 0) {
        XHMJ_FooterMarkNoPictureCell *cell = (XHMJ_FooterMarkNoPictureCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkTableViewCell" owner:nil options:nil] lastObject];
        cell.model = model;
        cell.nameLabel.text = self.artistName;
        
        //让cell进行layout
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        if (cell.replyStyle == footMarkReplyStyleJustPraise) {
            CGFloat height = cell.tableView.y + cell.tableView.height + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
        }
        
        if (cell.replyStyle == footMarkReplyNoPictureStyleNone) {
            CGFloat height = cell.commentImageView.y + cell.commentImageView.height + cell.commentAndPraiseBottomConstraint.constant;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
        }
        
        else{
            CGFloat height = cell.tableView.y + cell.tableView.height + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
        }
    }else{
        XHMJ_FooterMarkCommonCell *cell = (XHMJ_FooterMarkCommonCell *)[[[NSBundle mainBundle] loadNibNamed:@"XHMJ_FooterMarkCommonCell" owner:nil options:nil] lastObject];
        
        cell.model = model;
        cell.nameLabel.text = self.artistName;
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        if (cell.replyStyle == footMarkReplyStyleJustPraise) {
            CGFloat height = cell.tableView.y + cell.tableView.height + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
        }
        
        if (cell.replyStyle == footMarkReplyNoPictureStyleNone) {
            CGFloat height = cell.commentImageView.y + cell.commentImageView.height + cell.commentViewBottomConstraint.constant;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
        }
        else{
            CGFloat height = cell.tableView.y + cell.tableView.height + 9;
            [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:heightKey];
        }
    }
}

#pragma mark --- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.commentView.textView resignFirstResponder];
}

#pragma mark --- 数据加载更多
- (void)stateJudgeTableView:(XHMJ_TableView *)tableView withState:(NSString *)state{
    if ([state isEqualToString:kSucessStr]) {
        [tableView removeTapAction];
        [tableView setHeaderRefreshData];
        [tableView setFooterLoadMoreData];
        [tableView reloadData];
    }else if ([state isEqualToString:kSucessEmptyStr]){
//        [self setEmptyViewWithStr:@"还没有发布任何资讯" tableView:tableView];
        [tableView removeTapAction];
        [tableView setLoadImageViewAndLabelWithText:kSucessEmptyMessage];
        [tableView setHeaderRefreshData];
        [tableView removeTableViewFooterRefresh];
        [tableView reloadData];
    }else{
        [tableView setLoadImageViewAndLabelWithText:kFailMessage imageName:kLogoImageName];
        [tableView setTapAction];
    }
}

-(void)setEmptyViewWithStr:(NSString*)str tableView:(id)tableView{
    UIImage *image = [UIImage imageNamed:@"none_works"];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((kWidth - image.size.width) / 2, (kWidth * 0.55 + kSegementHeight + 40) , image.size.width, image.size.height)];
    imageV.image = image;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageV.frame), kWidth, 30)];
    label.font = kFontType(14.0f);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = str;
    label.textColor = RGBColor(128, 128, 128);
    [tableView addSubview:imageV];
    [tableView addSubview:label];
    
    UILabel *detaillabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame), kWidth, 20)];
    detaillabel.text = @"请原谅啊，最近有点忙，您可以关注我，及时获取更新";
    detaillabel.textColor = RGBColor(128, 128, 128);
    detaillabel.textAlignment = NSTextAlignmentCenter;
    detaillabel.font = kFontType(12.0f);
    [tableView addSubview:detaillabel];
}

#pragma mark --- 删除动态信息

- (void)deleteNotification:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[XHMJ_FooterMarkNoPictureCell class]]) {
        self.footmarkDeleteDynamicStyle = FootMarkDeleteDynamicStyleNoPicture;
        NSString *dynamicId = [[notification userInfo] objectForKey:@"dynamicId"];
        self.noPictureCell = [[notification userInfo] objectForKey:@"class"];
        _dealIndexPath = [self.tableView indexPathForCell:self.noPictureCell];
        XHMJ_FooterMarkDeleteStatus *delete = [[XHMJ_FooterMarkDeleteStatus alloc] initWithId:dynamicId];
        delete.delegate = self;
        [self.footMarklistRequest removeFooterMarkModelAtIndex:self.dealIndexPath.row];
        [delete deleteDynamicInfoRequest];
    }else if ([notification.object isKindOfClass:[XHMJ_FooterMarkCommonCell class]]){
        self.footmarkDeleteDynamicStyle = FootMarkDeleteDynamicStyleCommon;
        NSString *dynamicId = [[notification userInfo] objectForKey:@"dynamicId"];
        self.commonCell = [[notification userInfo] objectForKey:@"class"];
        _dealIndexPath = [self.tableView indexPathForCell:self.commonCell];
        XHMJ_FooterMarkDeleteStatus *delete = [[XHMJ_FooterMarkDeleteStatus alloc] initWithId:dynamicId];
        delete.delegate = self;
        [self.footMarklistRequest removeFooterMarkModelAtIndex:self.dealIndexPath.row];
        [delete deleteDynamicInfoRequest];
    }
}

- (void)deleteDynamicStatusWithDic:(NSDictionary *)dict{
    if ([[dict objectForKey:@"success"] integerValue] == [kSucessStr integerValue]) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
