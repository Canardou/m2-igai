var THREE = require('three');

class BSpline {
    constructor(pointsArray, order){
        this.pointsArray = [];
        for(var k in pointsArray)
            this.pointsArray[k] =  pointsArray[k].clone();
        this.k = order;
        
        this.u = [];
        for(var i = 0; i < pointsArray.length + order; i++){
            this.u[i] = i;
        }
    }
    
    computePoint(u){
        var dec = 0;
        var i = this.k;
        
        while(u > u[i]){
            dec++;
            i++;
        }
        
        var points = [];
        for(i = dec; i < dec + this.k; i++)
            points.push(this.pointsArray[i].clone())

        return this.floraison(points, dec, u, 0);
    }
    
    floraison(points, dec, u, r){
        if(r == this.k - 1)
            return points[0];
        for(var i = 0; i < this.k - 1 - r; i++){
            var ut1 = this.u[dec + 1 + i + r];
            var ut2 = this.u[dec + this.k + i];
            var deltaUt = ut2 - ut1;
            console.log((ut2 - u) / deltaUt + (u - ut1) / deltaUt)
            points[i] = points[i].multiplyScalar((ut2 - u) / deltaUt).add(points[i+1].multiplyScalar((u - ut1) / deltaUt));
        }
        return this.floraison(points, dec, u, r + 1);
    }
}

var test = new BSpline([new THREE.Vector3( 1, 0, 0 ),new THREE.Vector3( 2, 0, 0 ), new THREE.Vector3( 3, 0, 0 )],3);
console.log(test)
console.log(test.computePoint(2));