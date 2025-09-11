import { RecordViewData, CalendarDay } from '../model/RecordModel';

/**
 * 日历工具类
 */
export class CalendarUtils {
  /**
   * 获取月份的日历数据（包含前后月份的日期以对齐周）
   * @param year 年份
   * @param month 月份
   * @param records 记录数据
   * @returns CalendarDay[]
   */
  static getCalendarDays(year: number, month: number, records: RecordViewData[]): CalendarDay[] {
    const days: CalendarDay[] = [];
    
    // 当前月的第一天是星期几（0=周日，1=周一...）
    const firstDay = new Date(year, month - 1, 1).getDay();
    // 当前月有多少天
    const daysInMonth = new Date(year, month, 0).getDate();
    // 上个月有多少天
    const daysInPrevMonth = new Date(year, month - 1, 0).getDate();
    
    // 添加上个月的日期（用于对齐周）
    for (let i = firstDay - 1; i >= 0; i--) {
      const date = daysInPrevMonth - i;
      days.push(new CalendarDay(date, false));
    }
    
    // 添加当前月的日期
    for (let date = 1; date <= daysInMonth; date++) {
      const dateTimestamp = new Date(year, month - 1, date).getTime();
      const record = records.find(r => {
        const recordDate = new Date(r.dateInfo);
        return recordDate.getDate() === date &&
               recordDate.getMonth() === month - 1 &&
               recordDate.getFullYear() === year;
      });
      
      days.push(new CalendarDay(date, true, record));
    }
    
    // 添加下个月的日期（补齐6周42天）
    const totalDays = 42; // 6周 * 7天
    const remainingDays = totalDays - days.length;
    for (let date = 1; date <= remainingDays; date++) {
      days.push(new CalendarDay(date, false));
    }
    
    return days;
  }

  /**
   * 获取月份显示文本
   * @param year 年份
   * @param month 月份
   * @returns string
   */
  static getMonthDisplayText(year: number, month: number): string {
    return `${year}年${month}月`;
  }

  /**
   * 获取下一个月
   * @param year 年份
   * @param month 月份
   * @returns {year: number, month: number}
   */
  static getNextMonth(year: number, month: number): {year: number, month: number} {
    if (month === 12) {
      return {year: year + 1, month: 1};
    }
    return {year: year, month: month + 1};
  }

  /**
   * 获取上一个月
   * @param year 年份
   * @param month 月份
   * @returns {year: number, month: number}
   */
  static getPrevMonth(year: number, month: number): {year: number, month: number} {
    if (month === 1) {
      return {year: year - 1, month: 12};
    }
    return {year: year, month: month - 1};
  }

  /**
   * 根据生理状态获取对应的颜色
   * @param status 生理状态
   * @returns string
   */
  static getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#FFFFFF'; // 默认
      case 1: return '#FF6B6B'; // 经期
      case 2: return '#4ECDC4'; // 安全期
      case 3: return '#45B7D1'; // 排卵期
      case 4: return '#FFA07A'; // 预测期
      default: return '#FFFFFF';
    }
  }

  /**
   * 获取周标签
   * @returns string[]
   */
  static getWeekLabels(): string[] {
    return ['日', '一', '二', '三', '四', '五', '六'];
  }
}