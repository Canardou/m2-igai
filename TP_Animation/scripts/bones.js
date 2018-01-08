class Bone{
   constructor(x,y,z,r,parent,color){
       this.position = new THREE.Vector3(x,y,z);
       this.transformation = (new THREE.Matrix4()).identity();
       this.parent = parent;
       //Weight calculation
       this.radius = r;
       //Cool color
       this.color = color;
       var geometry = new THREE.SphereGeometry( r, 16, 16 );
       var material = new THREE.MeshBasicMaterial( {color: color, transparent: true, opacity: 0.5 } );
       this.sphere = new THREE.Mesh( geometry, material );
       if(this.parent != null){
           var dir = (new THREE.Vector3()).subVectors( this.position, this.parent.position ).normalize();
           this.arrow = new THREE.ArrowHelper( dir, this.parent.position, this.position.distanceTo( this.parent.position ), this.color );
       }
   }
   
   setRadius(radius){
       this.radius = radius;
       var geometry = new THREE.SphereGeometry( radius, 16, 16 );
       var material = new THREE.MeshBasicMaterial( {color: this.color, transparent: true, opacity: 0.5 } );
       this.sphere = new THREE.Mesh( geometry, material );
   }
   
   updateArrow(transfo){
       var newPos = this.getTransformedPosition();
       this.sphere.position.copy(newPos);
       if(this.parent != null){
           var pPos = this.parent.getTransformedPosition();
           var dir = (new THREE.Vector3()).subVectors( newPos, pPos ).normalize();
           this.arrow.position.copy(pPos);
           this.arrow.setDirection(dir);
           this.arrow.setLength(newPos.distanceTo( pPos ));
       }
   }
   
   getPosition(){
       return this.position;
   }
   
   updateTransformedPosition(transfo){
       this.tPos = this.position.clone().applyMatrix4(transfo);
   }
   
   getTransformedPosition(){
       return this.tPos;
   }
   
   getTransformation(){
       var current = this;
       var transformation = new THREE.Matrix4();
       var inverseTranslation = new THREE.Matrix4();
       var to_treat = [];
       while(current != null){
           to_treat.unshift(current);
           current = current.parent;
       }
       for(var x in to_treat){
           current = to_treat[x];
           if(current.parent != null)
            transformation.multiply(new THREE.Matrix4().makeTranslation(current.position.x-current.parent.position.x,current.position.y-current.parent.position.y,current.position.z-current.parent.position.z));
           else
            transformation.multiply(new THREE.Matrix4().makeTranslation(current.position.x,current.position.y,current.position.z));
           
           transformation.multiply(current.transformation);
           
           if(current.parent != null)
            inverseTranslation.multiply(new THREE.Matrix4().makeTranslation(current.parent.position.x-current.position.x,current.parent.position.y-current.position.y,current.parent.position.z-current.position.z))
           else
            inverseTranslation.multiply(new THREE.Matrix4().makeTranslation(-current.position.x,-current.position.y,-current.position.z))
       }
       transformation.multiply(inverseTranslation);
       this.updateTransformedPosition(transformation);
       this.updateArrow();
       return transformation;
   }
}

function mat2dual(mat){
    var rotationQuat = new THREE.Quaternion();
    var translationQuat = new THREE.Quaternion(mat.elements[12], mat.elements[13], mat.elements[14], 0.0);
    rotationQuat.setFromRotationMatrix(mat);

    translationQuat.multiplyQuaternions(translationQuat, rotationQuat);
    translationQuat.x = translationQuat.x/2;
    translationQuat.y = translationQuat.y/2;
    translationQuat.z = translationQuat.z/2;
    translationQuat.w = translationQuat.w/2;
    
    return {rotation:rotationQuat, translation:translationQuat};
}

function initTransformations(bonesGeometry, uBonesQuatRotation, uBonesQuatTranslat, uBonesTransformation){
    for(var k = 0; k < bonesGeometry.length; k++){
        var transfo = bonesGeometry[k].getTransformation();
        uBonesTransformation[k] = transfo;
        var dual = mat2dual(transfo);
        uBonesQuatRotation[k] = dual.rotation;
        uBonesQuatTranslat[k] = dual.translation;
    }
}

function getBonesWeights(bonesGeometry, vertices){
    var bones = [];
    var weights = [];
    //Calculate weights (4 max per vertex) once only !
    for(var i = 0; i < vertices.count; i++){
        var current = new THREE.Vector3(vertices.getX(i),vertices.getY(i),vertices.getZ(i));
        //Find closest 4
        var list = [];
        for(var j=0; j<bonesGeometry.length; j++){
            var bone = bonesGeometry[j];
            var dist = current.distanceTo(bone.position);
            if(dist < bone.radius){
                dist = (bone.radius-dist)/bone.radius;
            }
            else
                dist = 0;
            list.push({bone: j, dist: dist});
        }
        
        list.sort(function(a, b) {
            return ((a.dist > b.dist) ? -1 : ((a.dist == b.dist) ? 0 : 1));
        });
        
        //Calculate weights
        var unWeights = [];
        var total = 0;
        for(var j=0; j<2; j++){
            var bone = bonesGeometry[list[j].bone];
            var dist = list[j].dist;
            unWeights[j] = dist;
            total += unWeights[j];
        }
        if(total == 0){
            weights = weights.concat([1,0]);
            bones = bones.concat([0,0]);
        }
        else {
            unWeights.forEach((e, i, a) => a[i] = e/total);
            weights = weights.concat(unWeights);
            bones = bones.concat([list[0].bone,list[1].bone]);
        }
    }
    return {bones: new Uint8Array(bones), weights: new Float32Array(weights)};
}