import { hilog } from '@kit.PerformanceAnalysisKit';

// 日期选择器配置接口
export interface DatePickerConfig {
  // 可选择的日期范围（时间戳数组）
  selectableDates?: number[];
  // 默认选中的日期范围
  defaultSelectedRange?: [number, number];
  // 未来日期的选中状态自定义
  futureSelectedState?: boolean;
  // 网络请求数据回调
  onDataLoad?: (timestamps: number[]) => void;
  // 点击日期时自动选中后续天数（默认为0，不自动选中）
  autoSelectDays?: number;
  // 是否启用智能选择模式（点击已选中日期的前后会自动选中/取消选中范围）
  smartSelectionMode?: boolean;
}

// 月份数据结构
interface MonthData {
  year: number;
  month: number;
  days: DayData[];
  weeks: (DayData | null)[][]; // 预处理的周数据
}

// 日期数据结构
interface DayData {
  day: number;
  timestamp: number;
  isSelected: boolean;
  isFuture: boolean;
  isInRange: boolean;
  hasNetworkData: boolean;
}

// 日期范围结构
interface DateRange {
  start: number;
  end: number;
}

@Component
export struct DatePickerComponent {
  @State private monthList: MonthData[] = [];
  @State private selectedDates: Set<number> = new Set();
  @State private networkDataTimestamps: Set<number> = new Set();
  @State private currentDisplayMonth: number = 0;
  @State private isLoading: boolean = false;
  
  // 配置参数 - 支持从外部传入
  @Prop config: DatePickerConfig = {};
  private selectableRange: [number, number] = [0, 0];
  
  // 回调函数 - 用于向父组件传递数据
  onSelectedDatesChange?: (dates: number[]) => void;
  
  // List组件控制器
  private listScroller: ListScroller = new ListScroller();
  
  // 性能优化：缓存计算结果
  private monthCache: Map<string, MonthData> = new Map();
  
  aboutToAppear() {
    this.initializeDateRange();
    this.generateInitialMonths();
    this.loadNetworkData();
    
    // 滚动到列表末尾（当前月份）
    setTimeout(() => {
      if (this.monthList.length > 0) {
        this.listScroller.scrollToIndex(this.monthList.length - 1);
      }
    }, 100);
  }
  
  // 初始化日期范围
  private initializeDateRange() {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    
    // 从2010年1月开始
    const startTime = new Date(2010, 0, 1).getTime();
    
    // 到下个月结束
    const nextMonth = new Date(currentYear, currentMonth + 2, 0); // 下个月的最后一天
    const endTime = nextMonth.getTime();
    
    this.selectableRange = [startTime, endTime];
    
    // 设置默认选中范围
    if (this.config.defaultSelectedRange) {
      const start = this.config.defaultSelectedRange[0];
      const end = this.config.defaultSelectedRange[1];
      for (let timestamp = start; timestamp <= end; timestamp += 24 * 60 * 60 * 1000) {
        this.selectedDates.add(timestamp);
      }
    }
  }
  
  // 生成初始月份数据（从历史月份到当前月）
  private generateInitialMonths() {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    
    // 生成更多初始数据，包括历史月份，减少首次加载时的卡顿
    // 生成过去12个月到下个月的数据
    for (let i = 12; i >= -1; i--) {
      const targetDate = new Date(currentYear, currentMonth - i, 1);
      
      // 确保不超过2010年1月
      if (targetDate.getFullYear() < 2010 || 
          (targetDate.getFullYear() === 2010 && targetDate.getMonth() < 0)) {
        continue;
      }
      
      // 确保不超过下个月
      const nextMonth = new Date(currentYear, currentMonth + 2, 0);
      if (targetDate.getTime() > nextMonth.getTime()) {
        continue;
      }
      
      const monthData = this.generateMonthData(targetDate.getFullYear(), targetDate.getMonth());
      this.monthList.push(monthData);
    }
    
    console.log(`Generated ${this.monthList.length} initial months`);
  }
  
