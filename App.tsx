import React from 'react';
import { Button, SafeAreaView, Text, View, StyleSheet, useColorScheme } from 'react-native';
import useTimer from './src/useTimer';

function App(): React.JSX.Element {
  const { value, play, reset, isPlaying } = useTimer();

  const theme = useColorScheme();
  const isDarkMode = theme === 'dark';

  const backgroundColor = isDarkMode ? '#333' : '#FFF';
  const textColor = isDarkMode ? '#FFF' : '#000';

  return (
    <SafeAreaView style={[styles.containerView, { backgroundColor }]}>
      <View style={styles.valueContainer}>
        <Text style={[styles.counterText, { color: textColor }]}>
          {value}
        </Text>
      </View>
      <View style={styles.buttonsContainer}>
        <View style={styles.buttonWrapper}>
          <Button
            title={isPlaying ? 'Pause' : 'Play'}
            onPress={play}
            color={isDarkMode ? '#BB86FC' : '#6200EE'}
          />
        </View>
        <Button
          title="Stop"
          onPress={reset}
          color={isDarkMode ? '#BB86FC' : '#6200EE'}
        />
      </View>
    </SafeAreaView>
  );
}

export default App;

const styles = StyleSheet.create({
  containerView: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  valueContainer: {
    paddingVertical: 32,
  },
  counterText: {
    fontSize: 80,
    fontVariant: ['tabular-nums'],
  },
  buttonsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 48,
  },
  buttonWrapper: {
    marginRight: 32,
  },
});
