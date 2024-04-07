import React from 'react';
import { NativeModules } from 'react-native';
import BackgroundTimer from 'react-native-background-timer';

const { QuickDropWidgetModule } = NativeModules;

const useTimer = () => {
    const [elapsedTimeInMs, setElapsedTimeInMs] = React.useState(0);
    const [isPlaying, setIsPlaying] = React.useState(false);
    const startDate = React.useRef<number | null>(null);
    const endDate = React.useRef<number | null>(null);
    const lastUpdatedMinute = React.useRef<number | null>(null);

    const totalDuration = 45;

    const play = () => {
        if (isPlaying) return;
        setIsPlaying(true);

        const now = Date.now();
        if (!startDate.current || !endDate.current) {
            startDate.current = now;
            endDate.current = now + totalDuration * 1000;
        }

        QuickDropWidgetModule.setEndDate(endDate.current / 1000);
        QuickDropWidgetModule.startLiveActivity(startDate.current / 1000);

        const initialMinutesLeft = Math.ceil(totalDuration / 60);
        QuickDropWidgetModule.updateMinutesLeft(initialMinutesLeft);
        lastUpdatedMinute.current = initialMinutesLeft;

        BackgroundTimer.runBackgroundTimer(() => {
            const now = Date.now();
            let timeLeftInSeconds = Math.round(((endDate.current ?? now) - now) / 1000);
            timeLeftInSeconds = Math.max(0, timeLeftInSeconds);
            const minutesLeft = Math.ceil(timeLeftInSeconds / 60);

            setElapsedTimeInMs(timeLeftInSeconds > 0 ? totalDuration * 1000 - timeLeftInSeconds * 1000 : 0);

            if (lastUpdatedMinute.current !== minutesLeft) {
                QuickDropWidgetModule.updateMinutesLeft(minutesLeft);
                lastUpdatedMinute.current = minutesLeft;
            }

            if (timeLeftInSeconds <= 30 && timeLeftInSeconds > 0) {
                QuickDropWidgetModule.updateHalfMinuteLeft(true);
                QuickDropWidgetModule.updateTimeLeftSeconds(timeLeftInSeconds);
            } else if (timeLeftInSeconds > 30 && timeLeftInSeconds <= 60) {
                QuickDropWidgetModule.updateMinutesLeft(1);
            } else if (timeLeftInSeconds > 30) {
                QuickDropWidgetModule.updateHalfMinuteLeft(false);
            } else if (timeLeftInSeconds === 0) {
                QuickDropWidgetModule.updateHalfMinuteLeft(false);
                BackgroundTimer.stopBackgroundTimer();
                setIsPlaying(false);
                QuickDropWidgetModule.timerHasEnded(true)
            }
        }, 1000);
    };

    const reset = () => {
        BackgroundTimer.stopBackgroundTimer();
        setIsPlaying(false);
        setElapsedTimeInMs(0);
        startDate.current = null;
        endDate.current = null;
        lastUpdatedMinute.current = null;
        QuickDropWidgetModule.stopLiveActivity();
    };

    React.useEffect(() => {
        return () => {
            BackgroundTimer.stopBackgroundTimer();
        };
    }, []);

    const timeLeft = totalDuration - elapsedTimeInMs / 1000;
    const formattedValue = `${Math.floor(timeLeft / 60)}:${`0${Math.floor(timeLeft % 60)}`.slice(-2)}`;

    return { play, reset, value: formattedValue, isPlaying };
};

export default useTimer;