  // 生成单个月份的数据
  private generateMonthData(year: number, month: number): MonthData {
    const cacheKey = `${year}-${month}`;
    
    // 检查缓存，但需要更新选中状态和网络数据状态
    if (this.monthCache.has(cacheKey)) {
      const cachedData = this.monthCache.get(cacheKey)!;
      
      // 更新动态数据（选中状态和网络数据）
      const updatedDays: DayData[] = [];
      for (let i = 0; i < cachedData.days.length; i++) {
        const dayData = cachedData.days[i];
        const updatedDayData: DayData = {
          day: dayData.day,
          timestamp: dayData.timestamp,
          isSelected: this.selectedDates.has(dayData.timestamp),
          isFuture: dayData.isFuture,
          isInRange: dayData.isInRange,
          hasNetworkData: this.networkDataTimestamps.has(dayData.timestamp)
        };
        updatedDays.push(updatedDayData);
      }
      
      // 重新生成周数据
      const weeks = this.generateWeeksData(year, month, updatedDays);
      
      return { year, month, days: updatedDays, weeks };
    }
    
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const days: DayData[] = [];
    const now = Date.now();
    
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day);
      const timestamp = date.getTime();
      
      const dayData: DayData = {
        day,
        timestamp,
        isSelected: this.selectedDates.has(timestamp),
        isFuture: timestamp > now,
        isInRange: this.isDateInSelectableRange(timestamp),
        hasNetworkData: this.networkDataTimestamps.has(timestamp)
      };
      
