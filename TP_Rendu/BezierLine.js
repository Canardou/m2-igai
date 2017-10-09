class BezierLine extends Line {
    constructor(pointsArray, order){
        super(pointsArray);
    }
    
    computePoint(t){
        var length = this.pointsArray.length - 1;
        var point = this.pointsArray[0].clone().multiplyScalar(Math.pow((1-t),length));
        for(var i = 1; i <= length; i++){
            point = point.add(this.pointsArray[i].clone().multiplyScalar(this.binomial(length,i)*Math.pow((1-t),length-i)*Math.pow(t,i)));
        }
        return point;
    }
    
    computeLine(numberOfPoints){
        this.points = [];
        numberOfPoints--;
        for(var i = 0; i <= numberOfPoints; i++){
            this.points.push(this.computePoint(i/numberOfPoints))
        }
        return this.points;
    }
    
    binomial(n, k) {
        if ((typeof n !== 'number') || (typeof k !== 'number')) 
            return false; 
        var coeff = 1;
        for (var x = n-k+1; x <= n; x++) coeff *= x;
        for (x = 1; x <= k; x++) coeff /= x;
        return coeff;
    }

}