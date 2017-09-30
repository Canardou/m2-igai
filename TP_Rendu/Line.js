/*global THREE*/
class Line {
    constructor(pointsArray){
        this.pointsArray = [];
        for(var k in pointsArray)
            this.pointsArray[k] =  pointsArray[k].clone();
            
        this.numberOfPoints = 0;
        this.points = [];
    }
    
    computeLine(numberOfPoints){
        this.points = [];
        for(var i = 0; i < numberOfPoints; i++){
            this.points.push(this.pointsArray[Math.floor(i/numberOfPoints*this.pointsArray.length)]);
        }
        return this.points;
    }
    
    getLine(numberOfPoints){
        if(this.numberOfPoints == numberOfPoints)
            return this.points;
        return this.computeLine(numberOfPoints);
    }
    
    getLineCylinder(radius, resolution, numberOfPoints){
        var points = this.getLine(numberOfPoints);
        var result = [];
        
        function calculate(i,j,p){
            var normal = (new THREE.Vector3()).subVectors(points[j],points[i]);
            var u = normal.clone().cross((new THREE.Vector3(0,1,0)))
            if(u.x == 0 && u.y == 0 && u.z == 0){
                u = normal.clone().cross(new THREE.Vector3(0.01,1,0.01))
            }
            normal.normalize();
            u.normalize();
            for(var j = 0; j < resolution; j++){
                result.push((new THREE.Vector3())
                                    .add(u.clone().multiplyScalar(radius * Math.cos(j/resolution*Math.PI*2)))
                                    .add(normal.clone().cross(u).multiplyScalar(radius * Math.sin(j/resolution*Math.PI*2)))
                                    .add(points[p]));
            }
        }
        
        //Special case first
        calculate(0,1,0);
        for(var i = 1; i < numberOfPoints - 1; i++){
            calculate(i-1,i+1,i);
        }
        //Special case for the last point
        calculate(numberOfPoints - 2,numberOfPoints - 1,numberOfPoints - 1);
        return result;
    }
    
    getGeometryCylinder(radius, resolution, numberOfPoints){
        var vertices = this.getLineCylinder(radius, resolution, numberOfPoints);
        var geom = new THREE.Geometry();
        geom.vertices = geom.vertices.concat(vertices);
        var length = vertices.length;
        //Start face
        for(var i = 0; i < resolution - 2; i++){
            geom.faces.push( new THREE.Face3( i, resolution-1, i+1 ));
        }
        for(var i = 0; i < length/resolution - 1; i++){
            var currentIndex = i * resolution;
            for(var j = 0; j < resolution - 1; j++){
                geom.faces.push( new THREE.Face3( currentIndex + j, currentIndex + j + 1, currentIndex + resolution + j + 1 ));
                geom.faces.push( new THREE.Face3( currentIndex + j, currentIndex + resolution + j + 1, currentIndex + resolution + j ));
            }
            geom.faces.push( new THREE.Face3( currentIndex + resolution - 1, currentIndex, currentIndex + resolution ));
            geom.faces.push( new THREE.Face3( currentIndex + resolution - 1, currentIndex + resolution, currentIndex + 2 * resolution - 1));
        }
        //End face
        for(var i = length - resolution; i < length - 2; i++){
            geom.faces.push( new THREE.Face3( i, i+1, length-1 ));
        }
        console.log(geom)
        geom.computeFaceNormals();
        return geom;
    }
}