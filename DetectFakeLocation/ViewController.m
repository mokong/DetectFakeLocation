//
//  ViewController.m
//  ForFakeLocationDetect
//
//  Created by MorganWangon 2021/8/6.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Masonry/Masonry.h>
#import "MWFakeLocationDetectUtil.h"
#import "CLLocationManager+DetectFakeLocation.h"

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIButton *locateButton;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupResultLabel];
    [self setupLocateButton];
    [self setupLocationManager];
}

#pragma mark - init
- (void)setupResultLabel {
    if (!_resultLabel) {
        _resultLabel = [UILabel new];
        _resultLabel.font = [UIFont systemFontOfSize:16.0];
        _resultLabel.textColor = [UIColor orangeColor];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self.view addSubview:_resultLabel];
    
    [_resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).inset(80.0);
    }];
}

- (void)setupLocateButton {
    if (!_locateButton) {
        _locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locateButton setTitle:@"定  位" forState:UIControlStateNormal];
        [_locateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_locateButton addTarget:self
                          action:@selector(locateBtnTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_locateButton];
    
    [_locateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(64.0);
        make.top.equalTo(self.resultLabel.mas_bottom).inset(42.0);
    }];
}

- (void)setupLocationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    _locationManager.delegate = self;
    [self requestLocationAuth];
}

- (void)requestLocationAuth {
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - utils


#pragma mark - action
- (void)locateBtnTapped:(UIButton *)sender {
    _resultLabel.text = @"定位检测...";

    [self.locationManager startUpdatingLocation];
 
    [MWFakeLocationDetectUtil util].resultCallback = ^(BOOL isSuspecious) {
        NSString *text = @"正常定位";
        if (isSuspecious) {
            text = @"疑似虚拟位置";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultLabel.text = text;
        });
    };
}

#pragma mark - other

#pragma mark - delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
}

@end
