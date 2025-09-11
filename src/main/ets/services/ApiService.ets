import http from '@ohos.net.http';
import { recordViewData } from '../models/RecordModels';
import { AppConfig } from '../config/AppConfig';

export class ApiService {
  private static instance: ApiService;
  private baseUrl: string = AppConfig.API_BASE_URL;

  private constructor() {}

  public static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }

  // 设置基础URL
  setBaseUrl(url: string): void {
    this.baseUrl = url;
  }

  // 获取月份记录数据
  async getMonthRecords(yearMonth: string): Promise<recordViewData[]> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: AppConfig.API_TIMEOUT,
        connectTimeout: AppConfig.API_TIMEOUT,
        extraData: {
          yearMonth: yearMonth
        }
      };

      httpRequest.request(`${this.baseUrl}/api/records/month`, requestOptions)
        .then((response: http.HttpResponse) => {
          if (response.responseCode === 200) {
            try {
              const data = JSON.parse(response.result as string);
              // 假设服务端返回格式为 { success: true, data: recordViewData[] }
              if (data.success && data.data) {
                const records: recordViewData[] = data.data.map((item: any) => {
                  const record = new recordViewData();
                  record.dateInfo = item.dateInfo;
                  record.todayFlag = item.todayFlag;
                  record.predictFlag = item.predictFlag;
                  record.physiologyStatus = item.physiologyStatus;
                  return record;
                });
                resolve(records);
              } else {
                reject(new Error('服务端返回数据格式错误'));
              }
            } catch (error) {
              reject(new Error('解析响应数据失败: ' + error.message));
            }
          } else {
            reject(new Error(`请求失败，状态码: ${response.responseCode}`));
          }
        })
        .catch((error: Error) => {
          reject(new Error('网络请求失败: ' + error.message));
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  // 批量获取多个月份的数据
  async getBatchMonthRecords(yearMonths: string[]): Promise<Map<string, recordViewData[]>> {
    const results = new Map<string, recordViewData[]>();
    const promises = yearMonths.map(async (yearMonth) => {
      try {
        const records = await this.getMonthRecords(yearMonth);
        results.set(yearMonth, records);
      } catch (error) {
        console.error(`获取${yearMonth}数据失败:`, error);
        results.set(yearMonth, []);
      }
    });

    await Promise.all(promises);
    return results;
  }

  // 更新记录数据（可选，如果需要支持数据修改）
  async updateRecord(record: recordViewData): Promise<boolean> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(record)
      };

      httpRequest.request(`${this.baseUrl}/api/records/update`, requestOptions)
        .then((response: http.HttpResponse) => {
          if (response.responseCode === 200) {
            try {
              const data = JSON.parse(response.result as string);
              resolve(data.success || false);
            } catch (error) {
              reject(new Error('解析响应数据失败: ' + error.message));
            }
          } else {
            reject(new Error(`更新失败，状态码: ${response.responseCode}`));
          }
        })
        .catch((error: Error) => {
          reject(new Error('网络请求失败: ' + error.message));
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }
}