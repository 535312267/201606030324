# 鸿蒙日期选择器组件

这是一个为鸿蒙API12环境开发的高性能日期选择器组件，主要用于经期记录等场景。

## 功能特性

### 📅 核心功能
- **年月信息列表**：显示从下个月到2010年1月的所有月份信息
- **日期选择**：点击非未来日期可以选择，支持多选
- **选中状态**：粉色圆圈表示选中，与截图样式一致
- **未来日期处理**：未来日期默认不可点击，但选中范围内的未来日期可自定义选中状态
- **默认显示**：默认展示当前月份

### 🚀 性能优化
- **虚拟滚动**：使用List组件的`maintainVisibleContentPosition`属性
- **懒加载**：通过`onScrollIndex`在滑动时动态加载新月份
- **缓存机制**：月份数据缓存，避免重复计算
- **性能参数**：`cachedCount`设置为3，优化滚动体验

### 🌐 网络集成
- **时间戳匹配**：网络请求返回的毫秒级时间戳与日期匹配
- **自动选中**：匹配的日期自动被选中
- **加载状态**：显示网络请求加载状态
- **数据指示**：有网络数据的日期显示小圆点

### 🎨 UI设计
- **现代化界面**：符合鸿蒙设计规范
- **丝滑体验**：优化的滚动和动画效果
- **响应式布局**：适配不同屏幕尺寸
- **视觉反馈**：清晰的选中状态和交互反馈

## 使用方法

### 基本使用

```typescript
import { DatePickerComponent, DatePickerConfig } from './DatePickerComponent';

@Component
struct MyPage {
  build() {
    Column() {
      DatePickerComponent()
        .layoutWeight(1)
    }
  }
}
```

### 高级配置

```typescript
const config: DatePickerConfig = {
  // 设置默认选中范围
  defaultSelectedRange: [
    Date.now(),
    Date.now() + 7 * 24 * 60 * 60 * 1000
  ],
  // 未来日期的选中状态
  futureSelectedState: true,
  // 网络数据加载回调
  onDataLoad: (timestamps: number[]) => {
    console.log('Network data loaded:', timestamps);
  }
};

// 应用配置
datePickerComponent.setConfig(config);
```

### 公共方法

```typescript
// 获取选中的日期（时间戳数组）
const selectedDates = datePickerComponent.getSelectedDates();

// 清除所有选中
datePickerComponent.clearSelection();

// 设置配置
datePickerComponent.setConfig(config);
```

## 配置参数

### DatePickerConfig 接口

| 参数 | 类型 | 说明 |
|------|------|------|
| `selectableDates` | `number[]` | 可选择的日期范围（时间戳数组） |
| `defaultSelectedRange` | `[number, number]` | 默认选中的日期范围 |
| `futureSelectedState` | `boolean` | 未来日期的选中状态自定义 |
| `onDataLoad` | `(timestamps: number[]) => void` | 网络请求数据回调 |

## 性能特性

### 1. 虚拟滚动
- 使用`List`组件的`maintainVisibleContentPosition`属性
- 支持大量数据的流畅滚动
- 内存使用优化

### 2. 懒加载策略
- 初始加载6个月数据
- 滚动到边界时自动加载更多
- 向上滚动加载历史月份
- 向下滚动加载未来月份（如需要）

### 3. 缓存机制
- 月份数据缓存，避免重复计算
- 使用Map进行高效缓存管理
- 减少CPU使用和提升响应速度

### 4. 渲染优化
- `cachedCount`设置为3，预缓存邻近月份
- 条件渲染减少不必要的组件创建
- 使用`ForEach`的key优化列表渲染

## 网络集成说明

### 数据格式
网络请求返回的数据应为毫秒级时间戳数组：
```typescript
[
  1693526400000, // 2023年9月1日
  1693699200000, // 2023年9月3日
  1693872000000  // 2023年9月5日
]
```

### 自动匹配
- 组件会自动将网络数据的时间戳与日期进行匹配
- 匹配的日期会自动被选中（如果在可选范围内）
- 有网络数据的日期会显示粉色小圆点指示

### 异步加载
```typescript
// 模拟网络请求
private async loadNetworkData() {
  this.isLoading = true;
  
  try {
    // 实际的网络请求
    const response = await fetch('/api/period-data');
    const timestamps = await response.json();
    
    // 更新数据
    timestamps.forEach(timestamp => {
      this.networkDataTimestamps.add(timestamp);
      if (this.isDateInSelectableRange(timestamp)) {
        this.selectedDates.add(timestamp);
      }
    });
    
    this.updateMonthsWithNetworkData();
    
  } catch (error) {
    console.error('Network request failed:', error);
  } finally {
    this.isLoading = false;
  }
}
```

## 技术实现

### 组件架构
- **DatePickerComponent**：主组件，包含所有核心逻辑
- **MonthView**：月份视图Builder
- **DayView**：单个日期视图Builder

### 数据结构
```typescript
interface MonthData {
  year: number;
  month: number;
  days: DayData[];
}

interface DayData {
  day: number;
  timestamp: number;
  isSelected: boolean;
  isFuture: boolean;
  isInRange: boolean;
  hasNetworkData: boolean;
}
```

### 状态管理
- 使用`@State`装饰器管理组件状态
- 集中式的状态更新方法
- 响应式的UI更新

## 注意事项

1. **性能考虑**：大量月份数据时注意内存使用
2. **网络请求**：建议添加错误处理和重试机制
3. **时区处理**：确保时间戳计算的准确性
4. **用户体验**：加载状态和错误提示
5. **可访问性**：考虑添加无障碍支持

## 扩展建议

1. **主题定制**：支持自定义颜色主题
2. **国际化**：支持多语言
3. **手势操作**：添加滑动手势
4. **动画效果**：增强视觉效果
5. **数据持久化**：本地存储选中状态