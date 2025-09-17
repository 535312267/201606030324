/**
 * 交互式刻度尺组件
 * 支持点击选择值、拖拽操作等交互功能
 */

export interface InteractiveRulerOptions {
  width?: number | string;
  height?: number | string;
  direction?: 'horizontal' | 'vertical';
  minValue?: number;
  maxValue?: number;
  step?: number;
  majorStep?: number;
  showLabels?: boolean;
  backgroundColor?: string | Color;
  rulerColor?: string | Color;
  textColor?: string | Color;
  selectedColor?: string | Color;
  fontSize?: number;
  rulerWidth?: number;
  majorTickHeight?: number;
  minorTickHeight?: number;
  showPointer?: boolean;
  pointerColor?: string | Color;
  enableTouch?: boolean;
  onValueChange?: (value: number) => void;
}

@Component
export struct InteractiveRulerComponent {
  @Prop options: InteractiveRulerOptions = {};
  @State selectedValue: number = 0;
  @State pointerPosition: number = 0;
  
  // 默认配置
  private defaultOptions: InteractiveRulerOptions = {
    width: '100%',
    height: 60,
    direction: 'horizontal',
    minValue: 0,
    maxValue: 100,
    step: 1,
    majorStep: 10,
    showLabels: true,
    backgroundColor: Color.White,
    rulerColor: '#333333',
    textColor: '#333333',
    selectedColor: '#FF5722',
    fontSize: 12,
    rulerWidth: 1,
    majorTickHeight: 20,
    minorTickHeight: 10,
    showPointer: true,
    pointerColor: '#FF5722',
    enableTouch: true
  };

  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  aboutToAppear() {
    this.selectedValue = this.getOption('minValue');
  }

  private getOption<K extends keyof InteractiveRulerOptions>(key: K): NonNullable<InteractiveRulerOptions[K]> {
    return this.options[key] ?? this.defaultOptions[key]!;
  }

