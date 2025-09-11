import preferences from '@ohos.data.preferences';
import { recordViewData, MonthData } from '../models/RecordModels';
import { AppConfig } from '../config/AppConfig';

export class DataManager {
  private static instance: DataManager;
  private preferences: preferences.Preferences | null = null;
  private readonly STORE_NAME = AppConfig.STORAGE_NAME;

  private constructor() {}

  public static getInstance(): DataManager {
    if (!DataManager.instance) {
      DataManager.instance = new DataManager();
    }
    return DataManager.instance;
  }

  // 初始化存储
  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (error) {
      console.error('初始化存储失败:', error);
    }
  }

  // 保存月份数据
  async saveMonthData(yearMonth: string, records: recordViewData[]): Promise<void> {
    if (!this.preferences) return;
    
    try {
      const monthData: MonthData = { yearMonth, records };
      await this.preferences.put(yearMonth, JSON.stringify(monthData));
      await this.preferences.flush();
    } catch (error) {
      console.error('保存月份数据失败:', error);
    }
  }

  // 获取月份数据
  async getMonthData(yearMonth: string): Promise<recordViewData[] | null> {
    if (!this.preferences) return null;
    
    try {
      const data = await this.preferences.get(yearMonth, '');
      if (data) {
        const monthData: MonthData = JSON.parse(data as string);
        return monthData.records;
      }
    } catch (error) {
      console.error('获取月份数据失败:', error);
    }
    return null;
  }

  // 检查是否有月份数据
  async hasMonthData(yearMonth: string): Promise<boolean> {
    if (!this.preferences) return false;
    
    try {
      const data = await this.preferences.get(yearMonth, '');
      return !!data;
    } catch (error) {
      console.error('检查月份数据失败:', error);
      return false;
    }
  }

  // 更新单个记录
  async updateRecord(yearMonth: string, record: recordViewData): Promise<void> {
    const records = await this.getMonthData(yearMonth);
    if (records) {
      const index = records.findIndex(r => r.dateInfo === record.dateInfo);
      if (index !== -1) {
        records[index] = record;
        await this.saveMonthData(yearMonth, records);
      }
    }
  }

  // 清除过期数据（可选，用于清理旧数据）
  async clearOldData(monthsToKeep: number = AppConfig.CACHE_EXPIRE_MONTHS): Promise<void> {
    if (!this.preferences) return;
    
    try {
      const now = new Date();
      const cutoffDate = new Date(now.getFullYear(), now.getMonth() - monthsToKeep, 1);
      
      const allKeys = await this.preferences.getAll();
      for (const key in allKeys) {
        if (key.length === 6) { // YYYYMM format
          const year = parseInt(key.substring(0, 4));
          const month = parseInt(key.substring(4, 6)) - 1; // month is 0-based
          const keyDate = new Date(year, month, 1);
          
          if (keyDate < cutoffDate) {
            await this.preferences.delete(key);
          }
        }
      }
      await this.preferences.flush();
    } catch (error) {
      console.error('清除过期数据失败:', error);
    }
  }
}