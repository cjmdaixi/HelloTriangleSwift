//
//  ViewController.swift
//  HelloTriangleSwift
//
//  Created by 陈锦明 on 2021/2/2.
//

import UIKit
import MetalKit

class Renderer : NSObject, MTKViewDelegate{
    let metalView: MTKView
    let metalDevice: MTLDevice!
    let renderPipelineState: MTLRenderPipelineState!
    let commandQueue: MTLCommandQueue!
    
    var viewport: simd_float2 = simd_float2(0.0, 0.0)
    
    init?(_ mtkView: MTKView) {
        self.metalView = mtkView
        self.metalDevice = mtkView.device
        
        guard let shaderLibrary = mtkView.device?.makeDefaultLibrary() else{
            print("Cannot create default shader library")
            return nil
        }
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = shaderLibrary.makeFunction(name: "vertexShader")
        renderPipelineDescriptor.fragmentFunction = shaderLibrary.makeFunction(name: "fragmentShader")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        
        guard let renderPipelineState = try? mtkView.device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            print("Cannot create render pipeline state")
            return nil
        }
        self.renderPipelineState = renderPipelineState
        self.commandQueue = mtkView.device?.makeCommandQueue()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.viewport.x = Float(size.width)
        self.viewport.y = Float(size.height)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else{
            print("failed to create command buffer")
            return
        }
        
        guard let renderPassDescriptor = self.metalView.currentRenderPassDescriptor else {
            print("get current render pass descriptor failed")
            return
        }
        
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print("create render command encoder failed")
            return
        }
        let positions: [simd_float3] = [
            simd_float3(self.viewport.x / 2, 0, 0),
            simd_float3(0, -self.viewport.y, 0),
            simd_float3(self.viewport.x, -self.viewport.y, 0)
        ]
        
        let colors: [simd_float3] = [
            simd_float3(1.0, 0.0, 0.0),
            simd_float3(0.0, 1.0, 0.0),
            simd_float3(0.0, 0.0, 1.0)
        ]
        
        renderCommandEncoder.setRenderPipelineState(self.renderPipelineState)
        
        renderCommandEncoder.setVertexBytes(positions, length: MemoryLayout<simd_float3>.size * 3, index: 0)
        renderCommandEncoder.setVertexBytes(colors, length: MemoryLayout<simd_float3>.size * 3, index: 1)
        renderCommandEncoder.setVertexBytes(&(self.viewport), length: MemoryLayout<simd_float2>.size, index: 2)
        
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderCommandEncoder.endEncoding()
        
        if let drawable = self.metalView.currentDrawable{
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
    
    
}

class ViewController: UIViewController {
    var mtkView: MTKView!
    var mtkRenderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let mtkView = self.view as? MTKView else {
            print("View of controller is not an MTKView")
            return
        }
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Cannot create default metal device")
            return
        }
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.white
        mtkView.clearColor = MTLClearColor(red: 1.0, green: 0.2, blue: 1.0, alpha: 1.0)
        
        mtkRenderer = Renderer(mtkView)
        mtkRenderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = mtkRenderer
        
        self.mtkView = mtkView
        
    }


}

