# 日期自动选择功能说明

## 🎯 功能概述

在原有日期选择器的基础上，新增了点击某个日期自动选中后续几天的功能，支持两种模式：
1. **普通模式**：点击日期自动选中指定天数
2. **智能模式**：智能选中日期范围

## ⚙️ 配置选项

### 新增配置参数

```typescript
interface DatePickerConfig {
  // ... 原有配置
  
  // 点击日期时自动选中后续天数（默认为0，不自动选中）
  autoSelectDays?: number;
  
  // 是否启用智能选择模式（默认false）
  smartSelectionMode?: boolean;
}
```

## 🔧 使用方法

### 1. 普通自动选择模式

```typescript
const config: DatePickerConfig = {
  autoSelectDays: 5, // 点击日期自动选中后续5天
  smartSelectionMode: false // 普通模式
};
```

**行为特点：**
- ✅ 点击未选中日期：选中当前日期 + 后续N天
- ✅ 点击已选中日期：取消连续选中的范围
- ✅ 自动跳过不可选择的日期
- ✅ 尊重未来日期的选择限制

### 2. 智能选择模式

```typescript
const config: DatePickerConfig = {
  autoSelectDays: 5, // 智能模式的默认天数
  smartSelectionMode: true // 启用智能模式
};
```

**行为特点：**
- 🧠 点击未选中日期：智能选中到最近已选日期的范围
- 🧠 点击已选中日期：取消整个连续范围
- 🧠 自动检测14天内的最近选中日期
- 🧠 如果没有最近日期，按普通模式选中

## 📊 功能对比

| 特性 | 普通模式 | 智能模式 |
|------|----------|----------|
| 选中逻辑 | 固定天数 | 智能范围 |
| 取消逻辑 | 连续范围 | 整个范围 |
| 适用场景 | 固定周期 | 灵活选择 |
| 用户体验 | 简单直接 | 智能便捷 |

## 🎮 交互示例

### 普通模式示例（autoSelectDays: 3）

```
初始状态: [ ][ ][ ][ ][ ][ ][ ]
点击第2天: [ ][●][●][●][ ][ ][ ]  // 自动选中2,3,4天
点击第6天: [ ][●][●][●][ ][●][●]  // 自动选中6,7天（第8天超出范围）
点击第3天: [ ][●][ ][ ][ ][●][●]  // 取消选中2,3,4天的连续范围
```

### 智能模式示例

```
初始状态: [ ][ ][ ][ ][ ][ ][ ]
点击第2天: [ ][●][ ][ ][ ][ ][ ]  // 选中第2天
点击第5天: [ ][●][●][●][●][ ][ ]  // 智能选中2-5天的范围
点击第7天: [ ][●][●][●][●][ ][●]  // 选中第7天（距离第5天较远）
点击第6天: [ ][●][●][●][●][●][●]  // 智能连接5-7天
点击第4天: [ ][ ][ ][ ][ ][ ][ ]  // 取消整个连续范围2-7天
```

## 🔍 核心算法

### 1. 普通选择算法

```typescript
private selectDateRange(startTimestamp: number) {
  const autoSelectDays = this.config.autoSelectDays || 0;
  const oneDayMs = 24 * 60 * 60 * 1000;
  
  // 选中起始日期
  this.selectedDates.add(startTimestamp);
  
  // 选中后续几天
  for (let i = 1; i <= autoSelectDays; i++) {
    const nextDayTimestamp = startTimestamp + (i * oneDayMs);
    
    if (this.isDateInSelectableRange(nextDayTimestamp) && 
        this.isDateAllowedToSelect(nextDayTimestamp)) {
      this.selectedDates.add(nextDayTimestamp);
    }
  }
}
```

### 2. 智能选择算法

```typescript
private smartSelect(clickedTimestamp: number) {
  // 查找最近的选中日期
  const nearestSelected = this.findNearestSelectedDate(clickedTimestamp);
  
  if (nearestSelected) {
    // 选中范围：从最小到最大时间戳
    const startTime = Math.min(clickedTimestamp, nearestSelected);
    const endTime = Math.max(clickedTimestamp, nearestSelected);
    
    for (let timestamp = startTime; timestamp <= endTime; timestamp += oneDayMs) {
      if (this.isDateInSelectableRange(timestamp)) {
        this.selectedDates.add(timestamp);
      }
    }
  } else {
    // 没有最近日期，按普通模式选中
    this.selectDateRange(clickedTimestamp);
  }
}
```

### 3. 最近日期查找算法

```typescript
private findNearestSelectedDate(targetTimestamp: number): number | null {
  const oneDayMs = 24 * 60 * 60 * 1000;
  const maxSearchDays = 14; // 最多搜索14天
  
  // 向前和向后同时搜索
  for (let i = 1; i <= maxSearchDays; i++) {
    const prevDay = targetTimestamp - (i * oneDayMs);
    const nextDay = targetTimestamp + (i * oneDayMs);
    
    if (this.selectedDates.has(prevDay)) return prevDay;
    if (this.selectedDates.has(nextDay)) return nextDay;
  }
  
  return null;
}
```

## 💡 使用建议

### 经期记录场景
```typescript
const periodConfig: DatePickerConfig = {
  autoSelectDays: 5, // 经期通常5-7天
  smartSelectionMode: false, // 使用固定天数更合适
  futureSelectedState: false // 不允许选择未来日期
};
```

### 假期安排场景
```typescript
const vacationConfig: DatePickerConfig = {
  autoSelectDays: 3,
  smartSelectionMode: true, // 智能模式适合灵活安排
  futureSelectedState: true // 允许选择未来日期
};
```

### 日程规划场景
```typescript
const scheduleConfig: DatePickerConfig = {
  autoSelectDays: 1, // 单天事件
  smartSelectionMode: true, // 智能连接相关日期
  futureSelectedState: true
};
```

## ⚠️ 注意事项

### 1. 性能考虑
- 批量更新UI，避免频繁重绘
- 智能搜索限制在14天内
- 使用缓存减少重复计算

### 2. 用户体验
- 提供视觉反馈显示选中范围
- 支持取消操作的直观逻辑
- 配置选项易于理解和使用

### 3. 边界处理
- 自动跳过不可选择的日期
- 处理月份边界的日期选择
- 正确处理未来日期的限制

## 🚀 扩展功能

### 1. 自定义选择策略
```typescript
// 未来可扩展的选择策略
interface SelectionStrategy {
  selectRange(startDate: number, config: DatePickerConfig): number[];
  deselectRange(startDate: number, selectedDates: Set<number>): number[];
}
```

### 2. 选择模式预设
```typescript
// 预设的选择模式
const SELECTION_PRESETS = {
  PERIOD: { autoSelectDays: 5, smartSelectionMode: false },
  VACATION: { autoSelectDays: 3, smartSelectionMode: true },
  SINGLE: { autoSelectDays: 0, smartSelectionMode: false }
};
```

这个自动选择功能大大提升了日期选择的效率，特别适合需要选择连续日期的场景！