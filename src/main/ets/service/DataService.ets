import { RecordViewData, MonthData } from '../model/RecordModel';
import preferences from '@ohos.data.preferences';

/**
 * 数据服务类，负责数据的获取和本地存储
 */
export class DataService {
  private static instance: DataService;
  private preferencesStore?: preferences.Preferences;

  private constructor() {
    this.initPreferences();
  }

  public static getInstance(): DataService {
    if (!DataService.instance) {
      DataService.instance = new DataService();
    }
    return DataService.instance;
  }

  /**
   * 初始化本地存储
   */
  private async initPreferences() {
    try {
      this.preferencesStore = await preferences.getPreferences(getContext(), 'calendar_data');
    } catch (error) {
      console.error('初始化本地存储失败:', error);
    }
  }

  /**
   * 从服务端获取月份数据
   * @param year 年份
   * @param month 月份
   * @returns Promise<RecordViewData[]>
   */
  async fetchMonthDataFromServer(year: number, month: number): Promise<RecordViewData[]> {
    try {
      // 模拟服务端请求
      // 在实际项目中，这里应该是真实的HTTP请求
      const response = await this.mockServerRequest(year, month);
      
      // 保存到本地存储
      await this.saveMonthDataToLocal(year, month, response);
      
      return response;
    } catch (error) {
      console.error(`获取${year}-${month}数据失败:`, error);
      return [];
    }
  }

  /**
   * 从本地存储获取月份数据
   * @param year 年份
   * @param month 月份
   * @returns Promise<RecordViewData[] | null>
   */
  async getMonthDataFromLocal(year: number, month: number): Promise<RecordViewData[] | null> {
    try {
      if (!this.preferencesStore) {
        await this.initPreferences();
      }
      
      const key = `${year}-${month}`;
      const dataStr = await this.preferencesStore?.get(key, '');
      
      if (dataStr && dataStr !== '') {
        return JSON.parse(dataStr as string) as RecordViewData[];
      }
      return null;
    } catch (error) {
      console.error(`获取本地${year}-${month}数据失败:`, error);
      return null;
    }
  }

  /**
   * 保存月份数据到本地存储
   * @param year 年份
   * @param month 月份
   * @param data 数据
   */
  async saveMonthDataToLocal(year: number, month: number, data: RecordViewData[]): Promise<void> {
    try {
      if (!this.preferencesStore) {
        await this.initPreferences();
      }
      
      const key = `${year}-${month}`;
      await this.preferencesStore?.put(key, JSON.stringify(data));
      await this.preferencesStore?.flush();
    } catch (error) {
      console.error(`保存本地${year}-${month}数据失败:`, error);
    }
  }

  /**
   * 获取月份数据（优先本地，无则请求服务端）
   * @param year 年份
   * @param month 月份
   * @returns Promise<RecordViewData[]>
   */
  async getMonthData(year: number, month: number): Promise<RecordViewData[]> {
    // 先尝试从本地获取
    const localData = await this.getMonthDataFromLocal(year, month);
    if (localData && localData.length > 0) {
      console.log(`从本地获取${year}-${month}数据`);
      return localData;
    }
    
    // 本地无数据，从服务端获取
    console.log(`从服务端获取${year}-${month}数据`);
    return await this.fetchMonthDataFromServer(year, month);
  }

  /**
   * 模拟服务端请求
   * @param year 年份
   * @param month 月份
   * @returns Promise<RecordViewData[]>
   */
  private async mockServerRequest(year: number, month: number): Promise<RecordViewData[]> {
    return new Promise((resolve) => {
      // 模拟网络延迟
      setTimeout(() => {
        const daysInMonth = new Date(year, month, 0).getDate();
        const data: RecordViewData[] = [];
        
        for (let day = 1; day <= daysInMonth; day++) {
          const dateInfo = new Date(year, month - 1, day).getTime();
          const today = new Date();
          const isToday = year === today.getFullYear() && 
                         month === today.getMonth() + 1 && 
                         day === today.getDate();
          
          data.push({
            dateInfo: dateInfo,
            todayFlag: isToday,
            predictFlag: Math.random() > 0.8, // 随机生成预测标记
            physiologyStatus: Math.floor(Math.random() * 5) // 随机生成生理状态
          });
        }
        
        resolve(data);
      }, 300);
    });
  }

  /**
   * 更新本地数据
   * @param year 年份
   * @param month 月份
   * @param data 更新的数据
   */
  async updateMonthData(year: number, month: number, data: RecordViewData[]): Promise<void> {
    await this.saveMonthDataToLocal(year, month, data);
  }
}