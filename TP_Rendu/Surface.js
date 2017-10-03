class Surface{
    constructor(pointsArray, lineGenerator){
        this.pointsArray = Surface.matrix(pointsArray.length,pointsArray[0].length);
        for(var k in pointsArray)
            for(var l in pointsArray[k])
                this.pointsArray[k][l] =  pointsArray[k][l].clone();
            
        this.resolution = {'x':0,'y':0};
        this.points = null;
        this.lineGenerator = lineGenerator;
    }
    
    computePoints(x,y,order){
        this.points = Surface.matrix(x,y);
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
                this.points[i][j]=generatrice[j];
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
    
    static matrix(m, n) {
      return Array.from({
        length: m
      }, () => new Array(n).fill(0));
    };
}