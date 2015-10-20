//
//  LeSelectedController.h
//  Mistic
//

#import <UIKit/UIKit.h>
#import "GGDiscover.h"

@interface LeSelectedController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) UIView *shadowView;
@property (strong,nonatomic) UIView *listView;
//列表
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *foundPeripherals;
@property  (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UIActivityIndicatorView *connectionActivityIndicator;

-(void) changeViewToList;
-(void) connectedSuccess;
-(void) connectedFailure;
- (void) pushPersonInfo;
@end
