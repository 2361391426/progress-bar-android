
/**
 * MIT License
 *
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import {
    Descriptor,
    ComponentBuilderContext,
    RNComponentFactory,
    RNOHContext,
    RNViewBase,
    ViewDynamicProps,
    ViewBaseProps,
    ColorSegments,
    convertColorSegmentsToString,
    RNScrollViewManager
} from '@rnoh/react-native-openharmony'
import  {ComWheel,Model} from './ComWheel'
import {
    MaterialProgressBar,
    MaterialProgressStyle,
    CircularComponent
} from "@ohos/materialprogressbar";
import Logger from './Logger'

export const PROGRESS_BAR_TYPE:string = "RNCProgressBar"

const TAG: string = "[RNOH] RNCProgressBar"

export interface ProgressBarProps extends ViewBaseProps {
    styleAttr: string,
    indeterminate: boolean,
    progress: number,
    animating: boolean,
    color: ColorSegments
}


export type ProgressBarAndroidDescriptor = Descriptor<"RNCProgressBar", ProgressBarProps>

@Component
export struct ProgressBarAndroid {
    ctx!: RNOHContext
    tag: number = 0
    @State descriptor: ProgressBarAndroidDescriptor = {} as ProgressBarAndroidDescriptor
    private unregisterDescriptorChangesListener?: () => void = undefined
    @State progressStyle: number = MaterialProgressStyle.MaterialHorizontal
    @State comWheelModel: Model = new Model();
    @State indeterminate: boolean = true;
    @State progress: number = 0;
    @State color: string = '';
    @State bgColor: string = '';

    aboutToAppear() {
        this.descriptor = this.ctx.descriptorRegistry.getDescriptor<ProgressBarAndroidDescriptor>(this.tag)
        this.init()
         Logger.info(TAG," ProgressBarAndroid: props = " + JSON.stringify(this.descriptor.props))
         Logger.info(TAG," ProgressBarAndroid: color = " + convertColorSegmentsToString(this.descriptor.props.color))
        this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
            (newDescriptor) => {
                this.descriptor = (newDescriptor as ProgressBarAndroidDescriptor)
            }
        )

    }

    init() {
        this.indeterminate = true
        this.initColor()
        if (this.descriptor.props.styleAttr === 'Horizontal') {
            if (this.descriptor.props.indeterminate === false) {
                this.indeterminate = false
                this.progress = this.descriptor.props.progress * 100
                this.bgColor = '#26000000'
            }else {
                // 如果为0会没有动画
                this.progress = -1
            }
        } else {
            let diameter = Math.min(this.descriptor.layoutMetrics.frame.size.width,this.descriptor.layoutMetrics.frame.size.height)
            this.comWheelModel.setCircleRadius(diameter * 1.5).setBarWidth(diameter/16).setRimWidth(0).init()
            this.comWheelModel.barColor =  convertColorSegmentsToString(this.descriptor.props.color) as ResourceColor
        }

    }

    aboutToDisappear() {
        this.unregisterDescriptorChangesListener?.()
        this.comWheelModel?.closeTimer()
    }

    initColor() {
        let colorSegments = this.descriptor.props.color
        if (!colorSegments) {
            this.color = '#008577'
            this.bgColor = '#80000000'
        }
        const r = colorSegments[0]
        const g = colorSegments[1]
        const b = colorSegments[2]
        const a = colorSegments[3]
        this.color = `rgba(${Math.round(r * 255)}, ${Math.round(g * 255)}, ${Math.round(
            b * 255
        )}, ${a})`
        this.bgColor = `rgba(${Math.round(r * 255)}, ${Math.round(g * 255)}, ${Math.round(
            b * 255
        )}, ${a * 0.15})`
    }

    build() {
        RNViewBase({
            ctx: this.ctx,
            tag: this.tag,
        }) {
            if (this.descriptor.props.styleAttr === 'Horizontal') {
                MaterialProgressBar({ style: MaterialProgressStyle.MaterialHorizontal,
                    modelBuild: {
                        color: this.color,
                        bgColor: this.bgColor,
                        progress: this.progress >= 0 ? this.progress: undefined,// 设置具体值则不再有动画效果
                        indeterminateAngle: this.indeterminate
                    } })
                    .width('100%')
                    .height('100%')
                    .visibility(this.descriptor.props.animating ? Visibility.Visible : Visibility.None)
            } else {
                ComWheel({model:$comWheelModel})
            }
        }
    }
}
