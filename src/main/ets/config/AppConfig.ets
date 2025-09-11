// 应用配置
export class AppConfig {
  // API配置
  static readonly API_BASE_URL = 'https://your-api-domain.com'; // 请替换为实际的API地址
  static readonly API_TIMEOUT = 10000; // 请求超时时间（毫秒）
  
  // 存储配置
  static readonly STORAGE_NAME = 'calendar_data';
  static readonly CACHE_EXPIRE_MONTHS = 12; // 缓存过期月数
  
  // UI配置
  static readonly SWIPER_DURATION = 300; // Swiper动画时长
  static readonly LOADING_DELAY = 50; // 加载延迟
  
  // 生理状态颜色配置
  static readonly STATUS_COLORS = {
    NORMAL: '#E0E0E0',      // 正常 - 灰色
    MENSTRUATION: '#FF4444', // 月经期 - 红色
    OVULATION: '#4CAF50',    // 排卵期 - 绿色
    FERTILE: '#FFC107',      // 易孕期 - 黄色
    PREDICTED: '#FF9800'     // 预测期 - 橙色
  };
  
  // 背景色透明度
  static readonly BACKGROUND_ALPHA = {
    NORMAL: '20',      // 正常状态背景透明度
    PREDICTED: '40'    // 预测状态背景透明度
  };
}