      days.push(dayData);
    }
    
    // 预处理周数据
    const weeks = this.generateWeeksData(year, month, days);
    
    const monthData: MonthData = { year, month, days, weeks };
    
    // 只缓存静态数据（不包括选中状态）
    const staticDays: DayData[] = [];
    for (let i = 0; i < days.length; i++) {
      const d = days[i];
      const staticDay: DayData = {
        day: d.day,
        timestamp: d.timestamp,
        isSelected: false, // 不缓存选中状态
        isFuture: d.isFuture,
        isInRange: d.isInRange,
        hasNetworkData: false // 不缓存网络数据状态
      };
      staticDays.push(staticDay);
    }
    
    const staticMonthData: MonthData = {
      year,
      month,
      days: staticDays,
      weeks: [] // 周数据会重新生成
    };
    this.monthCache.set(cacheKey, staticMonthData);
    
    return monthData;
  }
  
  // 生成周数据
  private generateWeeksData(year: number, month: number, days: DayData[]): (DayData | null)[][] {
    // 计算第一天是星期几
    const firstDay = new Date(year, month, 1).getDay();
    const startIndex = firstDay === 0 ? 6 : firstDay - 1; // 周一为0
    
    let currentWeek: (DayData | null)[] = [];
    let weeks: (DayData | null)[][] = [];
    
    // 添加空白日期
    for (let i = 0; i < startIndex; i++) {
      currentWeek.push(null);
    }
    
    // 添加实际日期
    days.forEach((dayData) => {
      currentWeek.push(dayData);
      
      if (currentWeek.length === 7) {
        const weekCopy: (DayData | null)[] = [];
        for (let k = 0; k < currentWeek.length; k++) {
          weekCopy.push(currentWeek[k]);
        }
        weeks.push(weekCopy);
        currentWeek = [];
      }
    });
    
    // 补齐最后一周
    while (currentWeek.length > 0 && currentWeek.length < 7) {
      currentWeek.push(null);
    }
    if (currentWeek.length > 0) {
      weeks.push(currentWeek);
    }
    
    return weeks;
  }
  
  // 检查日期是否在可选择范围内
  private isDateInSelectableRange(timestamp: number): boolean {
    const start = this.selectableRange[0];
    const end = this.selectableRange[1];
    const result = timestamp >= start && timestamp <= end;
    
    // 调试信息
    if (!result) {
      const date = new Date(timestamp);
      const startDate = new Date(start);
      const endDate = new Date(end);
      console.log(`Date ${date.toDateString()} not in range ${startDate.toDateString()} - ${endDate.toDateString()}`);
    }
    
    return result;
  }
  
  // 模拟网络请求加载数据
  private async loadNetworkData() {
    this.isLoading = true;
    
    try {
      // 模拟网络延迟
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 模拟返回的时间戳数据
      const mockTimestamps = [
        new Date(2025, 8, 1).getTime(), // 2025年9月1日
        new Date(2025, 8, 3).getTime(), // 2025年9月3日
        new Date(2025, 8, 5).getTime(), // 2025年9月5日
      ];
      
      // 更新网络数据时间戳
      mockTimestamps.forEach(timestamp => {
        this.networkDataTimestamps.add(timestamp);
        // 如果网络数据中的日期在可选范围内，自动选中
        if (this.isDateInSelectableRange(timestamp)) {
          this.selectedDates.add(timestamp);
        }
      });
      
      // 更新月份数据
      this.updateMonthsWithNetworkData();
      
      // 调用配置回调
      if (this.config.onDataLoad) {
        this.config.onDataLoad(mockTimestamps);
      }
      
    } catch (error) {
      hilog.error(0x0000, 'DatePicker', `Network data load failed: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }
  
  // 使用网络数据更新月份
  private updateMonthsWithNetworkData() {
    const newMonthList: MonthData[] = [];
    
    for (let i = 0; i < this.monthList.length; i++) {
      const monthData = this.monthList[i];
      const updatedDays: DayData[] = [];
      
      for (let j = 0; j < monthData.days.length; j++) {
        const dayData = monthData.days[j];
        const updatedDayData: DayData = {
          day: dayData.day,
          timestamp: dayData.timestamp,
          isSelected: this.selectedDates.has(dayData.timestamp),
          isFuture: dayData.isFuture,
          isInRange: dayData.isInRange,
          hasNetworkData: this.networkDataTimestamps.has(dayData.timestamp)
        };
        updatedDays.push(updatedDayData);
      }
      
      // 重新生成周数据
      const weeks = this.generateWeeksData(monthData.year, monthData.month, updatedDays);
      
      const updatedMonthData: MonthData = {
        year: monthData.year,
        month: monthData.month,
        days: updatedDays,
        weeks: weeks
      };
      
      newMonthList.push(updatedMonthData);
    }
    
    this.monthList = newMonthList;
  }
  
  // 处理日期点击
  private onDateClick(dayData: DayData) {
    console.log('Date clicked:', dayData.day, dayData.timestamp);

    // 未来日期且不在选中范围内，不允许点击
    if (dayData.isFuture && !dayData.isInRange) {
      console.log('Future date not in range, click ignored');
      return;
    }

    // 不在可选择范围内的日期不允许点击
    if (!dayData.isInRange) {
      console.log('Date not in selectable range, click ignored');
      return;
    }

    // 智能选择模式
    if (this.config.smartSelectionMode) {
      this.handleSmartSelection(dayData);
    } else {
      this.handleNormalSelection(dayData);
    }

    // 通知父组件选中日期变化
    if (this.onSelectedDatesChange) {
      this.onSelectedDatesChange(this.getSelectedDates());
    }
  }

  // 普通选择模式
  private handleNormalSelection(dayData: DayData) {
    const wasSelected = this.selectedDates.has(dayData.timestamp);
    
    if (wasSelected) {
      // 取消选中：移除当前日期和可能的连续日期
      this.deselectDateRange(dayData.timestamp);
      console.log('Date deselected:', dayData.day);
    } else {
      // 选中：添加当前日期和后续几天
      this.selectDateRange(dayData.timestamp);
      console.log('Date selected:', dayData.day);
    }
  }

  // 智能选择模式
  private handleSmartSelection(dayData: DayData) {
    const wasSelected = this.selectedDates.has(dayData.timestamp);
    
    if (wasSelected) {
      // 如果点击已选中的日期，智能取消选中相关范围
      this.smartDeselect(dayData.timestamp);
    } else {
      // 如果点击未选中的日期，智能选中范围
      this.smartSelect(dayData.timestamp);
    }
  }

  // 选中日期范围（当前日期 + 后续几天）
  private selectDateRange(startTimestamp: number) {
    const autoSelectDays = this.config.autoSelectDays || 0;
    const oneDayMs = 24 * 60 * 60 * 1000;
    
    // 选中起始日期
    this.selectedDates.add(startTimestamp);
    
    // 选中后续几天
    for (let i = 1; i <= autoSelectDays; i++) {
      const nextDayTimestamp = startTimestamp + (i * oneDayMs);
      
      // 检查是否在可选择范围内
      if (this.isDateInSelectableRange(nextDayTimestamp)) {
        // 检查是否是未来日期且不允许选中
        const isFuture = nextDayTimestamp > Date.now();
        if (!(isFuture && !this.config.futureSelectedState)) {
          this.selectedDates.add(nextDayTimestamp);
          console.log(`Auto selected: ${new Date(nextDayTimestamp).toDateString()}`);
        }
      }
    }
    
    // 批量更新UI
    this.updateMultipleDaysSelection();
  }

  // 取消选中日期范围
  private deselectDateRange(startTimestamp: number) {
    const autoSelectDays = this.config.autoSelectDays || 0;
    const oneDayMs = 24 * 60 * 60 * 1000;
    
    // 取消选中起始日期
    this.selectedDates.delete(startTimestamp);
    
    // 取消选中后续几天（如果它们是连续选中的）
    for (let i = 1; i <= autoSelectDays; i++) {
      const nextDayTimestamp = startTimestamp + (i * oneDayMs);
      if (this.selectedDates.has(nextDayTimestamp)) {
        this.selectedDates.delete(nextDayTimestamp);
        console.log(`Auto deselected: ${new Date(nextDayTimestamp).toDateString()}`);
      } else {
        // 如果遇到未选中的日期，停止取消选中
        break;
      }
    }
    
    // 批量更新UI
    this.updateMultipleDaysSelection();
  }

  // 智能选中
  private smartSelect(clickedTimestamp: number) {
    const oneDayMs = 24 * 60 * 60 * 1000;
    const autoSelectDays = this.config.autoSelectDays || 5; // 智能模式默认5天
    
    // 查找最近的选中日期
    const nearestSelected = this.findNearestSelectedDate(clickedTimestamp);
    
    if (nearestSelected) {
      // 如果有最近的选中日期，选中它们之间的范围
      const startTime = Math.min(clickedTimestamp, nearestSelected);
      const endTime = Math.max(clickedTimestamp, nearestSelected);
      
      for (let timestamp = startTime; timestamp <= endTime; timestamp += oneDayMs) {
        if (this.isDateInSelectableRange(timestamp)) {
          this.selectedDates.add(timestamp);
        }
      }
      console.log('Smart selected range');
    } else {
      // 如果没有最近的选中日期，按普通模式选中
      this.selectDateRange(clickedTimestamp);
    }
    
    this.updateMultipleDaysSelection();
  }

  // 智能取消选中
  private smartDeselect(clickedTimestamp: number) {
    const oneDayMs = 24 * 60 * 60 * 1000;
    
    // 查找连续的选中范围并取消选中
    const range = this.findConnectedSelectedRange(clickedTimestamp);
    
    for (let timestamp = range.start; timestamp <= range.end; timestamp += oneDayMs) {
      this.selectedDates.delete(timestamp);
    }
    
    console.log('Smart deselected range');
    this.updateMultipleDaysSelection();
  }

  // 查找最近的选中日期
  private findNearestSelectedDate(targetTimestamp: number): number | null {
    const oneDayMs = 24 * 60 * 60 * 1000;
    const maxSearchDays = 14; // 最多搜索14天
    
    // 向前和向后搜索
    for (let i = 1; i <= maxSearchDays; i++) {
      const prevDay = targetTimestamp - (i * oneDayMs);
      const nextDay = targetTimestamp + (i * oneDayMs);
      
      if (this.selectedDates.has(prevDay)) {
        return prevDay;
      }
      if (this.selectedDates.has(nextDay)) {
        return nextDay;
      }
    }
    
    return null;
  }

  // 查找连续的选中范围
  private findConnectedSelectedRange(centerTimestamp: number): DateRange {
    const oneDayMs = 24 * 60 * 60 * 1000;
    let start = centerTimestamp;
    let end = centerTimestamp;
    
    // 向前查找
    while (this.selectedDates.has(start - oneDayMs)) {
      start -= oneDayMs;
    }
    
    // 向后查找
    while (this.selectedDates.has(end + oneDayMs)) {
      end += oneDayMs;
    }
    
    const result: DateRange = {
      start: start,
      end: end
    };
    
    return result;
  }

  // 批量更新多个日期的选中状态
  private updateMultipleDaysSelection() {
    // 创建新的月份列表以触发@State更新
    const newMonthList: MonthData[] = [];

    for (let i = 0; i < this.monthList.length; i++) {
      const monthData = this.monthList[i];
      const updatedDays: DayData[] = [];
      let monthUpdated = false;

      for (let j = 0; j < monthData.days.length; j++) {
        const dayData = monthData.days[j];
        const newIsSelected = this.selectedDates.has(dayData.timestamp);
        
        if (newIsSelected !== dayData.isSelected) {
          monthUpdated = true;
        }
        
        const updatedDayData: DayData = {
          day: dayData.day,
          timestamp: dayData.timestamp,
          isSelected: newIsSelected,
          isFuture: dayData.isFuture,
          isInRange: dayData.isInRange,
          hasNetworkData: dayData.hasNetworkData
        };
        updatedDays.push(updatedDayData);
      }

      if (monthUpdated) {
        // 重新生成周数据
        const weeks = this.generateWeeksData(monthData.year, monthData.month, updatedDays);
        const updatedMonthData: MonthData = {
          year: monthData.year,
          month: monthData.month,
          days: updatedDays,
          weeks: weeks
        };
        newMonthList.push(updatedMonthData);
      } else {
        newMonthList.push(monthData);
      }
    }

    // 触发@State更新
    this.monthList = newMonthList;
  }
  
  // 更新日期选中状态
  private updateDaySelection(timestamp: number) {
    // 创建新的月份列表以触发@State更新
    const newMonthList: MonthData[] = [];
    
    for (let i = 0; i < this.monthList.length; i++) {
      const monthData = this.monthList[i];
      let monthUpdated = false;
      const updatedDays: DayData[] = [];
      
      for (let j = 0; j < monthData.days.length; j++) {
        const dayData = monthData.days[j];
        
        if (dayData.timestamp === timestamp) {
          // 更新目标日期
          const updatedDayData: DayData = {
            day: dayData.day,
            timestamp: dayData.timestamp,
            isSelected: this.selectedDates.has(timestamp),
            isFuture: dayData.isFuture,
            isInRange: dayData.isInRange,
            hasNetworkData: dayData.hasNetworkData
          };
          updatedDays.push(updatedDayData);
          monthUpdated = true;
        } else {
          updatedDays.push(dayData);
        }
      }
      
      if (monthUpdated) {
        // 重新生成周数据
        const weeks = this.generateWeeksData(monthData.year, monthData.month, updatedDays);
        const updatedMonthData: MonthData = {
          year: monthData.year,
          month: monthData.month,
          days: updatedDays,
          weeks: weeks
        };
        newMonthList.push(updatedMonthData);
      } else {
        newMonthList.push(monthData);
      }
    }
    
    // 触发@State更新
    this.monthList = newMonthList;
  }
  
  // 滑动到指定索引时加载更多月份
  private onScrollIndex = (start: number, end: number, center: number) => {
    // 当滑动到接近开头时，提前加载更多历史月份
    // 使用更保守的触发条件，确保maintainVisibleContentPosition生效
    if (start <= 1 && !this.isLoadingMore) {
      this.loadMoreHistoryMonthsWithMaintainPosition(center);
    }
    
    // 更新当前显示的月份
    this.currentDisplayMonth = center;
  }
  
  // 防止重复加载的标志
  private isLoadingMore: boolean = false;
  
  // 使用maintainVisibleContentPosition加载更多历史月份
  private loadMoreHistoryMonthsWithMaintainPosition(currentCenter: number) {
    // 防止重复加载
    if (this.isLoadingMore) {
      return;
    }
    
    this.isLoadingMore = true;
    console.log('Loading more history months with maintainVisibleContentPosition...');
    
    const firstMonth = this.monthList[0];
    const firstDate = new Date(firstMonth.year, firstMonth.month, 1);
    
    // 检查是否已经到达2010年1月
    if (firstDate.getFullYear() <= 2010 && firstDate.getMonth() <= 0) {
      console.log('Already reached 2010-01, no more data to load');
      this.isLoadingMore = false;
      return;
    }
    
    // 使用requestAnimationFrame确保在下一帧执行，配合maintainVisibleContentPosition
    setTimeout(() => {
      const newMonths: MonthData[] = [];
      
      // 添加6个月的历史数据
      for (let i = 1; i <= 6; i++) {
        const targetDate = new Date(firstDate.getFullYear(), firstDate.getMonth() - i, 1);
        
        // 检查是否已经到达2010年1月
        if (targetDate.getFullYear() < 2010 || 
            (targetDate.getFullYear() === 2010 && targetDate.getMonth() < 0)) {
          break;
        }
        
        const monthData = this.generateMonthData(targetDate.getFullYear(), targetDate.getMonth());
        newMonths.unshift(monthData); // 添加到数组开头
      }
      
      if (newMonths.length > 0) {
        // 关键：在显示区域外（列表开头）插入新数据
        // maintainVisibleContentPosition会自动保持当前可见内容的位置
        const combinedList: MonthData[] = [];
        
        // 先添加新的历史月份（插入到显示区域外）
        for (let i = 0; i < newMonths.length; i++) {
          combinedList.push(newMonths[i]);
        }
        
        // 再添加原有的月份
        for (let i = 0; i < this.monthList.length; i++) {
          combinedList.push(this.monthList[i]);
        }
        
        // 更新列表数据 - maintainVisibleContentPosition会自动处理位置保持
        this.monthList = combinedList;
        
        console.log(`Loaded ${newMonths.length} more months with maintainVisibleContentPosition, total: ${this.monthList.length}`);
      }
      
      this.isLoadingMore = false;
    }, 0); // 使用最小延迟，让maintainVisibleContentPosition发挥作用
  }
  
  
  build() {
    Column() {
      // 头部信息
      Row() {
        Text('记录经期')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        
        Blank()
        
        Button('回到今天')
          .backgroundColor('#FF69B4')
          .fontColor(Color.White)
          .borderRadius(20)
          .onClick(() => {
            // 滑动到当前月份（应该在列表最后）
            const now = new Date();
            const currentYear = now.getFullYear();
            const currentMonth = now.getMonth();
            
            // 查找当前月份或下个月（因为范围是下个月开始）
            const targetIndex = this.monthList.findIndex(month => 
              (month.year === currentYear && month.month === currentMonth) ||
              (month.year === currentYear && month.month === currentMonth + 1)
            );
            
            if (targetIndex >= 0) {
              this.listScroller.scrollToIndex(targetIndex);
            } else {
              // 如果没找到，滚动到列表末尾
              this.listScroller.scrollToIndex(this.monthList.length - 1);
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      
      // 提示信息
      Row() {
        Text('☀️')
          .fontSize(16)
        Text('点击日期即可添加/删除/编辑经期')
          .fontSize(12)
          .fontColor('#666')
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .backgroundColor('#FFF5E6')
      .borderRadius(8)
      .margin({ left: 16, right: 16 })
      
      // 星期标题
      Row() {
        ForEach(['周一', '周二', '周三', '周四', '周五', '周六', '周日'], (day: string) => {
          Text(day)
            .fontSize(12)
            .fontColor('#999')
            .width('14.28%')
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      
      // 月份列表
      List({ scroller: this.listScroller }) {
        ForEach(this.monthList, (monthData: MonthData, monthIndex: number) => {
          ListItem() {
            this.MonthView(monthData)
          }
          .reuseId(`month-${monthData.year}-${monthData.month}`)
        }, (monthData: MonthData) => `${monthData.year}-${monthData.month}`)
      }
      .layoutWeight(1)
      .onScrollIndex(this.onScrollIndex)
      .cachedCount(5) // 缓存5个月的数据
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring) // 添加弹性边缘效果
      .maintainVisibleContentPosition(true) // 保持可见内容位置不变
      .onReachStart(() => {
        // 到达顶部时的处理
        console.log('Reached start of list');
      })
      
      // 加载指示器
      if (this.isLoading || this.isLoadingMore) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text(this.isLoadingMore ? '加载更多历史数据...' : '加载中...')
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 8 })
        }
        .padding(16)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
  
  // 月份视图组件
  @Builder
  MonthView(monthData: MonthData) {
    Column() {
      // 月份标题
      Text(`${monthData.year}年${monthData.month + 1}月`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .width('100%')
        .textAlign(TextAlign.Center)
      
      // 日期网格
      Column() {
        ForEach(monthData.weeks, (week: (DayData | null)[], weekIndex: number) => {
          Row() {
            ForEach(week, (dayData: DayData | null, dayIndex: number) => {
              if (dayData) {
                this.DayView(dayData)
              } else {
                // 空白日期
                Text('')
                  .width('14.28%')
                  .height(40)
              }
            }, (dayData: DayData | null, index: number) => `${weekIndex}-${index}`)
          }
          .width('100%')
        }, (week: (DayData | null)[], index: number) => `week-${index}`)
      }
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 4, bottom: 4 })
  }
  
  // 单个日期视图
  @Builder
  DayView(dayData: DayData) {
    Stack() {
      // 背景圆圈
      if (dayData.isSelected) {
        Circle()
          .width(32)
          .height(32)
          .fill('#FF69B4')
      }
      
      // 日期数字
      Text(dayData.day.toString())
        .fontSize(14)
        .fontColor(dayData.isSelected ? Color.White : Color.Black)
        .fontWeight(dayData.isSelected ? FontWeight.Bold : FontWeight.Normal)
      
      // 网络数据指示点
      if (dayData.hasNetworkData) {
        Circle()
          .width(4)
          .height(4)
          .fill('#FF69B4')
          .position({ x: '70%', y: '20%' })
      }
    }
    .width('14.28%')
    .height(40)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.onDateClick(dayData))
    .opacity(dayData.isFuture && !dayData.isInRange ? 0.3 : 1.0)
    .backgroundColor(dayData.isSelected ? '#FF69B4' : Color.Transparent)
    .borderRadius(16)
  }
  
  
  // 公共方法：设置配置
  public setConfig(config: DatePickerConfig) {
    // 手动合并配置对象
    if (config.selectableDates !== undefined) {
      this.config.selectableDates = config.selectableDates;
    }
    if (config.defaultSelectedRange !== undefined) {
      this.config.defaultSelectedRange = config.defaultSelectedRange;
    }
    if (config.futureSelectedState !== undefined) {
      this.config.futureSelectedState = config.futureSelectedState;
    }
    if (config.onDataLoad !== undefined) {
      this.config.onDataLoad = config.onDataLoad;
    }
    if (config.autoSelectDays !== undefined) {
      this.config.autoSelectDays = config.autoSelectDays;
    }
    if (config.smartSelectionMode !== undefined) {
      this.config.smartSelectionMode = config.smartSelectionMode;
    }
    
    // 重新初始化
    if (config.selectableDates) {
      let minDate = config.selectableDates[0];
      let maxDate = config.selectableDates[0];
      
      for (let i = 1; i < config.selectableDates.length; i++) {
        if (config.selectableDates[i] < minDate) {
          minDate = config.selectableDates[i];
        }
        if (config.selectableDates[i] > maxDate) {
          maxDate = config.selectableDates[i];
        }
      }
      
      this.selectableRange = [minDate, maxDate];
    }
    
    if (config.defaultSelectedRange) {
      this.selectedDates.clear();
      const start = config.defaultSelectedRange[0];
      const end = config.defaultSelectedRange[1];
      for (let timestamp = start; timestamp <= end; timestamp += 24 * 60 * 60 * 1000) {
        this.selectedDates.add(timestamp);
      }
    }
  }
  
  // 公共方法：获取选中的日期
  public getSelectedDates(): number[] {
    const result: number[] = [];
    this.selectedDates.forEach(timestamp => {
      result.push(timestamp);
    });
    return result;
  }
  
  // 公共方法：清除所有选中
  public clearSelection() {
    this.selectedDates.clear();
    this.updateAllMonthsSelection();
  }
  
  // 更新所有月份的选中状态
  private updateAllMonthsSelection() {
    const newMonthList: MonthData[] = [];
    
    for (let i = 0; i < this.monthList.length; i++) {
      const monthData = this.monthList[i];
      const updatedDays: DayData[] = [];
      
      for (let j = 0; j < monthData.days.length; j++) {
        const dayData = monthData.days[j];
        const updatedDayData: DayData = {
          day: dayData.day,
          timestamp: dayData.timestamp,
          isSelected: this.selectedDates.has(dayData.timestamp),
          isFuture: dayData.isFuture,
          isInRange: dayData.isInRange,
          hasNetworkData: dayData.hasNetworkData
        };
        updatedDays.push(updatedDayData);
      }
      
      // 重新生成周数据
      const weeks = this.generateWeeksData(monthData.year, monthData.month, updatedDays);
      
      const updatedMonthData: MonthData = {
        year: monthData.year,
        month: monthData.month,
        days: updatedDays,
        weeks: weeks
      };
      
      newMonthList.push(updatedMonthData);
    }
    
    this.monthList = newMonthList;
  }
}