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

@interface MyoRoomViewController ()

@property (weak, nonatomic) IBOutlet UILabel *myoIsConnected;
@property (weak, nonatomic) IBOutlet UILabel *jamboxIsConnected;
@property (weak, nonatomic) IBOutlet UIButton *jamboxSetDirButton;
@property (weak, nonatomic) IBOutlet UILabel *lightIsConnected;
@property (weak, nonatomic) IBOutlet UIButton *lightSetDirButton;
@property (weak, nonatomic) IBOutlet UILabel *jamboxLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
- (IBAction)didClickToPairMyo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *myoPairButton;

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
    // Posted whenever the user does a Sync Gesture, and the Myo is calibrated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeArm:)
                                                 name:TLMMyoDidReceiveArmRecognizedEventNotification
                                               object:nil];
    // Posted whenever Myo loses its calibration (when Myo is taken off, or moved enough on the user's arm)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoseArm:)
                                                 name:TLMMyoDidReceiveArmLostEventNotification
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
    self.jamboxSetDirButton.hidden = NO;
    
    self.lightIsConnected.hidden = NO;
    self.lightLabel.hidden = NO;
    self.lightSetDirButton.hidden = NO;
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    self.myoIsConnected.text = @STATUS_UNCONNECTED;
    self.myoIsConnected.textColor = [UIColor redColor];
    [self.myoPairButton setTitle:@BUTTON_MYO_UNCONNECTED forState:UIControlStateNormal];
    
    // Hide the jambox and light settings
    self.jamboxIsConnected.hidden = YES;
    self.jamboxLabel.hidden = YES;
    self.jamboxSetDirButton.hidden = YES;
    
    self.lightIsConnected.hidden = YES;
    self.lightLabel.hidden = YES;
    self.lightSetDirButton.hidden = YES;
}

- (void)didRecognizeArm:(NSNotification *)notification {
}

- (void)didLoseArm:(NSNotification *)notification {
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    // Next, we want to apply a rotation and perspective transformation based on the pitch, yaw, and roll.
    CATransform3D rotationAndPerspectiveTransform = CATransform3DConcat(CATransform3DConcat(CATransform3DRotate (CATransform3DIdentity, angles.pitch.radians, -1.0, 0.0, 0.0), CATransform3DRotate(CATransform3DIdentity, angles.yaw.radians, 0.0, 1.0, 0.0)), CATransform3DRotate(CATransform3DIdentity, angles.roll.radians, 0.0, 0.0, -1.0));
}

- (void)didReceivePoseChange:(NSNotification *)notification {
}


- (IBAction)didClickToPairMyo:(id)sender {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    [controller.navigationBar setBackgroundColor:UIColorFromRGB(ORANGE_YELLOW)];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
}
@end
