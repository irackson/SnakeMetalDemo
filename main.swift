import Cocoa
import Metal
import MetalKit

// Embedded Metal shader source
let shaderSource = """
#include <metal_stdlib>
using namespace metal;
struct Vertex {
    float2 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};
vertex float4 vertex_main(const device Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return float4(vertices[vid].position, 0, 1);
}
fragment float4 fragment_main(const device Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return vertices[vid].color;
}
"""

class GameView: MTKView, MTKViewDelegate {
    struct Vertex { var position: SIMD2<Float>; var color: SIMD4<Float> }
    let gridSize = 20
    var snake = [(10,10),(9,10),(8,10)]
    var dir = (dx: 1, dy: 0)
    var food = (15,15)
    var lastUpdate = CACurrentMediaTime()
    var pipeline: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    override init(frame frameRect: NSRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device ?? MTLCreateSystemDefaultDevice())
        colorPixelFormat = .bgra8Unorm
        delegate = self
        commandQueue = self.device!.makeCommandQueue()
        let lib = try! self.device!.makeLibrary(source: shaderSource, options: nil)
        let vfn = lib.makeFunction(name: "vertex_main")!
        let ffn = lib.makeFunction(name: "fragment_main")!
        let pd = MTLRenderPipelineDescriptor()
        pd.vertexFunction = vfn
        pd.fragmentFunction = ffn
        pd.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipeline = try! device!.makeRenderPipelineState(descriptor: pd)
        preferredFramesPerSecond = 60

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { e in
            switch e.keyCode {
            case 123: self.dir = (-1,0)  // left
            case 124: self.dir = (1,0)   // right
            case 125: self.dir = (0,-1)  // down
            case 126: self.dir = (0,1)   // up
            default: break
            }
            return e
        }
    }

    required init(coder: NSCoder) { fatalError() }

    func draw(in view: MTKView) {
        let now = CACurrentMediaTime()
        if now - lastUpdate > 0.15 {
            lastUpdate = now
            var head = snake[0]
            head = ((head.0 + dir.dx + gridSize) % gridSize,
                    (head.1 + dir.dy + gridSize) % gridSize)
            snake.insert(head, at: 0)
            if head == food {
                food = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
            } else {
                snake.removeLast()
            }
        }

        guard let pass = currentRenderPassDescriptor,
              let drawable = currentDrawable else { return }
        let buf = commandQueue.makeCommandBuffer()!
        let enc = buf.makeRenderCommandEncoder(descriptor: pass)!
        enc.setRenderPipelineState(pipeline)

        var verts = [Vertex]()
        func addRect(x: Int, y: Int, color: SIMD4<Float>) {
            let s = 2.0 / Float(gridSize)
            let fx = Float(x) * s - 1 + s/2
            let fy = Float(y) * s - 1 + s/2
            let hs = s/2
            let pts = [
                SIMD2<Float>(fx-hs, fy-hs), SIMD2<Float>(fx+hs, fy-hs), SIMD2<Float>(fx-hs, fy+hs),
                SIMD2<Float>(fx+hs, fy-hs), SIMD2<Float>(fx+hs, fy+hs), SIMD2<Float>(fx-hs, fy+hs),
            ]
            for p in pts { verts.append(Vertex(position: p, color: color)) }
        }

        snake.forEach { addRect(x: $0.0, y: $0.1, color: SIMD4<Float>(0,1,0,1)) }
        addRect(x: food.0, y: food.1, color: SIMD4<Float>(1,0,0,1))

        enc.setVertexBytes(verts, length: MemoryLayout<Vertex>.stride * verts.count, index: 0)
        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: verts.count)
        enc.endEncoding()

        buf.present(drawable)
        buf.commit()
    }
}

// App setup
let app = NSApplication.shared
let window = NSWindow(contentRect: NSMakeRect(0, 0, 640, 640),
                      styleMask: [.titled, .closable, .resizable],
                      backing: .buffered, defer: false)
window.title = "Snake Metal Demo"
let view = GameView(frame: window.contentView!.bounds, device: MTLCreateSystemDefaultDevice())
view.autoresizingMask = [.width, .height]
window.contentView = view
window.makeKeyAndOrderFront(nil)
app.run()
