/**
 * @author alteredq / http://alteredqualia.com/
 */
THREE.SepiaShader = {
	uniforms: {
		"tDiffuse": { value: null },
		"width": { value: 640 },
		"height": { value: 480 },
		"byp":		{ value: 0 }
	},
	vertexShader: [
		"varying vec2 vUv;",
		"void main() {",
			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",
		"}"
	].join( "\n" ),
	fragmentShader: [
		"uniform int byp;",
		"uniform sampler2D tDiffuse;",
		"uniform float width;",
		"uniform float height;",
		"varying vec2 vUv;",
		"vec2 inverseScreenSize;",
		
		"float rgb2luma(vec3 rgb){",
		    "return sqrt(dot(rgb, vec3(0.299, 0.587, 0.114)));",
		"}",
		"void main() {",
			"if(byp<1) {",
				"inverseScreenSize = vec2(1.0/width, 1.0/height);",
				"vec3 colorCenter = texture2D(tDiffuse,vUv).rgb;",
				"float lumaCenter = rgb2luma(colorCenter);",
				// Luma at the four direct neighbours of the current fragment.
				"float lumaDown = rgb2luma(texture2D(tDiffuse,vUv+vec2(0.0,-1.0)*inverseScreenSize).rgb);",
				"float lumaUp = rgb2luma(texture2D(tDiffuse,vUv+vec2(0.0,1.0)*inverseScreenSize).rgb);",
				"float lumaLeft = rgb2luma(texture2D(tDiffuse,vUv+vec2(-1.0,0.0)*inverseScreenSize).rgb);",
				"float lumaRight = rgb2luma(texture2D(tDiffuse,vUv+vec2(1.0,0.0)*inverseScreenSize).rgb);",
				
				// Find the maximum and minimum luma around the current fragment.
				"float lumaMin = min(lumaCenter,min(min(lumaDown,lumaUp),min(lumaLeft,lumaRight)));",
				"float lumaMax = max(lumaCenter,max(max(lumaDown,lumaUp),max(lumaLeft,lumaRight)));",
				
				// Compute the delta.
				"float lumaRange = lumaMax - lumaMin;",
				
				// If the luma variation is lower that a threshold (or if we are in a really dark area), we are not on an edge, don't perform any AA.
				"if(lumaRange < max(0.0312,lumaMax*0.125)){",
				    "gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0)*0.5 + texture2D (tDiffuse, vUv)*0.5;",
				    "return;",
				"}",
				"gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0)*0.5 + texture2D (tDiffuse, vUv)*0.5;",
			"}",
			"else {",
				"gl_FragColor=texture2D (tDiffuse, vUv);",
			"}",
		"}"
	].join( "\n" )
};

THREE.FXAAPass = function ( dt_size ) {

	THREE.Pass.call( this );
	
	var shader = THREE.SepiaShader;
	this.uniforms = THREE.UniformsUtils.clone( shader.uniforms );

	this.material = new THREE.ShaderMaterial( {
		uniforms: this.uniforms,
		vertexShader: shader.vertexShader,
		fragmentShader: shader.fragmentShader
	} );

	this.camera = new THREE.OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
	this.scene  = new THREE.Scene();

	this.quad = new THREE.Mesh( new THREE.PlaneBufferGeometry( 2, 2 ), null );
	this.quad.frustumCulled = false; // Avoid getting clipped
	this.scene.add( this.quad );

	this.active = false;
};

THREE.FXAAPass.prototype = Object.assign( Object.create( THREE.Pass.prototype ), {

	constructor: THREE.GlitchPass,

	render: function ( renderer, writeBuffer, readBuffer, delta, maskActive ) {

		this.uniforms[ "tDiffuse" ].value = readBuffer.texture;
		this.uniforms[ "width" ].value = readBuffer.width;
		this.uniforms[ "height" ].value = readBuffer.height;
		
		if(this.active == false)
			this.uniforms[ 'byp' ].value = 1;
		else
			this.uniforms[ 'byp' ].value = 0;
		
		this.quad.material = this.material;

		if ( this.renderToScreen ) {

			renderer.render( this.scene, this.camera );

		} else {

			renderer.render( this.scene, this.camera, writeBuffer, this.clear );

		}

	}

} );