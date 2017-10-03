/*global THREE*/
class Surface{
    constructor(pointsArray, lineGenerator){
        this.pointsArray = Surface.matrix(pointsArray.length,pointsArray[0].length);
        for(var k in pointsArray)
            for(var l in pointsArray[k])
                this.pointsArray[k][l] =  pointsArray[k][l].clone();
            
        this.resolution = {'x':0,'y':0};
        this.points = [];
        this.lineGenerator = lineGenerator;
    }
    
    computePoints(x,y,order){
        this.points = [];
        var directrice = [];
        for(var k in this.pointsArray){
            directrice[k] = new this.lineGenerator(this.pointsArray[k],order).getLine(x);
        }
        for(var i = 0; i < x; i++){
            var dir = []
            for(var k in this.pointsArray){
                dir.push(directrice[k][i]);
            }
            var generatrice = new this.lineGenerator(dir,order).getLine(y);
            for(var j = 0; j < y; j++){
                this.points.push(generatrice[j]);
            }
        }
        return this.points;
    }
    
    computeSurface(x, y, order){
        this.computePoints(x,y,order);
    }
    
    getSurface(resolution){
        if(this.resolution == resolution)
            return this.points;
        this.resolution = resolution;
        return this.computeSurface(resolution.x, resolution.y, resolution.order);
    }
    
    getSurfaceGeometry(resolution){
        this.getSurface(resolution);
        var geom = new THREE.Geometry();
        geom.vertices = geom.vertices.concat(this.points);
        var l = resolution.x;
        for(var j = 0; j < resolution.y - 1; j++){
            for(var i = 0; i < resolution.x - 1; i++){
                geom.faces.push( new THREE.Face3( i + j*l, i + 1 + j*l, i + l + j*l ) );
                geom.faces.push( new THREE.Face3( i + l +  j*l, i + 1 + j*l, i + l + 1 + j*l ) );
            }
        }
        for(var k in geom.faces){
            geom.faces[k].normal.set(0, 0, 1);
        }
        
        console.log(geom)
        return geom;
    }
    
    static matrix(m, n) {
      return Array.from({
        length: m
      }, () => new Array(n).fill(0));
    };
}