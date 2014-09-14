//
//  MyoRoomViewController.m
//  MyoRoom
//
//  Created by Yuxuan Chen on 9/13/14.
//  Copyright (c) 2014 Yuxuan Chen. All rights reserved.
//

#import "Constants.h"
#import "MyoRoomViewController.h"
#import <MyoKit/MyoKit.h>
#import "BOXDevice.h"

@interface MyoRoomViewController () <BOXDeviceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *myoIsConnected;
@property (weak, nonatomic) IBOutlet UILabel *jamboxIsConnected;
@property (weak, nonatomic) IBOutlet UIButton *jamboxSetDirButton;
@property (weak, nonatomic) IBOutlet UILabel *lightIsConnected;
@property (weak, nonatomic) IBOutlet UIButton *lightSetDirButton;
@property (weak, nonatomic) IBOutlet UILabel *jamboxLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
- (IBAction)didClickToPairMyo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *myoPairButton;
@property (strong, nonatomic) TLMPose *currentPose;
@property (weak, nonatomic) IBOutlet UILabel *gestureTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (nonatomic, strong) UIAlertView *authAlert;
@property (nonatomic, strong) BOXDevice *jambox;
@property (nonatomic, strong) TLMEulerAngles *currentAngle;
@property (nonatomic, strong) NSMutableArray *devices;
- (IBAction)setJamboxDirection:(id)sender;

@property double jamboxYaw;
@property double jamboxPitch;
@property double jamboxRoll;

@end

@implementation MyoRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // Set the color of the navigation bar
    [self.navigationController.navigationBar setBackgroundColor:UIColorFromRGB(ORANGE_YELLOW)];
    
    // Hide the jambox and light settings
    self.jamboxIsConnected.hidden = YES;
    self.jamboxLabel.hidden = YES;
    self.jamboxSetDirButton.hidden = YES;
    
    self.lightIsConnected.hidden = YES;
    self.lightLabel.hidden = YES;
    self.lightSetDirButton.hidden = YES;
    
    self.gestureTitleLabel.hidden = YES;
    self.testLabel.hidden = YES;
    
    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    
    // Posted when a new pose is available from a TLMMyo
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
     
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
        __weak typeof(self) wself = self;
        if (wself.jambox != NULL) return;
        [BOXDevice findDevices:^(BOXDevice *device, BOOL *stop, NSError *error) {
            NSLog(@"%@", device.name);
            if ([device.name isEqualToString:@"v1.3"]) {
                wself.jambox = device;
                [wself.view setNeedsDisplay];
            }
            *stop = YES;
        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter Methods

- (void)didConnectDevice:(NSNotification *)notification {
    // Set the connect status of Myo to "connected"
    self.myoIsConnected.text = @STATUS_CONNECTED;
    self.myoIsConnected.textColor = [UIColor greenColor];
    [self.myoPairButton setTitle:@BUTTON_MYO_CONNECTED forState:UIControlStateNormal];
    
    // Show the jambox and light
    self.jamboxIsConnected.hidden = NO;
    self.jamboxLabel.hidden = NO;
    
    self.lightIsConnected.hidden = NO;
    self.lightLabel.hidden = NO;
    
    self.gestureTitleLabel.hidden = NO;
    self.testLabel.hidden = NO;
    
    // Show the status of the jambox
    if (self.jambox != NULL) {
        self.jamboxIsConnected.text = @STATUS_CONNECTED;
        self.jamboxIsConnected.textColor = [UIColor greenColor];
        self.jamboxSetDirButton.hidden = NO;
    }
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    self.myoIsConnected.text = @STATUS_UNCONNECTED;
    self.myoIsConnected.textColor = [UIColor redColor];
    [self.myoPairButton setTitle:@BUTTON_MYO_UNCONNECTED forState:UIControlStateNormal];
    
    // Hide the jambox and light settings
    self.jamboxIsConnected.hidden = YES;
    self.jamboxLabel.hidden = YES;
    
    self.lightIsConnected.hidden = YES;
    self.lightLabel.hidden = YES;
    
    self.gestureTitleLabel.hidden = YES;
    self.testLabel.hidden = YES;
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    // Create Euler angles from the quaternion of the orientation.
    self.currentAngle = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    if (!self.jamboxYaw) return;
    
    if (fabs(self.jamboxYaw - self.currentAngle.yaw.radians) < 0.1) {
            NSLog(@"Pointing at the jambox");
        }
    
    NSLog(@"Not pointing");
    
    //self.testLabel.text = [NSString stringWithFormat:@"Yaw:%3.4lf Pitch:%3.4lf Roll:%3.4lf",
      //  angles.yaw.radians, angles.pitch.radians, angles.roll.radians];
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
            //self.testLabel.text = @"None";
            //self.testLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            break;
        case TLMPoseTypeFist:
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            //self.testLabel.text = @"Fist";
            //self.testLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            break;
        case TLMPoseTypeWaveIn:
            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
            //self.testLabel.text = @"Wave In";
            //self.testLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            break;
        case TLMPoseTypeWaveOut:
            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
            //self.testLabel.text = @"Wave Out";
            //self.testLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            break;
        case TLMPoseTypeFingersSpread:
            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
            //self.testLabel.text = @"Fingers Spread";
            //self.testLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            break;
        case TLMPoseTypeThumbToPinky:
            // Changes helloLabel's font to Superclarendon when the user is in a twist in pose.
            //self.testLabel.text = @"Thumb to Pinky";
            //self.testLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            break;
    }
}


- (IBAction)didClickToPairMyo:(id)sender {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    [controller.navigationBar setBackgroundColor:UIColorFromRGB(ORANGE_YELLOW)];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark BOXDeviceDelegate

- (void)boxDeviceRequiresAuthentication:(BOXDevice *)device
{
    self.authAlert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:@"Please press the round button to authenticate"
                              delegate:nil
                     cancelButtonTitle:nil
                     otherButtonTitles:nil];
    [self.authAlert show];
}

- (void)boxDevice:(BOXDevice *)device didDisconnectWithError:(NSError *)error
{
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Disconnected"
                                    message:[NSString stringWithFormat:@"Disconnected from %@ ", device.name]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark Private

- (void)pulseButton:(UIButton *)button
{
    button.highlighted = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.highlighted = NO;
    });
}

- (IBAction)setJamboxDirection:(id)sender {
    self.jamboxYaw = self.currentAngle.yaw.radians;
    self.jamboxPitch = self.currentAngle.pitch.radians;
    self.jamboxRoll = self.currentAngle.roll.radians;
    NSLog(@"Y: %4.4lf; P: %4.4lf; R: %4.4lf", self.jamboxYaw, self.jamboxPitch, self.jamboxRoll);
    self.jamboxSetDirButton.titleLabel.text = @"Reset";
}
@end
