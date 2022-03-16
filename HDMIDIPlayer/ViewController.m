//
//  ViewController.m
//  HDMIDIPlayer
//
//  Created by denglibing on 2022/3/16.
//

#import "ViewController.h"

#import <MIKMIDI/MIKMIDI.h>

#import "HDModulator.h"

typedef NS_ENUM(NSInteger, HDMidiPlayMode) {
    HDMidiPlayModeMain = 0,
    HDMidiPlayModeMinor,
    HDMidiPlayModeAll,
};

@interface ViewController ()

@property (nonatomic, strong) MIKMIDISynthesizer *synthesizer;

@property (nonatomic, strong) HDModulator *modulator;

@property (nonatomic, assign) HDMidiPlayMode playMode;
@property (nonatomic, assign) BOOL isPlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _modulator = [HDModulator loadPlist:@"bjehp"];
    [_modulator logModulator];
    
    _isPlay = NO;
}

- (MIKMIDISynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[MIKMIDISynthesizer alloc] initWithError:nil];
        NSURL *soundfont = [[NSBundle mainBundle] URLForResource:@"Grand Piano" withExtension:@"sf2"];
        NSError *error = nil;
        if (![_synthesizer loadSoundfontFromFileAtURL:soundfont error:&error]) {
            NSLog(@"Error loading soundfont for synthesizer. Sound will be degraded. %@", error);
        }
    }
    return _synthesizer;
}


- (IBAction)changeMode:(UISegmentedControl *)sender {
    _playMode = sender.selectedSegmentIndex;
}

- (IBAction)playMidiPlay:(id)sender {
    if (_isPlay) {
        _isPlay = NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isPlay = YES;
        
        if (self.playMode == HDMidiPlayModeAll) {
            [self playIndex:0];
            [self playMinorIndex:0];
        }
        else if (self.playMode == HDMidiPlayModeMain) {
            [self playIndex:0];
        }
        else if (self.playMode == HDMidiPlayModeMinor) {
            [self playMinorIndex:0];
        }
    });
}

- (IBAction)stopMidiPlay:(id)sender {
    _isPlay = NO;
}

- (void)playIndex:(NSInteger)index {
    if (!_isPlay) {
        return;
    }
    if (_modulator.combineModulators.count <= index) {
//        [self playIndex:0];
        return;
    }
    
    HDModulatorItem *item = _modulator.combineModulators[index];
    NSInteger midiModulator = item.midiModulator;
    NSLog(@"七音阶（主）：%ld MIDI音阶：%ld 下一拍时间间隔：%0.2f", item.modulator, midiModulator, item.interval);
    if (midiModulator != -1000) {
        UInt8 note = 60 + midiModulator;
        MIKMIDINoteOnCommand *noteOn = [MIKMIDINoteOnCommand noteOnCommandWithNote:note velocity:127 channel:0 timestamp:[NSDate date]];
        [self.synthesizer handleMIDIMessages:@[noteOn]];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(item.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playIndex:index+1];
    });
}

- (void)playMinorIndex:(NSInteger)index {
    if (!_isPlay) {
        return;
    }
    
    if (_modulator.combineMinorModulators.count <= index) {
//        [self playMinorIndex:0];
        return;
    }
    
    HDModulatorItem *item = _modulator.combineMinorModulators[index];
    NSInteger midiMinorModulator = item.midiMinorModulator;
    NSLog(@"七音阶（副）：%ld MIDI音阶：%ld 下一拍时间间隔：%0.2f", item.minorModulator, midiMinorModulator, item.interval);
    if (midiMinorModulator != -1000) {
        UInt8 note = 60 + midiMinorModulator;
        MIKMIDINoteOnCommand *noteOn = [MIKMIDINoteOnCommand noteOnCommandWithNote:note velocity:127 channel:1 timestamp:[NSDate date]];
        [self.synthesizer handleMIDIMessages:@[noteOn]];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(item.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playMinorIndex:index+1];
    });
}


@end
