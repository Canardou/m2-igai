/**
 * based on http://blog.simonrodriguez.fr/articles/30-07-2016_implementing_fxaa.html
 */
THREE.FXAAShader = {
	uniforms: {
		"screenTexture": { value: null },
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
		"uniform sampler2D screenTexture;",
		"uniform float width;",
		"uniform float height;",
		"varying vec2 vUv;",
		"vec2 inverseScreenSize;",
		
		"const float FXAA_EDGE_THRESHOLD = 1.0/8.0;",
		"const float FXAA_EDGE_THRESHOLD_MIN = 1.0/16.0;",
		"const float FXAA_SUBPIX_TRIM = 1.0/4.0;",
		"const float FXAA_SUBPIX_CAP = 3.0/4.0;",
		"const int FXAA_SEARCH_STEPS = 12;",
		"const float FXAA_SEARCH_ACCELERATION = 2.0;",
		
		"float rgb2luma(vec3 rgb){",
		    "return rgb.y * (0.587/0.299) + rgb.x;",
		"}",
		"void main() {",
			"if(byp>0) {",
				"if(byp==8){",
					"gl_FragColor = vec4(vec3(rgb2luma(texture2D(screenTexture, vUv).rgb)),1.0);",
				    "return;",
				"}",
				"inverseScreenSize = vec2(1.0/width, 1.0/height);",
				"vec3 colorCenter = texture2D(screenTexture,vUv).rgb;",
				"float lumaM = rgb2luma(colorCenter);",
				// Luma at the four direct neighbours of the current fragment.
				"float lumaN = rgb2luma(texture2D(screenTexture,vUv+vec2(0.0,-1.0)*inverseScreenSize).rgb);",
				"float lumaS = rgb2luma(texture2D(screenTexture,vUv+vec2(0.0,1.0)*inverseScreenSize).rgb);",
				"float lumaW = rgb2luma(texture2D(screenTexture,vUv+vec2(-1.0,0.0)*inverseScreenSize).rgb);",
				"float lumaE = rgb2luma(texture2D(screenTexture,vUv+vec2(1.0,0.0)*inverseScreenSize).rgb);",
				
				// Find the maximum and minimum luma around the current fragment.
				"float rangeMin = min(lumaM,min(min(lumaN,lumaS),min(lumaW,lumaE)));",
				"float rangeMax = max(lumaM,max(max(lumaN,lumaS),max(lumaW,lumaE)));",
				
				// Compute the delta.
				"float range = rangeMax - rangeMin;",
				
				// If the luma variation is lower that a threshold (or if we are in a really dark area), we are not on an edge, don't perform any AA.
				"if(range < max(FXAA_EDGE_THRESHOLD_MIN,rangeMax*FXAA_EDGE_THRESHOLD)){",
				    "gl_FragColor = texture2D (screenTexture, vUv);",
				    "return;",
				"} else if (byp == 1) {",
				    "gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);",
				    "return;",
				"}",
				
				
				"float lumaNW = rgb2luma(texture2D(screenTexture,vUv+vec2(-1.0,-1.0)*inverseScreenSize).rgb);",
				"float lumaSE = rgb2luma(texture2D(screenTexture,vUv+vec2(1.0,1.0)*inverseScreenSize).rgb);",
				"float lumaSW = rgb2luma(texture2D(screenTexture,vUv+vec2(-1.0,1.0)*inverseScreenSize).rgb);",
				"float lumaNE = rgb2luma(texture2D(screenTexture,vUv+vec2(1.0,-1.0)*inverseScreenSize).rgb);",
				
				"float lumaVert = lumaN + lumaS;",
				"float lumaHori = lumaW + lumaE;",
				
				// Same for corners
				"float lumaWCorners = lumaNW + lumaSW;",
				"float lumaNCorners = lumaNW + lumaNE;",
				"float lumaECorners = lumaNE + lumaSE;",
				"float lumaSCorners = lumaSE + lumaSW;",
				
				// Compute an estimation of the gradient along the horizontal and vertical axis.
				"float edgeVert = abs((0.25 * lumaNW) + (-0.5 * lumaN) + (0.25 * lumaNE)) + abs((0.50 * lumaW ) + (-1.0 * lumaM) + (0.50 * lumaE )) + abs((0.25 * lumaSW) + (-0.5 * lumaS) + (0.25 * lumaSE));",
				"float edgeHorz = abs((0.25 * lumaNW) + (-0.5 * lumaW) + (0.25 * lumaSW)) + abs((0.50 * lumaN ) + (-1.0 * lumaM) + (0.50 * lumaS )) + abs((0.25 * lumaNE) + (-0.5 * lumaE) + (0.25 * lumaSE));",
				
				// Is the local edge horizontal or vertical ?
				"bool isHorizontal = edgeHorz >= edgeVert;",
				
				"if (isHorizontal && byp == 2) {",
					"gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);",
					"return;",
				"} else if(!isHorizontal && byp == 2) {",
					"gl_FragColor = vec4(0.0, 1.0, 1.0, 1.0);",
					"return;",
				"}",
				
				// Select the two neighboring texels lumas in the opposite direction to the local edge.
				"float luma1 = isHorizontal ? lumaN : lumaW;",
				"float luma2 = isHorizontal ? lumaS : lumaE;",
				
				// Compute gradients in this direction.
				"float gradient1 = luma1 - lumaM;",
				"float gradient2 = luma2 - lumaM;",
				
				// Which direction is the steepest ?
				"bool is1Steepest = abs(gradient1) >= abs(gradient2);",
				
				"if (is1Steepest && byp == 3) {",
					"gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);",
					"return;",
				"} else if(!is1Steepest && byp == 3) {",
					"gl_FragColor = vec4(0.2, 1.0, 0.2, 1.0);",
					"return;",
				"}",
				
				// Gradient in the corresponding direction, normalized.
				"float gradientScaled = 0.25*max(abs(gradient1),abs(gradient2));",
				
				// Choose the step size (one pixel) according to the edge direction.
				"float stepLength = isHorizontal ? inverseScreenSize.y : inverseScreenSize.x;",
				
				// Average luma in the correct direction.
				"float lumaLocalAverage = 0.0;",
				
				"if(is1Steepest){",
				    // Switch the direction
				    "stepLength = - stepLength;",
				    "lumaLocalAverage = 0.5*(luma1 + lumaM);",
				"} else {",
				    "lumaLocalAverage = 0.5*(luma2 + lumaM);",
				"}",
				
				// Shift UV in the correct direction by half a pixel.
				"vec2 currentUv = vUv;",
				"if(isHorizontal){",
				    "currentUv.y += stepLength * 0.5;",
				"} else {",
				    "currentUv.x += stepLength * 0.5;",
				"}",
				
				// Compute offset (for each iteration step) in the right direction.
				"vec2 offset = isHorizontal ? vec2(inverseScreenSize.x,0.0) : vec2(0.0,inverseScreenSize.y);",
				// Compute UVs to explore on each side of the edge, orthogonally. The QUALITY allows us to step faster.
				"vec2 uv1 = currentUv - offset;",
				"vec2 uv2 = currentUv + offset;",
				
				// Read the lumas at both current extremities of the exploration segment, and compute the delta wrt to the local average luma.
				"float lumaEnd1 = rgb2luma(texture2D(screenTexture,uv1).rgb);",
				"float lumaEnd2 = rgb2luma(texture2D(screenTexture,uv2).rgb);",
				"lumaEnd1 -= lumaLocalAverage;",
				"lumaEnd2 -= lumaLocalAverage;",
				
				// If the luma deltas at the current extremities are larger than the local gradient, we have reached the side of the edge.
				"bool reached1 = abs(lumaEnd1) >= gradientScaled;",
				"bool reached2 = abs(lumaEnd2) >= gradientScaled;",
				"bool reachedBoth = reached1 && reached2;",
				
				// If the side is not reached, we continue to explore in this direction.
				"if(!reached1){",
				    "uv1 -= offset;",
				"}",
				"if(!reached2){",
				    "uv2 += offset;",
				"}",
				
				
				// If both sides have not been reached, continue to explore.
				"if(!reachedBoth){",
				
				    "for(int i = 2; i < FXAA_SEARCH_STEPS; i++){",
				        // If needed, read luma in 1st direction, compute delta.
				        "if(!reached1){",
				            "lumaEnd1 = rgb2luma(texture2D(screenTexture, uv1).rgb);",
				            "lumaEnd1 = lumaEnd1 - lumaLocalAverage;",
				        "}",
				        // If needed, read luma in opposite direction, compute delta.
				        "if(!reached2){",
				            "lumaEnd2 = rgb2luma(texture2D(screenTexture, uv2).rgb);",
				            "lumaEnd2 = lumaEnd2 - lumaLocalAverage;",
				        "}",
				        // If the luma deltas at the current extremities is larger than the local gradient, we have reached the side of the edge.
				        "reached1 = abs(lumaEnd1) >= gradientScaled;",
				        "reached2 = abs(lumaEnd2) >= gradientScaled;",
				        "reachedBoth = reached1 && reached2;",
				
				        // If the side is not reached, we continue to explore in this direction, with a variable quality.
				        "if(!reached1){",
				            "uv1 -= offset * FXAA_SEARCH_ACCELERATION;",
				        "}",
				        "if(!reached2){",
				            "uv2 += offset * FXAA_SEARCH_ACCELERATION;",
				        "}",
				
				        // If both sides have been reached, stop the exploration.
				        "if(reachedBoth){ break;}",
				    "}",
				"}",
				
				// Compute the distances to each extremity of the edge.
				"float distance1 = isHorizontal ? (vUv.x - uv1.x) : (vUv.y - uv1.y);",
				"float distance2 = isHorizontal ? (uv2.x - vUv.x) : (uv2.y - vUv.y);",
				
				// In which direction is the extremity of the edge closer ?
				"bool isDirection1 = distance1 < distance2;",
				
				"if (isDirection1 && byp == 4) {",
					"gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);",
					"return;",
				"} else if(!isDirection1 && byp == 4) {",
					"gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);",
					"return;",
				"}",
				
				"if (isDirection1 && is1Steepest && byp == 5) {",
					"gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);",
					"return;",
				"} else if(isDirection1 && !is1Steepest && byp == 5) {",
					"gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);",
					"return;",
				"} else if(!isDirection1 && is1Steepest && byp == 5) {",
					"gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);",
					"return;",
				"} else if(!isDirection1 && !is1Steepest && byp == 5) {",
					"gl_FragColor = vec4(0.0, 1.0, 1.0, 1.0);",
					"return;",
				"}",
				
				"float distanceFinal = min(distance1, distance2);",
				
				// Length of the edge.
				"float edgeThickness = (distance1 + distance2);",
				
				// UV offset: read in the direction of the closest side of the edge.
				"float pixelOffset = - distanceFinal / edgeThickness + 0.5;",
				
				// Is the luma at center smaller than the local average ?
				"bool islumaMSmaller = lumaM < lumaLocalAverage;",
				
				// If the luma at center is smaller than at its neighbour, the delta luma at each end should be positive (same variation).
				// (in the direction of the closer side of the edge.)
				"bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != islumaMSmaller;",
				
				// If the luma variation is incorrect, do not offset.
				"float finalOffset = correctVariation ? pixelOffset : 0.0;",
				
				// Sub-pixel shifting
				// Full weighted average of the luma over the 3x3 neighborhood.
				"float lumaAverage = (1.0/9.0) * (lumaHori + lumaVert + lumaWCorners + lumaECorners + lumaM);",
				// Ratio of the delta between the global average and the center luma, over the luma range in the 3x3 neighborhood.
				"float subPixelOffsetFinal = clamp(abs(lumaAverage - lumaM)/range - FXAA_SUBPIX_TRIM,0.0,FXAA_SUBPIX_CAP);",
				
				"if (finalOffset>subPixelOffsetFinal && byp == 6) {",
					"gl_FragColor = vec4(1.0, 0.0, 0.2, 1.0);",
					"return;",
				"} else if(!(finalOffset>subPixelOffsetFinal) && byp == 6) {",
					"gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);",
					"return;",
				"}",
				
				"if (byp == 9) {",
					"gl_FragColor = vec4(finalOffset*4.0, 0.0, 0.0, 1.0);",
					"return;",
				"}",
				
				// Pick the biggest of the two offsets.
				"finalOffset = max(finalOffset,subPixelOffsetFinal);",
				
				// Compute the final UV coordinates.
				"vec2 finalUv = vUv;",
				
				"if(isHorizontal){",
				    "finalUv.y += finalOffset * stepLength;",
				"} else {",
				    "finalUv.x += finalOffset * stepLength;",
				"}",
				
				// Read the color at the new UV coordinates, and use it.
				"vec3 finalColor = texture2D(screenTexture,finalUv).rgb;",
				"gl_FragColor = vec4(finalColor, 1.0);",
			"}",
			"else {",
				"gl_FragColor=texture2D (screenTexture, vUv);",
			"}",
		"}"
	].join( "\n" )
};

THREE.FXAAPass = function ( ) {

	THREE.Pass.call( this );
	
	var shader = THREE.FXAAShader;
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
	this.step = 7;
};

THREE.FXAAPass.prototype = Object.assign( Object.create( THREE.Pass.prototype ), {

	render: function ( renderer, writeBuffer, readBuffer, delta, maskActive ) {

		this.uniforms[ "screenTexture" ].value = readBuffer.texture;
		this.uniforms[ "width" ].value = readBuffer.width;
		this.uniforms[ "height" ].value = readBuffer.height;
		
		if(this.active == false)
			this.uniforms[ 'byp' ].value = this.step;
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