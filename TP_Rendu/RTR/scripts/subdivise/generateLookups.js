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