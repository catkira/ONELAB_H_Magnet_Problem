SetFactory("OpenCASCADE");
  
DefineConstant[
  mm = 1.e-3,
  cub = {10*mm, Name "Parameters/2Magnet bottom size [m]"}
  hite = {20*mm, Name "Parameters/2Magnet hieght [m]"}
  lc1 = {TotalMemory <= 2048 ? 5*mm : 2*mm, Name "Parameters/3Mesh size on magnets [m]"}
  lc2 = {TotalMemory <= 2048 ? 20*mm : 10*mm, Name "Parameters/4Mesh size at infinity [m]"}
  inf = {100*mm, Name "Parameters/1Air box distance [m]"}
];

// change global Gmsh options
Mesh.Optimize = 1; // optimize quality of tetrahedra
Mesh.VolumeEdges = 0; // hide volume edges
Geometry.ExactExtrusion = 0; // to allow rotation of extruded shapes
Solver.AutoMesh = 2; // always remesh if necessary (don't reuse mesh on disk)
Geometry.OCCBooleanPreserveNumbering = 1;

//create magnet
mag = newv; Box(mag) = {-cub, -cub, -hite, 2*cub, 2*cub, 2*hite};

//create frame
hite2 = hite + cub;
eps = 0.001;
frameOutside = newv; Box(frameOutside) = {-4*cub, -cub, -hite2, 8*cub, 2*cub, 2*hite2};
frameInside = newv; Box(frameInside) = {-2*cub, -cub-eps, -hite, 4*cub, 2*(cub+eps), 2*hite};
frameArr() = BooleanDifference{ Volume{frameOutside}; Delete;}{ Volume{frameInside}; Delete;};
frame = frameArr(#frameArr()-1);
Printf("Volume %i", mag);


// create air box around magnets
air = newv; Box(air) = {-inf, -inf, -inf, 2*inf, 2*inf, 2*inf};
airBoundary() = {Boundary{ Volume{air()}; }};
air = BooleanDifference{Volume{air}; Delete;}{Volume{frame}; Volume{mag};}; // why is this line needed?
Coherence;

//set mesh size
MeshSize{ PointsOf{ Volume{frame, mag}; } } = lc1;

Physical Volume(0) = {mag};
Physical Volume(1) = {frame};
Physical Volume(2) = {air};
Physical Surface(3) = {airBoundary[]};

