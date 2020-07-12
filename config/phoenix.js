const TANDEM = "Tandem";
const PC_WINDOW_WIDTH = 1680;
const TANDEM_WINDOW_WIDTH = PC_WINDOW_WIDTH * 0.2;
const REMAINING_PC_WINDOW_WIDTH = PC_WINDOW_WIDTH - TANDEM_WINDOW_WIDTH;

Phoenix.set({
  openAtLogin: false,
});

const log = (msg) => {
  Phoenix.log(JSON.stringify(msg));
};

const displayTandemAppInPcWindow = (appName) => {
  if (appName === TANDEM) return;

  // Tandem app
  const tandemApp = App.get(TANDEM);
  if (!tandemApp) return;
  const tandemAppWindow = tandemApp.mainWindow();

  // focused app
  const focusedApp = App.get(appName);
  const focusedAppWindow = focusedApp.mainWindow();
  const focusedAppFrame = focusedAppWindow.frame();

  // Main screen frame
  const frame = Screen.main().visibleFrame();
  const windowX = frame.x;
  const windowHeight = frame.height;

  // Resize
  if (windowX === 0) {
    // If the current window is on macbook
    const focusedAppWidth = focusedAppFrame.width;
    const focusedAppHeight = focusedAppFrame.height;
    const point = focusedAppWindow.topLeft();
    let focusedAppX = point.x;
    const focusedAppY = point.y;
    const appWidth = Math.min(REMAINING_PC_WINDOW_WIDTH, focusedAppWidth);
    if (focusedAppX + appWidth > REMAINING_PC_WINDOW_WIDTH) {
      focusedAppX = REMAINING_PC_WINDOW_WIDTH - appWidth;
    }

    focusedAppWindow.setFrame({
      x: focusedAppX,
      y: focusedAppY,
      width: appWidth,
      focusedAppHeight,
    });
  }
  tandemAppWindow.setFrame({
    x: REMAINING_PC_WINDOW_WIDTH,
    y: 0,
    width: TANDEM_WINDOW_WIDTH,
    windowHeight,
  });

  focusedAppWindow.raise();
  tandemAppWindow.raise();
};

// on active
Event.on("appDidActivate", (app) => {
  const appName = app.name();
  displayTandemAppInPcWindow(appName);
});
