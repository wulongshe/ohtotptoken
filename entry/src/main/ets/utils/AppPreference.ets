import { PreferenceManager } from "./PreferenceManager";

export type SettingValue = boolean | string | number;
export enum SettingColorMode {
  System,
  Dark,
  Light,
}

export class AppPreference {
  private static prefMgr = PreferenceManager.getInstance();

  private static settings: Map<string, SettingValue> = new Map<string, SettingValue>([
    // 安全性——隐私模式设置
    ['app_safety_privacy_enable', false],
    // 安全性应用锁定设置
    ['app_safety_lock_enable', false],
    // 隐藏令牌
    ['app_safety_hide_token_enable', false],
    // 外观-显示下一个令牌
    ['app_appearance_show_next_token_enable', false],
    // 外观-交换主机名用户名
    ['app_appearance_swap_host_user_enable', false],
    // 外观-自动解锁
    ['app_appearance_auto_unlock_enable', false],
    // 外观-颜色模式
    ['app_appearance_color_mode', SettingColorMode.System],
    // 外观-图标包
    ['app_appearance_icon_pack_selected', 0],
    // 数据库是否启用云同步
    ['app_db_rds_cloud_sync_enable', false],
    // 数据库是否启用跨设备流转
    ['app_db_rds_sync_enable', false],
    // kv数据库同步时间
    ['app_db_kv_sync_time', ''],
    // 是否显示引导提示
    ['app_show_guide_tips', true],
    // 是否处于debug模式
    ['app_debug_mode_on', false],
  ]);

  public static getAppearance(key: string): SettingValue {
    return AppPreference.settings.get(key) ?? '';
  }

  public static setAppearance(key: string, value: SettingValue): void {
    AppPreference.settings.set(key, value);
    AppPreference.prefMgr.setValue<SettingValue>(key, value);
  }

  public static async loadSettings(): Promise<void> {
    const promises = Array.from(AppPreference.settings.keys()).map(async (k) => {
      await AppPreference.prefMgr.getValue<SettingValue>(k).then((val) => {
        if (val !== undefined && val !== null) {
          AppPreference.settings.set(k, val);
        }
      })
    });
    await Promise.all(promises);
  }

  public static saveSettings(): void {
    AppPreference.prefMgr.saveUserData();
  }

  private constructor() {
  }
}