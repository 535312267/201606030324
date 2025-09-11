// 年月查询记录信息
export class recordViewData {
  dateInfo: number = 0; // 日期时间戳毫秒
  todayFlag: boolean = false; // 是否是今日
  predictFlag: boolean = false; // 是否是预测周期
  physiologyStatus: number = 0; // 生理状态枚举
}

// 月份数据
export interface MonthData {
  yearMonth: string; // YYYYMM格式
  records: recordViewData[];
}

// 日历日期项
export interface CalendarDay {
  day: number;
  date: Date;
  record?: recordViewData;
  isCurrentMonth: boolean;
  isToday: boolean;
}

// 周信息
export interface WeekInfo {
  days: CalendarDay[];
}

// 生理状态枚举
export enum PhysiologyStatus {
  NORMAL = 0,
  MENSTRUATION = 1,
  OVULATION = 2,
  FERTILE = 3,
  PREDICTED = 4
}