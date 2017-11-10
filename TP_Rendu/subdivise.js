function getEdge( a, b, map ) {

	var vertexIndexA = Math.min( a, b );
	var vertexIndexB = Math.max( a, b );

	var key = vertexIndexA + "_" + vertexIndexB;

	return map[ key ];

}

function processEdge( a, b, vertices, map, face, metaVertices) {

	var vertexIndexA = Math.min( a, b );
	var vertexIndexB = Math.max( a, b );

	var key = vertexIndexA + "_" + vertexIndexB;

	var edge;

	if ( key in map ) {

		edge = map[ key ];

	} else {

		var vertexA = vertices[ vertexIndexA ];
		var vertexB = vertices[ vertexIndexB ];

		edge = {
			a: vertexA,
			b: vertexB,
			newIndex: null,
			faces: []
		};

		map[ key ] = edge;
	}

	edge.faces.push( face );
	
	metaVertices[ a ].edges.push( edge.b );
	metaVertices[ b ].edges.push( edge.a );
}


function generateLookups( vertices, faces, metaVertices, edges ) {

	var i, il, face, edge;

	for ( i = 0, il = vertices.length; i < il; i ++ ) {

		metaVertices[ i ] = { edges: [] };

	}

	for ( i = 0, il = faces.length; i < il; i ++ ) {

		face = faces[ i ];

		processEdge( face.a, face.b, vertices, edges, face, metaVertices );
		processEdge( face.b, face.c, vertices, edges, face, metaVertices );
		processEdge( face.c, face.a, vertices, edges, face, metaVertices );

	}

}

function subdivise(geometry, sub){
    geometry.faceVertexUvs = [];
    sub = Math.min(Math.max(sub,0),7);
    for(var boucle = 0; boucle < sub; boucle++){
        var oldVertices = geometry.vertices; // { x, y, z}
    	var oldFaces = geometry.faces; // { a: oldVertex1, b: oldVertex2, c: oldVertex3 }
    
    	// Generate edges Lookup
    
    	var edges = {}; // edge oldVertex1_oldVertex2 = { oldVertex1, oldVertex2, faces[]  }
        var metaVertices = [];
    
    	generateLookups(oldVertices, oldFaces, metaVertices, edges);
    	
    	// new edges vertex
    	/*
    	    2 6
    	     6 2
    	*/
    	
    	var newEdgeVertices = [];
    
        for(var k in edges){
            var edge = edges[k];
            //R2, R3, R4
            var vertexWeight = 6/16;
            var adjVertexWeight = 2/16;
            
            var newVertex = new THREE.Vector3();
            
            newVertex.add(edge.a).multiplyScalar(vertexWeight);
            newVertex.add(edge.b.clone().multiplyScalar(vertexWeight));
            
            for(var l in edge.faces){
                var face = edge.faces[l];
                
                // each vertex
                var letters = ['a','b','c'];
                
                for(var m in letters){
                    var vertex = oldVertices[face[letters[m]]];
                    if(vertex != edge.a && vertex != edge.b){
                        newVertex.add(vertex.clone().multiplyScalar(adjVertexWeight));
                    }
                }
            }
            edge.newIndex = newEdgeVertices.length+oldVertices.length;
            newEdgeVertices.push(newVertex);
        }
        
        //console.assert(newEdgeVertices.length == 18, "Edges vertex should count to 18");
        
        // Reposition already created vertex
        /*
            1  1  
          1  10  1
            1  1
        */
        var newSourceVertices = [];
        for(var i = 0; i < oldVertices.length; i++){
            var oldVertex = oldVertices[i];
            
            let edges = metaVertices[i].edges;
            var n = edges.length;
            
            var alpha_n = Math.pow(3/8 + Math.cos(2*Math.PI/n)/4, 2)+3/8;
            
            var alpha = 1.7*alpha_n - 1;
            var beta = (1-alpha)/n;
            
            let newVertex = oldVertex.clone().multiplyScalar(alpha);
            for(var k in edges){
                newVertex.add(edges[k].clone().multiplyScalar(beta));
            }
            newSourceVertices.push(newVertex);
        }
        
        //link source and edge -> 1 face = 4 new faces
        var newFaces = [];
        var newVertices = newSourceVertices.concat(newEdgeVertices);
        for(var i = 0; i<oldFaces.length; i++){
            var face = oldFaces[i];
            
            var d = getEdge( face.a, face.b, edges ).newIndex;
            var e = getEdge( face.b, face.c, edges ).newIndex;
            var f = getEdge( face.c, face.a, edges ).newIndex;
            
            /*
                    a
                   / \
                  d---f
                 / \ / \
                b---e---c 
            */
            newFaces.push(new THREE.Face3(d, e, f));
            newFaces.push(new THREE.Face3(face.a, d, f));
            newFaces.push(new THREE.Face3(face.b, e, d));
            newFaces.push(new THREE.Face3(face.c, f, e));
        }
        
        geometry.faces = newFaces;
        geometry.vertices = newVertices;
    }
    geometry.computeVertexNormals();
    return geometry;
}