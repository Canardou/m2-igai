/**
 * based on http://blog.simonrodriguez.fr/articles/30-07-2016_implementing_fxaa.html
 */
THREE.SSAOShader = {
	uniforms: {
		"screenTexture":{ value: null },
		"tDepth":       { value: null },
		"size":         { value: new THREE.Vector2( 512, 512 ) },
		"cameraNear":   { value: 1 },
		"cameraFar":    { value: 50 },
		"byp":  		{ value: 0 },
	},
	vertexShader: [
		"varying vec2 vUv;",
		
		"void main() {",
			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
		"}"
	].join( "\n" ),
	fragmentShader: [
		"uniform sampler2D screenTexture;",
		"uniform sampler2D tDepth;",
		"uniform float cameraNear;",
		"uniform float cameraFar;",
		"uniform vec2 size;",
		"uniform int byp;",
		"varying vec2 vUv;",
		
		"const int samples = 32;",
		
		"float uRadius = 0.1;",
		
		"#include <packing>",
		
		"vec2 inverseScreenSize;",
		
		"float readDepth( const in vec2 coord ) {",

			"float cameraFarPlusNear = cameraFar + cameraNear;",
			"float cameraFarMinusNear = cameraFar - cameraNear;",
			"float cameraCoef = 2.0 * cameraFar * cameraNear;",

			"#ifdef USE_LOGDEPTHBUF",

				"float logz = unpackRGBAToDepth( texture2D( tDepth, coord ) );",
				"float w = pow(2.0, (logz / logDepthBufFC)) - 1.0;",
				"float z = (logz / w) + 1.0;",

			"#else",

				"float z = unpackRGBAToDepth( texture2D( tDepth, coord ) );",

			"#endif",

    		"z = z * 2.0 - 1.0;",

			"return cameraCoef / ( cameraFarPlusNear - z * cameraFarMinusNear );",


		"}",
		
		"vec3 calculNormal( float depth, vec2 uv ) {",

			"vec2 offset1 = vec2(0,1)*inverseScreenSize.y;",
			"vec2 offset2 = vec2(1,0)*inverseScreenSize.x;",
			  
			"float depth1 = readDepth( uv + offset1);",
			"float depth2 = readDepth( uv + offset2);",
			  
			"vec3 p1 = vec3(offset1, depth1 - depth);",
			"vec3 p2 = vec3(offset2, depth2 - depth);",
			  
			"vec3 normal = cross(p1, p2);",
			  
			"return normalize(normal);",


		"}",
		
		"float rand(vec2 co){",
			"return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);",
		"}",
		
		"void main() {",
			"if(byp>0){",
				"inverseScreenSize = vec2(1.0/size.x, 1.0/size.y);",
				//get depth
				"float depth = readDepth(vUv);",
				//calculate informations of the point : normal(world) + position(x,y,z) screen space
				"vec3 normal = calculNormal( depth, vUv);",
				"vec3 position = vec3( vUv, depth);",
				//generate hemisphere
				"vec3 kernel[samples];",
				"for(int i = 0; i < samples; ++i) {",
				   "kernel[i] = vec3(",
				   "rand(vUv*(0.1*(float(i)+1.0)))*2.0-1.0,",
				   "rand(vUv*(0.11*(float(i)+1.0)))*2.0-1.0,",
				   "rand(vUv*(0.12*(float(i)+1.0)))*1.0);",
				   "kernel[i] = normalize(kernel[i]);",
				   "float scale = float(i) / float(samples);",
			       "scale = clamp(scale * scale, 0.1, 1.0);",
			       "kernel[i] *= scale;",
				"}",
				//rotation matrix
			    "vec3 tangent = normalize(kernel[0] - normal * dot(kernel[0], normal));",
			    "vec3 bitangent = cross(normal, tangent);",
			    "mat3 tbn = mat3(tangent, bitangent, normal);",
				
				"float occlusion = 0.0;",
				"for (int i = 0; i < samples; ++i) {",
				// get sample position:
				   "vec3 sample = tbn * kernel[i];",
				   "sample = sample * uRadius + position;",
				  
				// get sample depth:
				   "float sampleDepth = readDepth(sample.xy);",
				  
				// range check & accumulate:
				   "float rangeCheck= abs(position.z - sampleDepth) < uRadius * 12.0 ? 1.0 : 0.0;",
				   "occlusion += (sampleDepth <= sample.z ? 1.0 : 0.0) * rangeCheck;",
				"}",
	
				"occlusion = 1.0 - occlusion / float(samples);",
	
				"if(byp==2){",
					"gl_FragColor = vec4(vec3(occlusion),1.0);",
				"}",
				"else if(byp==1){",
					"gl_FragColor = vec4(normal*0.5+0.5,1.0);",
				"}",
				"else{",
					"gl_FragColor = vec4(texture2D(screenTexture, vUv).rgb*occlusion,1.0);",
				"}",
			"}",
			"else{",
				"gl_FragColor = vec4(texture2D(screenTexture, vUv).rgb,1.0);",
			"}",
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

	this.step = 3;
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

	this.uniforms[ "screenTexture" ].value = readBuffer.texture;
	this.uniforms[ 'byp' ].value = this.step;

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

};/**
 * based on http://blog.simonrodriguez.fr/articles/30-07-2016_implementing_fxaa.html
 */
THREE.SSAOShader = {
	uniforms: {
		"screenTexture":{ value: null },
		"tDepth":       { value: null },
		"size":         { value: new THREE.Vector2( 512, 512 ) },
		"cameraNear":   { value: 1 },
		"cameraFar":    { value: 50 },
		"byp":  		{ value: 0 },
	},
	vertexShader: [
		"varying vec2 vUv;",
		
		"void main() {",
			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
		"}"
	].join( "\n" ),
	fragmentShader: [
		"uniform sampler2D screenTexture;",
		"uniform sampler2D tDepth;",
		"uniform float cameraNear;",
		"uniform float cameraFar;",
		"uniform vec2 size;",
		"uniform int byp;",
		"varying vec2 vUv;",
		
		"const int samples = 32;",
		
		"float uRadius = 0.1;",
		
		"#include <packing>",
		
		"vec2 inverseScreenSize;",
		
		"float readDepth( const in vec2 coord ) {",

			"float cameraFarPlusNear = cameraFar + cameraNear;",
			"float cameraFarMinusNear = cameraFar - cameraNear;",
			"float cameraCoef = 2.0 * cameraFar * cameraNear;",

			"#ifdef USE_LOGDEPTHBUF",

				"float logz = unpackRGBAToDepth( texture2D( tDepth, coord ) );",
				"float w = pow(2.0, (logz / logDepthBufFC)) - 1.0;",
				"float z = (logz / w) + 1.0;",

			"#else",

				"float z = unpackRGBAToDepth( texture2D( tDepth, coord ) );",

			"#endif",

    		"z = z * 2.0 - 1.0;",

			"return cameraCoef / ( cameraFarPlusNear - z * cameraFarMinusNear );",


		"}",
		
		"vec3 calculNormal( float depth, vec2 uv ) {",

			"vec2 offset1 = vec2(0,1)*inverseScreenSize.y;",
			"vec2 offset2 = vec2(1,0)*inverseScreenSize.x;",
			  
			"float depth1 = readDepth( uv + offset1);",
			"float depth2 = readDepth( uv + offset2);",
			  
			"vec3 p1 = vec3(offset1, depth1 - depth);",
			"vec3 p2 = vec3(offset2, depth2 - depth);",
			  
			"vec3 normal = cross(p1, p2);",
			  
			"return normalize(normal);",


		"}",
		
		"float rand(vec2 co){",
			"return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);",
		"}",
		
		"void main() {",
			"if(byp>0){",
				"inverseScreenSize = vec2(1.0/size.x, 1.0/size.y);",
				//get depth
				"float depth = readDepth(vUv);",
				//calculate informations of the point : normal(world) + position(x,y,z) screen space
				"vec3 normal = calculNormal( depth, vUv);",
				"vec3 position = vec3( vUv, depth);",
				//generate hemisphere
				"vec3 kernel[samples];",
				"for(int i = 0; i < samples; ++i) {",
				   "kernel[i] = vec3(",
				   "rand(vUv*(0.1*(float(i)+1.0)))*2.0-1.0,",
				   "rand(vUv*(0.11*(float(i)+1.0)))*2.0-1.0,",
				   "rand(vUv*(0.12*(float(i)+1.0)))*1.0);",
				   "kernel[i] = normalize(kernel[i]);",
				   "float scale = float(i) / float(samples);",
			       "scale = clamp(scale * scale, 0.1, 1.0);",
			       "kernel[i] *= scale;",
				"}",
				//rotation matrix
			    "vec3 tangent = normalize(kernel[0] - normal * dot(kernel[0], normal));",
			    "vec3 bitangent = cross(normal, tangent);",
			    "mat3 tbn = mat3(tangent, bitangent, normal);",
				
				"float occlusion = 0.0;",
				"for (int i = 0; i < samples; ++i) {",
				// get sample position:
				   "vec3 sample = tbn * kernel[i];",
				   "sample = sample * uRadius + position;",
				  
				// get sample depth:
				   "float sampleDepth = readDepth(sample.xy);",
				  
				// range check & accumulate:
				   "float rangeCheck= abs(position.z - sampleDepth) < uRadius * 12.0 ? 1.0 : 0.0;",
				   "occlusion += (sampleDepth <= sample.z ? 1.0 : 0.0) * rangeCheck;",
				"}",
	
				"occlusion = 1.0 - occlusion / float(samples);",
	
				"if(byp==2){",
					"gl_FragColor = vec4(vec3(occlusion),1.0);",
				"}",
				"else if(byp==1){",
					"gl_FragColor = vec4(normal*0.5+0.5,1.0);",
				"}",
				"else{",
					"gl_FragColor = vec4(texture2D(screenTexture, vUv).rgb*occlusion,1.0);",
				"}",
			"}",
			"else{",
				"gl_FragColor = vec4(texture2D(screenTexture, vUv).rgb,1.0);",
			"}",
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

	this.step = 3;
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

	this.uniforms[ "screenTexture" ].value = readBuffer.texture;
	this.uniforms[ 'byp' ].value = this.step;

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