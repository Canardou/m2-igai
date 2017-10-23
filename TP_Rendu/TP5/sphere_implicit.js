class sphere{
    constructor(x, y, z, r){
        this.x = x; 
        this.y = y;
        this.z = z;
        this.r = r;
    }
    
    distance(x,y,z){
        return Math.max(1 - ((x - this.x)*(x - this.x) + (y - this.y)*(y - this.y) + (z - this.z)*(z - this.z))/this.r, 0);
    }
}