/**
 * based on http://blog.simonrodriguez.fr/articles/30-07-2016_implementing_fxaa.html
 */
THREE.SSAOShader = {
	uniforms: {
		"tDiffuse":     { value: null },
		"tDepth":       { value: null },
		"size":         { value: new THREE.Vector2( 512, 512 ) },
		"cameraNear":   { value: 1 },
		"cameraFar":    { value: 50 },
		"radius":       { value: 32 },
		"onlyAO":       { value: 0 },
		"aoClamp":      { value: 0.25 },
		"lumInfluence": { value: 0.7 }
	},
	vertexShader: [
		"varying vec2 vUv;",
		
		"void main() {",
			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
		"}"
	].join( "\n" ),
	fragmentShader: [
		"uniform sampler2D tDepth;",
		"uniform float cameraNear;",
		"uniform float cameraFar;",
		"varying vec2 vUv;",
		
		"#include <packing>",
		
		"float readDepth( const in vec2 coord ) {",

			"float cameraFarPlusNear = cameraFar + cameraNear;",
			"float cameraFarMinusNear = cameraFar - cameraNear;",
			"float cameraCoef = 2.0 * cameraNear;",

			"#ifdef USE_LOGDEPTHBUF",

				"float logz = unpackRGBAToDepth( texture2D( tDepth, coord ) );",
				"float w = pow(2.0, (logz / logDepthBufFC)) - 1.0;",
				"float z = (logz / w) + 1.0;",

			"#else",

				"float z = unpackRGBAToDepth( texture2D( tDepth, coord ) );",

			"#endif",

			"return cameraCoef / ( cameraFarPlusNear - z * cameraFarMinusNear );",


		"}",
		
		"void main() {",
			"gl_FragColor = vec4(vec3(readDepth(vUv)),1.0);",
		"}"
	].join( "\n" )
};

THREE.SSAOPass = function ( scene, camera, width, height ) {

	THREE.ShaderPass.call( this, THREE.SSAOShader );

	this.width = ( width !== undefined ) ? width : 512;
	this.height = ( height !== undefined ) ? height : 256;

	this.renderToScreen = false;

	this.camera2 = camera;
	this.scene2 = scene;

	//Depth material
	this.depthMaterial = new THREE.MeshDepthMaterial();
	this.depthMaterial.depthPacking = THREE.RGBADepthPacking;
	this.depthMaterial.blending = THREE.NoBlending;

	//Depth render target
	this.depthRenderTarget = new THREE.WebGLRenderTarget( this.width, this.height, { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter } );
	//this.depthRenderTarget.texture.name = 'SSAOShader.rt';
	
	//Shader uniforms
	this.uniforms[ 'tDepth' ].value = this.depthRenderTarget.texture;
	this.uniforms[ 'size' ].value.set( this.width, this.height );
	this.uniforms[ 'cameraNear' ].value = this.camera2.near;
	this.uniforms[ 'cameraFar' ].value = this.camera2.far;

	this.uniforms[ 'radius' ].value = 4;
	this.uniforms[ 'onlyAO' ].value = false;
	this.uniforms[ 'aoClamp' ].value = 0.25;
	this.uniforms[ 'lumInfluence' ].value = 0.7;
}

THREE.SSAOPass.prototype = Object.create( THREE.Pass.prototype );

/**
 * Render using this pass.
 * 
 * @method render
 * @param {WebGLRenderer} renderer
 * @param {WebGLRenderTarget} writeBuffer Buffer to write output.
 * @param {WebGLRenderTarget} readBuffer Input buffer.
 * @param {Number} delta Delta time in milliseconds.
 * @param {Boolean} maskActive Not used in this pass.
 */
THREE.SSAOPass.prototype.render = function( renderer, writeBuffer, readBuffer, delta, maskActive ) {

	//Render depth into depthRenderTarget
	this.scene2.overrideMaterial = this.depthMaterial;
	
	renderer.render( this.scene2, this.camera2, this.depthRenderTarget, true );
	
	this.scene2.overrideMaterial = null;

	this.quad.material = this.material;

	//SSAO shaderPass
	if ( this.renderToScreen ) {

		renderer.render( this.scene, this.camera );

	} else {

		renderer.render( this.scene, this.camera, writeBuffer, this.clear );

	}

};