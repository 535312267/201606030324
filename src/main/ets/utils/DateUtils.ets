export class DateUtils {
  
  // 格式化日期为YYYYMM
  static formatYearMonth(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    return `${year}${month}`;
  }

  // 从YYYYMM字符串解析为Date对象
  static parseYearMonth(yearMonth: string): Date {
    if (yearMonth.length !== 6) {
      throw new Error('年月格式错误，应为YYYYMM');
    }
    
    const year = parseInt(yearMonth.substring(0, 4));
    const month = parseInt(yearMonth.substring(4, 6)) - 1; // month is 0-based
    return new Date(year, month, 1);
  }

  // 获取下个月的YYYYMM
  static getNextMonth(yearMonth: string): string {
    const date = this.parseYearMonth(yearMonth);
    const nextMonth = new Date(date.getFullYear(), date.getMonth() + 1, 1);
    return this.formatYearMonth(nextMonth);
  }

  // 获取上个月的YYYYMM
  static getPrevMonth(yearMonth: string): string {
    const date = this.parseYearMonth(yearMonth);
    const prevMonth = new Date(date.getFullYear(), date.getMonth() - 1, 1);
    return this.formatYearMonth(prevMonth);
  }

  // 获取月份的中文标题
  static getMonthTitle(yearMonth: string): string {
    if (yearMonth.length !== 6) return '';
    
    const year = yearMonth.substring(0, 4);
    const month = parseInt(yearMonth.substring(4, 6));
    return `${year}年${month}月`;
  }

  // 判断是否是今天
  static isToday(date: Date): boolean {
    const today = new Date();
    return date.getFullYear() === today.getFullYear() &&
           date.getMonth() === today.getMonth() &&
           date.getDate() === today.getDate();
  }

  // 获取当前年月
  static getCurrentYearMonth(): string {
    return this.formatYearMonth(new Date());
  }

  // 获取指定日期所在月份的所有日期
  static getDaysInMonth(yearMonth: string): Date[] {
    const date = this.parseYearMonth(yearMonth);
    const year = date.getFullYear();
    const month = date.getMonth();
    
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysCount = lastDay.getDate();
    
    const days: Date[] = [];
    for (let i = 1; i <= daysCount; i++) {
      days.push(new Date(year, month, i));
    }
    
    return days;
  }

  // 获取月份相对于当前月份的偏移量
  static getMonthOffset(yearMonth: string): number {
    const current = new Date();
    const target = this.parseYearMonth(yearMonth);
    
    const currentYear = current.getFullYear();
    const currentMonth = current.getMonth();
    const targetYear = target.getFullYear();
    const targetMonth = target.getMonth();
    
    return (targetYear - currentYear) * 12 + (targetMonth - currentMonth);
  }

  // 根据偏移量获取年月
  static getYearMonthByOffset(offset: number): string {
    const current = new Date();
    const target = new Date(current.getFullYear(), current.getMonth() + offset, 1);
    return this.formatYearMonth(target);
  }

  // 比较两个年月的大小
  static compareYearMonth(yearMonth1: string, yearMonth2: string): number {
    if (yearMonth1 === yearMonth2) return 0;
    
    const date1 = this.parseYearMonth(yearMonth1);
    const date2 = this.parseYearMonth(yearMonth2);
    
    return date1.getTime() - date2.getTime();
  }

  // 验证年月格式
  static isValidYearMonth(yearMonth: string): boolean {
    if (!yearMonth || yearMonth.length !== 6) return false;
    
    const year = parseInt(yearMonth.substring(0, 4));
    const month = parseInt(yearMonth.substring(4, 6));
    
    return !isNaN(year) && !isNaN(month) && 
           year >= 1900 && year <= 2100 && 
           month >= 1 && month <= 12;
  }
}