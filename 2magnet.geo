// define geometry-specific parameters
mm = 1.e-3;
  
DefineConstant[
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

p1 = newp; Point(p1) = {-cub, -cub, -hite, lc1};
p2 = newp; Point(p2) = { cub, -cub, -hite, lc1};
p3 = newp; Point(p3) = { cub,  cub, -hite, lc1};
p4 = newp; Point(p4) = {-cub,  cub, -hite, lc1};
l1 = newl; Line(l1) = {p1,p2}; l2 = newl; Line(l2) = {p2,p3};
l3 = newl; Line(l3) = {p3,p4}; l4 = newl; Line(l4) = {p4,p1};
ll1 = newll; Line Loop(ll1) = {l1,l2,l3,l4};
s1 = news; Plane Surface(s1) = {ll1};
mag[] = Extrude {0, 0, 2*hite} { Surface{s1}; };
Physical Volume(0) = {mag[1]};

//create steel frame around the magnet
p1 = newp; Point(p1) = {-2*cub, -cub, -hite, lc1};
p2 = newp; Point(p2) = { 2*cub, -cub, -hite, lc1};
p3 = newp; Point(p3) = { 2*cub, -cub,  hite, lc1};
p4 = newp; Point(p4) = {-2*cub, -cub,  hite, lc1};
l1 = newl; Line(l1) = {p1,p2}; l2 = newl; Line(l2) = {p2,p3};
l3 = newl; Line(l3) = {p3,p4}; l4 = newl; Line(l4) = {p4,p1};
ll1 = newll; Line Loop(ll1) = {l1,l2,l3,l4};
hite2 = hite + cub;
p1 = newp; Point(p1) = {-4*cub, -cub, -hite2, lc1};
p2 = newp; Point(p2) = { 4*cub, -cub, -hite2, lc1};
p3 = newp; Point(p3) = { 4*cub, -cub,  hite2, lc1};
p4 = newp; Point(p4) = {-4*cub, -cub,  hite2, lc1};
l1 = newl; Line(l1) = {p1,p2}; l2 = newl; Line(l2) = {p2,p3};
l3 = newl; Line(l3) = {p3,p4}; l4 = newl; Line(l4) = {p4,p1};
ll2 = newll; Line Loop(ll2) = {l1,l2,l3,l4};
s1 = news; Plane Surface(s1) = {ll2, ll1};
frame[] = Extrude {0, 2*cub, 0} { Surface{s1}; };
Physical Volume(1) = {frame[1]};



// create air box around magnets
BoundingBox; // recompute model bounding box
cx = (General.MinX + General.MaxX) / 2;
cy = (General.MinY + General.MaxY) / 2;
cz = (General.MinZ + General.MaxZ) / 2;
lx = 2*inf + General.MaxX - General.MinX;
ly = 2*inf + General.MaxY - General.MinZ;
lz = 2*inf + General.MaxZ - General.MinZ;
p1 = newp; Point (p1) = {cx-lx/2, cy-ly/2, cz-lz/2, lc2};
p2 = newp; Point (p2) = {cx+lx/2, cy-ly/2, cz-lz/2, lc2};
l1 = newl; Line(l1) = {p1, p2};
e1[] = Extrude {0, ly, 0} { Line{l1}; };
air[] = Extrude {0, 0, lz} { Surface{e1[1]}; };
slair = newsl; Surface Loop(slair) = Boundary{Volume{air[1]}; };
slmag = newsl; Surface Loop(slmag) = Boundary{Volume{mag[1]}; };
slframe = newsl; Surface Loop(slframe) = Boundary{Volume{frame[1]}; };
vair = newv; Volume(vair) = {slair, slmag};
Physical Volume(2) = vair; // air
Physical Surface(3) = {e1[1], air[0], air[2], air[3], air[4], air[5]};
Delete { Volume{air[1]}; }//
