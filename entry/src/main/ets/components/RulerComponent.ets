/**
 * 刻度尺组件
 * 支持水平和垂直方向，可自定义刻度间距、样式等
 */

export interface RulerOptions {
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
  fontSize?: number;
  rulerWidth?: number;
  majorTickHeight?: number;
  minorTickHeight?: number;
}

@Component
export struct RulerComponent {
  @Prop options: RulerOptions = {};
  
  // 默认配置
  private defaultOptions: RulerOptions = {
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
    fontSize: 12,
    rulerWidth: 1,
    majorTickHeight: 20,
    minorTickHeight: 10
  };

  private getOption<K extends keyof RulerOptions>(key: K): NonNullable<RulerOptions[K]> {
    return this.options[key] ?? this.defaultOptions[key]!;
  }

  build() {
    if (this.getOption('direction') === 'horizontal') {
      this.buildHorizontalRuler();
    } else {
      this.buildVerticalRuler();
    }
  }

  @Builder
  buildHorizontalRuler() {
    Column() {
      Canvas(this.canvasContext)
        .width(this.getOption('width'))
        .height(this.getOption('height'))
        .backgroundColor(this.getOption('backgroundColor'))
        .onReady(() => {
          this.drawHorizontalRuler();
        })
    }
  }

  @Builder
  buildVerticalRuler() {
    Row() {
      Canvas(this.canvasContext)
        .width(this.getOption('width'))
        .height(this.getOption('height'))
        .backgroundColor(this.getOption('backgroundColor'))
        .onReady(() => {
          this.drawVerticalRuler();
        })
    }
  }

  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

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
    const textColor = this.getOption('textColor');
    const fontSize = this.getOption('fontSize');
    const rulerWidth = this.getOption('rulerWidth');
    const majorTickHeight = this.getOption('majorTickHeight');
    const minorTickHeight = this.getOption('minorTickHeight');

    // 清空画布
    ctx.clearRect(0, 0, width, height);
    
    // 设置样式
    ctx.strokeStyle = rulerColor;
    ctx.lineWidth = rulerWidth;
    ctx.fillStyle = textColor;
    ctx.font = `${fontSize}px sans-serif`;
    ctx.textAlign = 'center';

    // 绘制主刻度线
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
    const textColor = this.getOption('textColor');
    const fontSize = this.getOption('fontSize');
    const rulerWidth = this.getOption('rulerWidth');
    const majorTickHeight = this.getOption('majorTickHeight');
    const minorTickHeight = this.getOption('minorTickHeight');

    // 清空画布
    ctx.clearRect(0, 0, width, height);
    
    // 设置样式
    ctx.strokeStyle = rulerColor;
    ctx.lineWidth = rulerWidth;
    ctx.fillStyle = textColor;
    ctx.font = `${fontSize}px sans-serif`;
    ctx.textAlign = 'center';

    // 绘制主刻度线
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
  }
}