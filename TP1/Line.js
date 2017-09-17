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
        for(var i = 0; i < numberOfPoints - 1; i++){
            var normal = (new THREE.Vector3()).subVectors(points[i+1],points[i]);
            var u = ((new THREE.Vector3()).add(normal)).cross((new THREE.Vector3(0,1,0)))
            if(u.x == 0 && u.y == 0 && u.z == 0){
                u = ((new THREE.Vector3()).add(normal)).cross((new THREE.Vector3(0.01,1,0.01)).add(normal))
            }
            normal.normalize();
            u.normalize();
            for(var j = 0; j < resolution; j++){
                result.push((new THREE.Vector3())
                                    .add(u.clone().multiplyScalar(radius * Math.cos(j/resolution*Math.PI*2)))
                                    .add(normal.clone().cross(u).multiplyScalar(radius * Math.sin(j/resolution*Math.PI*2)))
                                    .add(points[i]));
            }
        }
        //Special case for the last point
        return result;
    }
}