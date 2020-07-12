const TANDEM = "Tandem";
const PC_WINDOW_WIDTH = 1680;
const TANDEM_WINDOW_WIDTH = PC_WINDOW_WIDTH * 0.2;
const REMAINING_PC_WINDOW_WIDTH = PC_WINDOW_WIDTH - TANDEM_WINDOW_WIDTH;

Phoenix.set({
  daemon: false,
  openAtLogin: true,
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

/**
 * @typedef {Object} Rectangle
 * @property {number} x
 * @property {number} y
 * @property {number} width
 * @property {number} height
 */

const AppPosition = {
  MODIFIERS: ["cmd", "ctrl", "alt"],
  getFrames() {
    const focusedWindow = Window.focused();
    if (!focusedWindow) return;

    /** @type {Rectangle} */
    const screenFrame = focusedWindow.screen().flippedVisibleFrame();
    /** @type {Rectangle} */
    const appFrame = focusedWindow.frame();
    return {
      focusedWindow,
      screenFrame,
      appFrame,
    };
  },
  /**
   * Resize the window size
   * @param {number} multiplier
   */
  resize(multiplier) {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame, appFrame } = frames;
    const { x, y, width, height } = appFrame;

    const appWidth = Math.min(screenFrame.width, width + screenFrame.width * multiplier);
    const appHeight = Math.min(screenFrame.height, height + screenFrame.height * multiplier);
    let appX = x;
    if (x - (screenFrame.width * multiplier) / 2 > screenFrame.x) {
      appX = x - (screenFrame.width * multiplier) / 2;
    } else if (x + appWidth > screenFrame.x + screenFrame.width) {
      appX = screenFrame.x + screenFrame.width - appWidth;
    }
    let appY = y;
    if (y - (screenFrame.height * multiplier) / 2 > screenFrame.y) {
      appY = y - (screenFrame.height * multiplier) / 2;
    } else if (y + appHeight > screenFrame.y + screenFrame.height) {
      appY = screenFrame.y + screenFrame.height - appHeight;
    }

    focusedWindow.setFrame({
      width: appWidth,
      height: appHeight,
      x: appX,
      y: appY,
    });
  },

  toLeft() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x,
      y: screenFrame.y,
      width: screenFrame.width / 2,
      height: screenFrame.height,
    });
  },
  toRight() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x + screenFrame.width - screenFrame.width / 2,
      y: screenFrame.y,
      width: screenFrame.width / 2,
      height: screenFrame.height,
    });
  },
  toTop() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x,
      y: screenFrame.y,
      width: screenFrame.width,
      height: screenFrame.height / 2,
    });
  },
  toBottom() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x,
      y: screenFrame.y + screenFrame.height - screenFrame.height / 2,
      width: screenFrame.width,
      height: screenFrame.height / 2,
    });
  },
  centerize() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x + screenFrame.width / 4,
      y: screenFrame.y + screenFrame.height / 4,
      width: screenFrame.width / 2,
      height: screenFrame.height / 2,
    });
  },
  maximize() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow } = frames;
    focusedWindow.maximise();
  },
  toTopLeft() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x,
      y: screenFrame.y,
      width: screenFrame.width / 2,
      height: screenFrame.height / 2,
    });
  },
  toTopRight() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x + screenFrame.width - screenFrame.width / 2,
      y: screenFrame.y,
      width: screenFrame.width / 2,
      height: screenFrame.height / 2,
    });
  },
  toBottomLeft() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x,
      y: screenFrame.y + screenFrame.height - screenFrame.height / 2,
      width: screenFrame.width / 2,
      height: screenFrame.height / 2,
    });
  },
  toBottomRight() {
    const frames = this.getFrames();
    if (!frames) return;

    const { focusedWindow, screenFrame } = frames;
    focusedWindow.setFrame({
      x: screenFrame.x + screenFrame.width - screenFrame.width / 2,
      y: screenFrame.y + screenFrame.height - screenFrame.height / 2,
      width: screenFrame.width / 2,
      height: screenFrame.height / 2,
    });
  },
  decreaseSize() {
    this.resize(-0.1);
  },
  increaseSize() {
    this.resize(0.1);
  },
};

Key.on("left", AppPosition.MODIFIERS, () => AppPosition.toLeft());
Key.on("right", AppPosition.MODIFIERS, () => AppPosition.toRight());
Key.on("up", AppPosition.MODIFIERS, () => AppPosition.toTop());
Key.on("down", AppPosition.MODIFIERS, () => AppPosition.toBottom());
Key.on("c", AppPosition.MODIFIERS, () => AppPosition.centerize());
Key.on("m", AppPosition.MODIFIERS, () => AppPosition.maximize());
Key.on("1", AppPosition.MODIFIERS, () => AppPosition.toTopLeft());
Key.on("2", AppPosition.MODIFIERS, () => AppPosition.toTopRight());
Key.on("3", AppPosition.MODIFIERS, () => AppPosition.toBottomLeft());
Key.on("4", AppPosition.MODIFIERS, () => AppPosition.toBottomRight());
Key.on("-", AppPosition.MODIFIERS, () => AppPosition.decreaseSize());
Key.on("=", AppPosition.MODIFIERS, () => AppPosition.increaseSize());
