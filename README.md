# 鸿蒙刻度尺组件

一个功能完整的鸿蒙刻度尺组件，支持水平和垂直方向，可自定义样式和刻度设置。

## 功能特性

### 基础刻度尺组件
- ✅ 支持水平和垂直两个方向
- ✅ 可自定义刻度范围（支持负数）
- ✅ 可配置主刻度和次刻度间距
- ✅ 支持自定义颜色、字体大小等样式
- ✅ 响应式布局，适配不同屏幕尺寸
- ✅ 高性能Canvas绘制
- ✅ TypeScript类型安全

### 交互式刻度尺组件
- ✅ 支持触摸点击选择数值
- ✅ 支持拖拽操作实时调整
- ✅ 实时数值显示和反馈
- ✅ 按钮精确微调功能
- ✅ 值变化回调事件
- ✅ 可视化指针和高亮显示
- ✅ 完全可配置的交互行为

## 快速开始

### 1. 导入组件

```typescript
// 基础刻度尺组件
import { RulerComponent, RulerOptions } from '../components/RulerComponent';

// 交互式刻度尺组件
import { InteractiveRulerComponent, InteractiveRulerOptions } from '../components/InteractiveRulerComponent';
```

### 2. 基础使用

```typescript
@Component
struct MyPage {
  build() {
    Column() {
      RulerComponent({
        options: {
          width: '100%',
          height: 60,
          direction: 'horizontal',
          minValue: 0,
          maxValue: 100
        } as RulerOptions
      })
    }
  }
}
```

## API 参考

### RulerOptions 接口（基础刻度尺）

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| width | number \| string | '100%' | 组件宽度 |
| height | number \| string | 60 | 组件高度 |
| direction | 'horizontal' \| 'vertical' | 'horizontal' | 刻度尺方向 |
| minValue | number | 0 | 最小值 |
| maxValue | number | 100 | 最大值 |
| step | number | 1 | 刻度步长 |
| majorStep | number | 10 | 主刻度步长 |
| showLabels | boolean | true | 是否显示标签 |
| backgroundColor | string \| Color | Color.White | 背景色 |
| rulerColor | string \| Color | '#333333' | 刻度线颜色 |
| textColor | string \| Color | '#333333' | 文字颜色 |
| fontSize | number | 12 | 字体大小 |
| rulerWidth | number | 1 | 刻度线宽度 |
| majorTickHeight | number | 20 | 主刻度线高度 |
| minorTickHeight | number | 10 | 次刻度线高度 |

### InteractiveRulerOptions 接口（交互式刻度尺）

继承 RulerOptions 的所有属性，并添加以下交互相关属性：

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| selectedColor | string \| Color | '#FF5722' | 选中状态颜色 |
| pointerColor | string \| Color | '#FF5722' | 指针颜色 |
| showPointer | boolean | true | 是否显示指针 |
| enableTouch | boolean | true | 是否启用触摸交互 |
| onValueChange | (value: number) => void | - | 值变化回调函数 |

## 使用示例

### 水平刻度尺

```typescript
RulerComponent({
  options: {
    width: '90%',
    height: 60,
    direction: 'horizontal',
    minValue: 0,
    maxValue: 100,
    step: 1,
    majorStep: 10,
    showLabels: true,
    backgroundColor: '#f5f5f5',
    rulerColor: '#333333',
    textColor: '#666666'
  } as RulerOptions
})
```

### 垂直刻度尺

```typescript
RulerComponent({
  options: {
    width: 80,
    height: 300,
    direction: 'vertical',
    minValue: 0,
    maxValue: 200,
    step: 5,
    majorStep: 20,
    showLabels: true,
    rulerColor: '#4CAF50',
    textColor: '#4CAF50'
  } as RulerOptions
})
```

### 精密刻度尺（支持小数）

```typescript
RulerComponent({
  options: {
    width: '90%',
    height: 80,
    direction: 'horizontal',
    minValue: 0,
    maxValue: 50,
    step: 0.5,
    majorStep: 5,
    showLabels: true,
    rulerColor: '#2196F3',
    textColor: '#2196F3',
    majorTickHeight: 25,
    minorTickHeight: 15
  } as RulerOptions
})
```

### 负数范围刻度尺

```typescript
RulerComponent({
  options: {
    width: 100,
    height: 300,
    direction: 'vertical',
    minValue: -50,
    maxValue: 150,
    step: 2,
    majorStep: 25,
    showLabels: true,
    rulerColor: '#FF5722',
    textColor: '#FF5722'
  } as RulerOptions
})
```

### 交互式刻度尺

```typescript
// 带触摸交互的水平刻度尺
InteractiveRulerComponent({
  options: {
    width: '90%',
    height: 80,
    direction: 'horizontal',
    minValue: 0,
    maxValue: 100,
    step: 1,
    majorStep: 10,
    showLabels: true,
    backgroundColor: '#f0f8ff',
    selectedColor: '#FF6B35',
    pointerColor: '#FF6B35',
    showPointer: true,
    enableTouch: true,
    onValueChange: (value: number) => {
      console.log('当前选中值:', value);
    }
  } as InteractiveRulerOptions
})
```

## 项目结构

```
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── components/
│   │   │   │   ├── RulerComponent.ets           # 基础刻度尺组件
│   │   │   │   └── InteractiveRulerComponent.ets # 交互式刻度尺组件
│   │   │   ├── pages/
│   │   │   │   └── Index.ets             # 演示页面
│   │   │   └── entryability/
│   │   │       └── EntryAbility.ts       # 应用入口
│   │   ├── resources/                    # 资源文件
│   │   └── module.json5                  # 模块配置
│   └── hvigorfile.ts
├── build-profile.json5                   # 构建配置
└── README.md
```

## 运行项目

1. 确保已安装DevEco Studio和HarmonyOS SDK
2. 在DevEco Studio中打开项目
3. 连接HarmonyOS设备或启动模拟器
4. 点击运行按钮或使用快捷键Ctrl+R

## 技术实现

- 使用Canvas API进行高性能绘制
- 支持响应式布局和自适应尺寸
- TypeScript类型安全保障
- 模块化设计，易于扩展和维护
- 事件驱动的交互机制
- 高精度触摸位置计算
- 实时绘制和动画效果

## 许可证

MIT License