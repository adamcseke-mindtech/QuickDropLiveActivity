import React from 'react';
import { NativeModules, Vibration } from 'react-native';
import BackgroundTimer from 'react-native-background-timer';

const { QuickDropWidgetModule } = NativeModules;

const useTimer = () => {
    const [elapsedTimeInMs, setElapsedTimeInMs] = React.useState(0);
    const [isPlaying, setIsPlaying] = React.useState(false);
    const startDate = React.useRef<number | null>(null);
    const endDate = React.useRef<number | null>(null);
    const lastUpdatedMinute = React.useRef<number | null>(null);
    const hasTriggeredHalfMinuteLeft = React.useRef<boolean>(false);
    const hasTriggeredTenSecondsLeft = React.useRef<boolean>(false);
    const hasTimerEnded = React.useRef<boolean>(false);

    const totalDuration = 70;

    const play = () => {
        if (isPlaying) return;
        setIsPlaying(true);

        const now = Date.now();
        startDate.current = now;
        endDate.current = now + totalDuration * 1000;

        const initialMinutesLeft = Math.ceil(totalDuration / 60);
        QuickDropWidgetModule.startLiveActivity(startDate.current / 1000, endDate.current / 1000, initialMinutesLeft)
        QuickDropWidgetModule.updateActivityState(initialMinutesLeft, false);
        hasTriggeredTenSecondsLeft.current = false
        lastUpdatedMinute.current = initialMinutesLeft;

        BackgroundTimer.runBackgroundTimer(() => {
            const now = Date.now();
            let timeLeftInSeconds = Math.round(((endDate.current ?? now) - now) / 1000);
            timeLeftInSeconds = Math.max(0, timeLeftInSeconds);
            const minutesLeft = Math.ceil(timeLeftInSeconds / 60);

            setElapsedTimeInMs(timeLeftInSeconds > 0 ? totalDuration * 1000 - timeLeftInSeconds * 1000 : 0);

            if (lastUpdatedMinute.current !== minutesLeft) {
                QuickDropWidgetModule.updateActivityState(minutesLeft, false);
                lastUpdatedMinute.current = minutesLeft;
            }

            if (timeLeftInSeconds <= 30 && timeLeftInSeconds > 0 && !hasTriggeredHalfMinuteLeft.current) {
                hasTriggeredHalfMinuteLeft.current = true;
                QuickDropWidgetModule.updateActivityState(minutesLeft, true);
            } else if (timeLeftInSeconds > 30) {
                hasTriggeredHalfMinuteLeft.current = false;
                QuickDropWidgetModule.updateActivityState(minutesLeft, false);
            } else if (timeLeftInSeconds <= 10 && !hasTriggeredTenSecondsLeft.current) {
                hasTriggeredTenSecondsLeft.current = true
                Vibration.vibrate(500);
                QuickDropWidgetModule.setTenSecondsLeft(true)
            }

            if (timeLeftInSeconds === 0) {
                if (!hasTimerEnded.current) {
                    hasTimerEnded.current = true;
                    QuickDropWidgetModule.updateActivityState(minutesLeft, false);
                    BackgroundTimer.stopBackgroundTimer();
                    QuickDropWidgetModule.timerHasEnded(true);
                } else {
                    BackgroundTimer.stopBackgroundTimer();
                }
            }
        }, 1000);

        BackgroundTimer.stopBackgroundTimer();
    };

    React.useEffect(() => {
        return () => {
            if (isPlaying) {
                BackgroundTimer.stopBackgroundTimer();
            }
        };
    }, [isPlaying]);

    const reset = () => {
        BackgroundTimer.stopBackgroundTimer();
        setIsPlaying(false);
        setElapsedTimeInMs(0);
        startDate.current = null;
        endDate.current = null;
        lastUpdatedMinute.current = null;
        hasTriggeredHalfMinuteLeft.current = false;
        hasTimerEnded.current = false;
        QuickDropWidgetModule.stopLiveActivity();
    };

    const timeLeft = totalDuration - elapsedTimeInMs / 1000;
    const formattedValue = `${Math.floor(timeLeft / 60)}:${`0${Math.floor(timeLeft % 60)}`.slice(-2)}`;

    return { play, reset, value: formattedValue, isPlaying };
};

export default useTimer;
