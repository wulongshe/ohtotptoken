/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG: string = '[WindowUtil]';

export class WindowUtil {

  public static requestFullScreen(windowStage: window.WindowStage, context: Context): void {
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
        return;
      }
      let windowClass: window.Window = data;
      Logger.info(TAG, 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(data));

      // Realize the immersive effect
      let isLayoutFullScreen = true;
      try {
        // Get status bar height.
        let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let naviBarArea: window.AvoidArea =
          windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        Logger.info(TAG,
          `Succeeded get the window navigation indicator HEIGHT: ${px2vp(naviBarArea.bottomRect.height)}`);
        AppStorage.setOrCreate<number>('statusBarHeight', px2vp(area.topRect.height));
        AppStorage.setOrCreate<number>('naviIndicatorHeight', px2vp(naviBarArea.bottomRect.height));
        WindowUtil.getDeviceSize(context);
        if (area.topRect.height > 0) {
          let promise: Promise<void> = windowClass.setWindowLayoutFullScreen(isLayoutFullScreen);
          promise.then(() => {
            Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, 'Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
          });
        }
      } catch {
        Logger.error(TAG, 'Failed to set the window layout to full-screen mode. ');
      }
    });
  }

  static getDeviceSize(context: Context): void {
    // Get device height.
    window.getLastWindow(context).then((data: window.Window) => {
      let properties = data.getWindowProperties();
      AppStorage.setOrCreate<number>('deviceHeight', px2vp(properties.windowRect.height));
      AppStorage.setOrCreate<number>('deviceWidth', px2vp(properties.windowRect.width));
    });
  }

  static setMainWindowRestricted(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(`MainWindowClass is undefined`);
        return;
      }
      // Setting restricted display.
      windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    });
  }

  static setMainWindowPortrait(context: Context): void {
    window.getLastWindow(context).then((windowClass: window.Window) => {
      if (windowClass === undefined) {
        Logger.error(`MainWindowClass is undefined`);
        return;
      }
      // Setting restricted display.
      windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
    });
  }

  static setMissionContinueActive(context: common.UIAbilityContext, active: boolean) {
    let activeState = active ? AbilityConstant.ContinueState.ACTIVE : AbilityConstant.ContinueState.INACTIVE;
    context.setMissionContinueState(activeState).then(() => {
      Logger.info('setMissionContinueState success');
    }).catch((err: BusinessError) => {
      Logger.error(`setMissionContinueState failed, code is ${err.code}, message is ${err.message}`);
    });
  }
}