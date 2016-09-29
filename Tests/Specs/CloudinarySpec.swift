//
//  CloudinarySpec.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 29/09/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Quick
import Nimble
@testable import Halo

class CloudinarySpec: BaseSpec {
    
    override func spec() {
        
        describe("The Cloudinary helper") {
            
            var cloud: CloudinaryURL!
            
            beforeEach {
                cloud = CloudinaryURL(url: "http://res.cloudinary.com/demo/image/upload/sample.jpg")
            }
            
            it("adds width and height in pixels") {
                cloud.width(pixels: 200).height(pixels: 100)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/w_200,h_100/sample.jpg"))
            }
            
            it("adds width and height in percent") {
                cloud.width(percent: 0.5).height(percent: 0.5)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/w_0.5,h_0.5/sample.jpg"))
            }
            
            it("sets crop") {
                cloud.crop(.Fill)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/c_fill/sample.jpg"))
            }
            
            it("sets aspect ratio as string") {
                cloud.aspectRatio(ratio: "16:9")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/ar_16:9/sample.jpg"))
            }
            
            it("sets aspect ratio as percent") {
                cloud.aspectRatio(percent: 1.5)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/ar_1.5/sample.jpg"))
            }
            
            it("sets gravity") {
                cloud.gravity(g: .Face)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/g_face/sample.jpg"))
            }
            
            it("sets zoom") {
                cloud.zoom(percent: 0.5)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/z_0.5/sample.jpg"))
            }
            
            it("sets xPos, yPos in pixels") {
                cloud.xPos(pixels: 40).yPos(pixels: 20)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/x_40,y_20/sample.jpg"))
            }
            
            it("sets xPos, yPos in percent") {
                cloud.xPos(percent: 0.5).yPos(percent: 0.5)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/x_0.5,y_0.5/sample.jpg"))
            }
            
            it("sets quality") {
                cloud.quality(percent: 80)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/q_80.0/sample.jpg"))
            }
            
            it("sets radius") {
                cloud.radius(pixels: 50)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/r_50/sample.jpg"))
            }
            
            it("sets max radius") {
                cloud.maxRadius()
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/r_max/sample.jpg"))
            }
            
            it("adds rotation") {
                cloud.rotate(angle: .Custom(12))
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/a_12.0/sample.jpg"))
            }
            
            it("adds effect") {
                cloud.addEffect(effect: .AutoColor)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/e_auto_color/sample.jpg"))
            }
            
            it("sets opacity") {
                cloud.opacity(opacity: 30)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/o_30/sample.jpg"))
            }
            
            it("sets border") {
                cloud.border(border: "4px_solid_black")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/bo_4px_solid_black/sample.jpg"))
            }
            
            it("sets background color by name") {
                cloud.backgroundColor(identifier: "blue")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/b_blue/sample.jpg"))
            }
            
            it("sets background color by rgb") {
                cloud.backgroundColor(rgb: "9090ff")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/b_rgb:9090ff/sample.jpg"))
            }
            
            it("sets overlay") {
                cloud.overlay(id: "badge")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/l_badge/sample.jpg"))
            }
            
            it("sets overlay text") {
                cloud.overlayText(text: "Arial_50:Smile!")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/l_text:Arial_50:Smile!/sample.jpg"))
            }
            
            it("sets underlay") {
                cloud.underlay(id: "site_bg.jpg")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/u_site_bg.jpg/sample.jpg"))
            }
            
            it("sets default image") {
                cloud.defaultImage(id: "avatar.png")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/d_avatar.png/sample.jpg"))
            }
            
            it("sets delay") {
                cloud.delay(delay: 20)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/dl_20/sample.jpg"))
            }
            
            it("sets color by name") {
                cloud.color(identifier: "blue")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/co_blue/sample.jpg"))
            }
            
            it("sets color by rgb") {
                cloud.color(rgb: "20a020")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/co_rgb:20a020/sample.jpg"))
            }
            
            it("sets device pixel ratio") {
                cloud.devicePixelRatio(ratio: 2)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/dpr_2.0/sample.jpg"))
            }
            
            it("sets page") {
                cloud.page(page: 2)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/pg_2/sample.jpg"))
            }
            
            it("sets dpi") {
                cloud.dpi(dpi: 10)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/dn_10/sample.jpg"))
            }
            
            it("adds flags") {
                cloud.addFlags(flags: .Clip, .Lossy, .Png8)
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/fl_clip.lossy.png8/sample.jpg"))
            }
            
            it("uses named transformation") {
                cloud.namedTransformation(name: "papafrita")
                expect(cloud.absoluteURLString).to(equal("http://res.cloudinary.com/demo/image/upload/t_papafrita/sample.jpg"))
            }
        }
    }
}
