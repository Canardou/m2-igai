class plan{
    constructor(y){
        this.y = y;
    }
    
    distance(x,y,z){
        return Math.min(1,Math.max(this.y-y,0));
    }
}