  build() {
    Column() {
      // 显示当前选中值
      if (this.getOption('showPointer')) {
        Text(`当前值: ${this.selectedValue.toFixed(2)}`)
          .fontSize(16)
          .fontColor(this.getOption('selectedColor'))
          .margin({ bottom: 10 })
      }

      // 刻度尺画布
      Canvas(this.canvasContext)
        .width(this.getOption('width'))
        .height(this.getOption('height'))
        .backgroundColor(this.getOption('backgroundColor'))
        .onReady(() => {
          this.drawRuler();
        })
        .onTouch((event: TouchEvent) => {
          if (this.getOption('enableTouch')) {
            this.handleTouch(event);
          }
        })

      // 数值调节按钮
      if (this.getOption('enableTouch')) {
        Row() {
          Button('-')
            .width(40)
            .height(30)
            .fontSize(16)
            .onClick(() => {
              this.adjustValue(-this.getOption('step'));
            })

          Text(`${this.selectedValue.toFixed(2)}`)
            .fontSize(14)
            .margin({ left: 10, right: 10 })
            .width(60)
            .textAlign(TextAlign.Center)

          Button('+')
            .width(40)
            .height(30)
            .fontSize(16)
            .onClick(() => {
              this.adjustValue(this.getOption('step'));
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })
      }
    }
  }

  private handleTouch(event: TouchEvent) {
    if (event.type === TouchType.Down || event.type === TouchType.Move) {
      const touch = event.touches[0];
      const value = this.calculateValueFromPosition(touch.x, touch.y);
      this.updateSelectedValue(value);
    }
  }

  private calculateValueFromPosition(x: number, y: number): number {
    const minValue = this.getOption('minValue');
    const maxValue = this.getOption('maxValue');
    const direction = this.getOption('direction');
    
    let ratio: number;
    
    if (direction === 'horizontal') {
      const width = this.canvasContext.width;
      ratio = Math.max(0, Math.min(1, x / width));
    } else {
      const height = this.canvasContext.height;
      ratio = Math.max(0, Math.min(1, 1 - y / height));
    }
    
    const value = minValue + ratio * (maxValue - minValue);
    const step = this.getOption('step');
    return Math.round(value / step) * step;
  }

  private adjustValue(delta: number) {
    const newValue = this.selectedValue + delta;
    this.updateSelectedValue(newValue);
  }

  private updateSelectedValue(value: number) {
    const minValue = this.getOption('minValue');
    const maxValue = this.getOption('maxValue');
    
    this.selectedValue = Math.max(minValue, Math.min(maxValue, value));
    this.drawRuler();
    
    // 触发回调
    const onValueChange = this.getOption('onValueChange');
    if (onValueChange) {
      onValueChange(this.selectedValue);
    }
  }

  private drawRuler() {
    if (this.getOption('direction') === 'horizontal') {
      this.drawHorizontalRuler();
    } else {
      this.drawVerticalRuler();
    }
  }

  private drawHorizontalRuler() {
    const ctx = this.canvasContext;
    const width = ctx.width;
    const height = ctx.height;
    
    const minValue = this.getOption('minValue');
    const maxValue = this.getOption('maxValue');
    const step = this.getOption('step');
    const majorStep = this.getOption('majorStep');
    const showLabels = this.getOption('showLabels');
    const rulerColor = this.getOption('rulerColor');
    const selectedColor = this.getOption('selectedColor');
    const textColor = this.getOption('textColor');
    const fontSize = this.getOption('fontSize');
    const rulerWidth = this.getOption('rulerWidth');
    const majorTickHeight = this.getOption('majorTickHeight');
    const minorTickHeight = this.getOption('minorTickHeight');

    // 清空画布
    ctx.clearRect(0, 0, width, height);
    
    // 设置样式
    ctx.lineWidth = rulerWidth;
    ctx.font = `${fontSize}px sans-serif`;
    ctx.textAlign = 'center';

    // 绘制主刻度线
    ctx.strokeStyle = rulerColor;
    ctx.beginPath();
    ctx.moveTo(0, height - majorTickHeight);
    ctx.lineTo(width, height - majorTickHeight);
    ctx.stroke();

    const range = maxValue - minValue;
    const pixelsPerUnit = width / range;

    // 绘制刻度
    for (let value = minValue; value <= maxValue; value += step) {
      const x = (value - minValue) * pixelsPerUnit;
      const isMajorTick = value % majorStep === 0;
      const tickHeight = isMajorTick ? majorTickHeight : minorTickHeight;
      const isSelected = Math.abs(value - this.selectedValue) < step / 2;

      // 设置颜色
      ctx.strokeStyle = isSelected ? selectedColor : rulerColor;
      ctx.fillStyle = isSelected ? selectedColor : textColor;

      // 绘制刻度线
      ctx.beginPath();
      ctx.moveTo(x, height - tickHeight);
      ctx.lineTo(x, height);
      ctx.stroke();

      // 绘制标签
      if (isMajorTick && showLabels) {
        ctx.fillText(value.toString(), x, height - majorTickHeight - 5);
      }
    }

    // 绘制指针
    if (this.getOption('showPointer')) {
      const pointerX = (this.selectedValue - minValue) * pixelsPerUnit;
      this.drawPointer(pointerX, height, true);
    }
  }

  private drawVerticalRuler() {
    const ctx = this.canvasContext;
    const width = ctx.width;
    const height = ctx.height;
    
    const minValue = this.getOption('minValue');
    const maxValue = this.getOption('maxValue');
    const step = this.getOption('step');
    const majorStep = this.getOption('majorStep');
    const showLabels = this.getOption('showLabels');
    const rulerColor = this.getOption('rulerColor');
    const selectedColor = this.getOption('selectedColor');
    const textColor = this.getOption('textColor');
    const fontSize = this.getOption('fontSize');
    const rulerWidth = this.getOption('rulerWidth');
    const majorTickHeight = this.getOption('majorTickHeight');
    const minorTickHeight = this.getOption('minorTickHeight');

    // 清空画布
    ctx.clearRect(0, 0, width, height);
    
    // 设置样式
    ctx.lineWidth = rulerWidth;
    ctx.font = `${fontSize}px sans-serif`;
    ctx.textAlign = 'center';

    // 绘制主刻度线
    ctx.strokeStyle = rulerColor;
    ctx.beginPath();
    ctx.moveTo(majorTickHeight, 0);
    ctx.lineTo(majorTickHeight, height);
    ctx.stroke();

    const range = maxValue - minValue;
    const pixelsPerUnit = height / range;

    // 绘制刻度（从下往上）
    for (let value = minValue; value <= maxValue; value += step) {
      const y = height - (value - minValue) * pixelsPerUnit;
      const isMajorTick = value % majorStep === 0;
      const tickHeight = isMajorTick ? majorTickHeight : minorTickHeight;
      const isSelected = Math.abs(value - this.selectedValue) < step / 2;

      // 设置颜色
      ctx.strokeStyle = isSelected ? selectedColor : rulerColor;
      ctx.fillStyle = isSelected ? selectedColor : textColor;

      // 绘制刻度线
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(tickHeight, y);
      ctx.stroke();

      // 绘制标签
      if (isMajorTick && showLabels) {
        ctx.save();
        ctx.translate(majorTickHeight + 15, y);
        ctx.rotate(-Math.PI / 2);
        ctx.fillText(value.toString(), 0, 0);
        ctx.restore();
      }
    }

    // 绘制指针
    if (this.getOption('showPointer')) {
      const pointerY = height - (this.selectedValue - minValue) * pixelsPerUnit;
      this.drawPointer(majorTickHeight, pointerY, false);
    }
  }

  private drawPointer(x: number, y: number, isHorizontal: boolean) {
    const ctx = this.canvasContext;
    const pointerColor = this.getOption('pointerColor');
    
    ctx.fillStyle = pointerColor;
    ctx.strokeStyle = pointerColor;
    ctx.lineWidth = 2;

    if (isHorizontal) {
      // 水平刻度尺的指针（向上箭头）
      ctx.beginPath();
      ctx.moveTo(x, y - 5);
      ctx.lineTo(x - 6, y - 15);
      ctx.lineTo(x + 6, y - 15);
      ctx.closePath();
      ctx.fill();
      
      // 指针线
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, y - 5);
      ctx.stroke();
    } else {
      // 垂直刻度尺的指针（向右箭头）
      ctx.beginPath();
      ctx.moveTo(x + 5, y);
      ctx.lineTo(x + 15, y - 6);
      ctx.lineTo(x + 15, y + 6);
      ctx.closePath();
      ctx.fill();
      
      // 指针线
      ctx.beginPath();
      ctx.moveTo(x + 5, y);
      ctx.lineTo(ctx.width, y);
      ctx.stroke();
    }
  }
}