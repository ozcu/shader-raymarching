import './style.css'
import * as THREE from 'three'
//import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'

import boilerVertexShader from './shaders/vertex.glsl'
import boilerFragmentShader from './shaders/fragment.glsl'


/**
 * Base
 */
// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()
scene.background = new THREE.Color(0x132020)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera

let frustumSize = sizes.height
let aspect = sizes.width/sizes.height
const camera = new THREE.OrthographicCamera(frustumSize * aspect / -2,frustumSize * aspect / 2, frustumSize / 2, frustumSize/-2, 0.1,10 )

//const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)

camera.position.z = 2.5
scene.add(camera)

// Controls
//const controls = new OrbitControls(camera, canvas)
//controls.enableDamping = true


//Matcap
const textureLoader = new THREE.TextureLoader()
const solarTexture = textureLoader.load('../static/solar.png')
const glowTexture = textureLoader.load('../statics/glow.png')
console.log(solarTexture)
console.log(glowTexture)

/**
 * Sphere
 */

//const geometry = new THREE.BoxBufferGeometry(1,1,1)

const plane = new THREE.PlaneBufferGeometry(sizes.width,sizes.height,1,1)
let shaderMaterial = null

shaderMaterial= new THREE.ShaderMaterial({
    vertexShader:boilerVertexShader,
    fragmentShader:boilerFragmentShader,
    uniforms:{
        uTime:{value:0},
        uResolution:{value: new THREE.Vector4()},
        uMatcap:{value: solarTexture},
    }


})

const planeObj = new THREE.Mesh(plane,shaderMaterial)

scene.add(planeObj)

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

const imageAspect = 1
let a1,a2

if(sizes.height/sizes.width > imageAspect){
    a1= (sizes.width/sizes.height) * imageAspect
    a2=1

}else{
    a1= 1
    a2 = (sizes.height/sizes.width) * imageAspect
}

shaderMaterial.uniforms.uResolution.value.x = sizes.width
shaderMaterial.uniforms.uResolution.value.y = sizes.height
shaderMaterial.uniforms.uResolution.value.z = a1
shaderMaterial.uniforms.uResolution.value.w = a2

/**
 * Animate
 */
const clock = new THREE.Clock()
let lastElapsedTime = 0

const animateScene = () =>
{
    const elapsedTime = clock.getElapsedTime()
    const deltaTime = elapsedTime - lastElapsedTime
    lastElapsedTime = elapsedTime

    // Update controls
    //controls.update()

    //Update shader with time
    shaderMaterial.uniforms.uTime.value = elapsedTime

    // Render
    renderer.render(scene, camera)

    // Call animateScene again on the next frame
    window.requestAnimationFrame(animateScene)
}

animateScene()