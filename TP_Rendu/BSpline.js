class BSpline extends Line {
    constructor(pointsArray, order){
        super(pointsArray);
        this.k = order;
        
        this.u = [];
        for(var i = 0; i < pointsArray.length + order; i++){
            this.u[i] = i;
        }
    }
    
    computePoint(u){
        var dec = 0;
        var i = this.k;
        
        while(u > this.u[i]){
            dec++;
            i++;
        }
        
        var points = [];
        for(i = dec; i < dec + this.k; i++)
            points.push(this.pointsArray[i].clone())

        return this.floraison(points, dec, u, 0);
    }
    
    computeLine(numberOfPoints){
        this.points = [];
        numberOfPoints--;
        for(var i = 0; i <= numberOfPoints; i++){
            this.points.push(this.computePoint(this.u[this.k - 1] + i*(this.u[this.pointsArray.length] - this.u[this.k - 1])/numberOfPoints))
        }
        return this.points;
    }
    
    floraison(points, dec, u, r){
        if(r == this.k - 1)
            return points[0];
        for(var i = 0; i < this.k - r - 1; i++){
            var ut1 = this.u[dec + 1 + i + r];
            var ut2 = this.u[dec + this.k + i];
            var deltaUt = ut2 - ut1;
            points[i] = points[i].multiplyScalar((ut2 - u) / deltaUt).add(points[i+1].clone().multiplyScalar((u - ut1) / deltaUt));
        }
        return this.floraison(points, dec, u, r + 1);
    }
}