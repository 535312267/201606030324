# 鸿蒙刻度尺组件

这是一个基于鸿蒙ArkTS开发的可滑动刻度尺组件，具有以下特性：

## 功能特性

- 📏 **精确刻度**: 支持精确的刻度显示和数值读取
- 🎯 **居中对齐**: 刻度线和数值文本完美居中对齐
- 📱 **触摸滑动**: 支持触摸滑动操作，实时更新数值
- 🎨 **美观界面**: 符合鸿蒙设计规范的现代化界面
- ⚡ **高性能**: 基于ArkTS开发，性能优异

## 组件规格

- **尺寸**: 宽345px × 高135px
- **刻度宽度**: 4px
- **普通刻度高度**: 12px
- **主要刻度高度**: 18px（每第5个刻度）
- **数值范围**: 0-10000mL
- **刻度精度**: 每个刻度代表40mL

## 项目结构

```
src/
├── main/
│   ├── ets/
│   │   ├── components/
│   │   │   └── RulerComponent.ets    # 刻度尺组件
│   │   ├── pages/
│   │   │   └── Index.ets             # 示例页面
│   │   └── entryability/
│   │       └── EntryAbility.ets      # 应用入口
│   ├── resources/
│   │   └── base/
│   │       └── profile/
│   │           └── main_pages.json   # 页面配置
│   └── module.json5                  # 模块配置
```

## 使用方法

### 1. 导入组件

```typescript
import { RulerComponent } from '../components/RulerComponent'
```

### 2. 在页面中使用

```typescript
@Entry
@Component
struct Index {
  build() {
    Column() {
      // 使用刻度尺组件
      RulerComponent()
        .margin({ top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
```

## 组件实现原理

### 核心技术栈
- **Stack组件**: 用于层叠布局，实现指示线和数值显示的叠加效果
- **Scroll组件**: 提供水平滚动功能，监听滚动偏移量
- **Column组件**: 创建垂直布局的刻度线
- **ForEach循环**: 动态生成大量刻度元素

### 关键实现
1. **滑动监听**: 通过`onScroll`回调监听滚动偏移量
2. **数值计算**: 根据滚动偏移量实时计算当前刻度值
3. **样式控制**: 每第5个刻度使用不同的高度和样式
4. **居中对齐**: 使用填充空间确保刻度能正确对齐到中心线

## 自定义配置

组件内部提供了多个配置常量，可根据需要调整：

```typescript
private readonly RULER_WIDTH = 345          // 组件宽度
private readonly RULER_HEIGHT = 135         // 组件高度
private readonly SCALE_WIDTH = 4            // 刻度线宽度
private readonly SCALE_HEIGHT_NORMAL = 12   // 普通刻度高度
private readonly SCALE_HEIGHT_MAJOR = 18    // 主要刻度高度
private readonly SCALE_SPACING = 8          // 刻度间距
private readonly SCALE_VALUE_STEP = 40      // 每个刻度的数值步长
```

## 开发环境

- **开发工具**: DevEco Studio
- **API版本**: API 9+
- **语言**: ArkTS
- **框架**: ArkUI

## 运行项目

1. 使用DevEco Studio打开项目
2. 连接鸿蒙设备或启动模拟器
3. 点击运行按钮即可体验刻度尺组件
