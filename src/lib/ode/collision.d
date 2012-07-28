// This file is hand mangled of a ODE header file.
// See copyright in src/ode/ode.d (BSD).
module lib.ode.collision;

import lib.ode.common;
import lib.ode.contact;
import lib.ode.space;


const CONTACTS_UNIMPORTANT = 0x80000000;

const dMaxUserClasses = 4;

enum
{
	dSphereClass = 0,
	dBoxClass,
	dCapsuleClass,
	dCylinderClass,
	dPlaneClass,
	dRayClass,
	dConvexClass,
	dGeomTransformClass,
	dTriMeshClass,
	dHeightfieldClass,

	dFirstSpaceClass,
	dSimpleSpaceClass = dFirstSpaceClass,
	dHashSpaceClass,
	dQuadTreeSpaceClass,
	dLastSpaceClass = dQuadTreeSpaceClass,

	dFirstUserClass,
	dLastUserClass = dFirstUserClass + dMaxUserClasses - 1,
	dGeomNumClasses
}

alias void* dHeightfieldDataID;

extern (C) {
	typedef dReal function(void* p_user_data, int x, int z) dHeightfieldGetHeight;
}

extern (C) {
	typedef void function(dGeomID, dReal aabb[6]) dGetAABBFn;
	typedef int function(dGeomID o1, dGeomID o2, int flags, dContactGeom* contact, int skip) dColliderFn;
	typedef dColliderFn* function(int num) dGetColliderFnFn;
	typedef void function(dGeomID o) dGeomDtorFn;
	typedef int function(dGeomID o1, dGeomID o2, dReal aabb[6]) dAABBTestFn;
}

struct dGeomClass
{
	int bytes;
	dGetColliderFnFn collider;
	dGetAABBFn aabb;
	dAABBTestFn aabb_test;
	dGeomDtorFn dtor;
}

version(DynamicODE)
{
extern(C):
void (*dGeomDestroy)(dGeomID geom);
void (*dGeomSetData)(dGeomID geom, void* data);
void* (*dGeomGetData)(dGeomID geom);
void (*dGeomSetBody)(dGeomID geom, dBodyID b);
dBodyID (*dGeomGetBody)(dGeomID geom);
void (*dGeomSetPosition)(dGeomID geom, dReal x, dReal y, dReal z);
void (*dGeomSetRotation)(dGeomID geom, dMatrix3 R);
void (*dGeomSetQuaternion)(dGeomID geom, dQuaternion Q);
dReal* (*dGeomGetPosition)(dGeomID geom);
void (*dGeomCopyPosition)(dGeomID geom, dVector3 pos);
dReal* (*dGeomGetRotation)(dGeomID geom);
void (*dGeomCopyRotation)(dGeomID geom, dMatrix3 R);
void (*dGeomGetQuaternion)(dGeomID geom, dQuaternion result);
void (*dGeomGetAABB)(dGeomID geom, dReal aabb[6]);
int (*dGeomIsSpace)(dGeomID geom);
dSpaceID (*dGeomGetSpace)(dGeomID);
int (*dGeomGetClass)(dGeomID geom);
// These 4 might be wrong
void (*dGeomSetCategoryBits)(dGeomID geom, ulong bits);
void (*dGeomSetCollideBits)(dGeomID geom, ulong bits);
ulong (*dGeomGetCategoryBits)(dGeomID);
ulong (*dGeomGetCollideBits)(dGeomID);
void (*dGeomEnable)(dGeomID geom);
void (*dGeomDisable)(dGeomID geom);
int (*dGeomIsEnabled)(dGeomID geom);
void (*dGeomSetOffsetPosition)(dGeomID geom, dReal x, dReal y, dReal z);
void (*dGeomSetOffsetRotation)(dGeomID geom, dMatrix3 R);
void (*dGeomSetOffsetQuaternion)(dGeomID geom, dQuaternion Q);
void (*dGeomSetOffsetWorldPosition)(dGeomID geom, dReal x, dReal y, dReal z);
void (*dGeomSetOffsetWorldRotation)(dGeomID geom, dMatrix3 R);
void (*dGeomSetOffsetWorldQuaternion)(dGeomID geom, dQuaternion);
void (*dGeomClearOffset)(dGeomID geom);
int (*dGeomIsOffset)(dGeomID geom);
dReal* (*dGeomGetOffsetPosition)(dGeomID geom);
void (*dGeomCopyOffsetPosition)(dGeomID geom, dVector3 pos);
dReal* (*dGeomGetOffsetRotation)(dGeomID geom);
void (*dGeomCopyOffsetRotation)(dGeomID geom, dMatrix3 R);
void (*dGeomGetOffsetQuaternion)(dGeomID geom, dQuaternion result);
int (*dCollide)(dGeomID o1, dGeomID o2, int flags, dContactGeom *contact, int skip);
void (*dSpaceCollide)(dSpaceID space, void *data, dNearCallback callback);
void (*dSpaceCollide2)(dGeomID space1, dGeomID space2, void *data, dNearCallback callback);
dGeomID (*dCreateSphere)(dSpaceID space, dReal radius);
void (*dGeomSphereSetRadius)(dGeomID sphere, dReal radius);
dReal (*dGeomSphereGetRadius)(dGeomID sphere);
dReal (*dGeomSpherePointDepth)(dGeomID sphere, dReal x, dReal y, dReal z);
dGeomID (*dCreateConvex)(dSpaceID space, dReal *_planes, uint _planecount, dReal *_points, uint _pointcount, uint *_polygons);
void (*dGeomSetConvex)(dGeomID g, dReal *_planes, uint _count, dReal *_points, uint _pointcount, uint *_polygons);
dGeomID (*dCreateBox)(dSpaceID space, dReal lx, dReal ly, dReal lz);
void (*dGeomBoxSetLengths)(dGeomID box, dReal lx, dReal ly, dReal lz);
void (*dGeomBoxGetLengths)(dGeomID box, dVector3 result);
dReal (*dGeomBoxPointDepth)(dGeomID box, dReal x, dReal y, dReal z);
dGeomID (*dCreatePlane)(dSpaceID space, dReal a, dReal b, dReal c, dReal d);
void (*dGeomPlaneSetParams)(dGeomID plane, dReal a, dReal b, dReal c, dReal d);
void (*dGeomPlaneGetParams)(dGeomID plane, dVector4 result);
dReal (*dGeomPlanePointDepth)(dGeomID plane, dReal x, dReal y, dReal z);
dGeomID (*dCreateCapsule)(dSpaceID space, dReal radius, dReal length);
void (*dGeomCapsuleSetParams)(dGeomID ccylinder, dReal radius, dReal length);
void (*dGeomCapsuleGetParams)(dGeomID ccylinder, dReal *radius, dReal *length);
dReal (*dGeomCapsulePointDepth)(dGeomID ccylinder, dReal x, dReal y, dReal z);
dGeomID (*dCreateCylinder)(dSpaceID space, dReal radius, dReal length);
void (*dGeomCylinderSetParams)(dGeomID cylinder, dReal radius, dReal length);
void (*dGeomCylinderGetParams)(dGeomID cylinder, dReal *radius, dReal *length);
dGeomID (*dCreateRay)(dSpaceID space, dReal length);
void (*dGeomRaySetLength)(dGeomID ray, dReal length);
dReal (*dGeomRayGetLength)(dGeomID ray);
void (*dGeomRaySet)(dGeomID ray, dReal px, dReal py, dReal pz, dReal dx, dReal dy, dReal dz);
void (*dGeomRayGet)(dGeomID ray, dVector3 start, dVector3 dir);
void (*dGeomRaySetParams)(dGeomID g, int FirstContact, int BackfaceCull);
void (*dGeomRayGetParams)(dGeomID g, int *FirstContact, int *BackfaceCull);
void (*dGeomRaySetClosestHit)(dGeomID g, int closestHit);
int (*dGeomRayGetClosestHit)(dGeomID g);
dGeomID (*dCreateGeomTransform)(dSpaceID space);
void (*dGeomTransformSetGeom)(dGeomID g, dGeomID obj);
dGeomID (*dGeomTransformGetGeom)(dGeomID g);
void (*dGeomTransformSetCleanup)(dGeomID g, int mode);
int (*dGeomTransformGetCleanup)(dGeomID g);
void (*dGeomTransformSetInfo)(dGeomID g, int mode);
int (*dGeomTransformGetInfo)(dGeomID g);
dGeomID (*dCreateHeightfield)(dSpaceID space, dHeightfieldDataID data, int bPlaceable);
dHeightfieldDataID (*dGeomHeightfieldDataCreate)();
void (*dGeomHeightfieldDataDestroy)(dHeightfieldDataID d);
void (*dGeomHeightfieldDataBuildCallback)(dHeightfieldDataID d, void* pUserData, dHeightfieldGetHeight* pCallback, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void (*dGeomHeightfieldDataBuildByte)(dHeightfieldDataID d, char* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void (*dGeomHeightfieldDataBuildShort)(dHeightfieldDataID d, short* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void (*dGeomHeightfieldDataBuildSingle)(dHeightfieldDataID d, float* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void (*dGeomHeightfieldDataBuildDouble)(dHeightfieldDataID d, double* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void (*dGeomHeightfieldDataSetBounds)(dHeightfieldDataID d, dReal minHeight, dReal maxHeight);
void (*dGeomHeightfieldSetHeightfieldData)(dGeomID g, dHeightfieldDataID d);
dHeightfieldDataID (*dGeomHeightfieldGetHeightfieldData)(dGeomID g);
void (*dClosestLineSegmentPoints)(dVector3 a1, dVector3 a2, dVector3 b1, dVector3 b2, dVector3 cp1, dVector3 cp2);
int (*dBoxTouchesBox)(dVector3 _p1, dMatrix3 R1, dVector3 side1, dVector3 _p2, dMatrix3 R2, dVector3 side2);
int (*dBoxBox)(dVector3 p1, dMatrix3 R1, dVector3 side1, dVector3 p2, dMatrix3 R2, dVector3 side2, dVector3 normal, dReal *depth, int *return_code, int flags, dContactGeom *contact, int skip);
void (*dInfiniteAABB)(dGeomID geom, dReal aabb[6]);
void (*dCloseODE)();
int (*dCreateGeomClass)(dGeomClass *classptr);
void* (*dGeomGetClassData)(dGeomID);
dGeomID (*dCreateGeom)(int classnum);
}
else
{
extern(C):
void dGeomDestroy(dGeomID geom);
void dGeomSetData(dGeomID geom, void* data);
void* dGeomGetData(dGeomID geom);
void dGeomSetBody(dGeomID geom, dBodyID b);
dBodyID dGeomGetBody(dGeomID geom);
void dGeomSetPosition(dGeomID geom, dReal x, dReal y, dReal z);
void dGeomSetRotation(dGeomID geom, dMatrix3 R);
void dGeomSetQuaternion(dGeomID geom, dQuaternion Q);
dReal* dGeomGetPosition(dGeomID geom);
void dGeomCopyPosition(dGeomID geom, dVector3 pos);
dReal* dGeomGetRotation(dGeomID geom);
void dGeomCopyRotation(dGeomID geom, dMatrix3 R);
void dGeomGetQuaternion(dGeomID geom, dQuaternion result);
void dGeomGetAABB(dGeomID geom, dReal aabb[6]);
int dGeomIsSpace(dGeomID geom);
dSpaceID dGeomGetSpace(dGeomID);
int dGeomGetClass(dGeomID geom);
// These 4 might be wrong
void dGeomSetCategoryBits(dGeomID geom, ulong bits);
void dGeomSetCollideBits(dGeomID geom, ulong bits);
ulong dGeomGetCategoryBits(dGeomID);
ulong dGeomGetCollideBits(dGeomID);
void dGeomEnable(dGeomID geom);
void dGeomDisable(dGeomID geom);
int dGeomIsEnabled(dGeomID geom);
void dGeomSetOffsetPosition(dGeomID geom, dReal x, dReal y, dReal z);
void dGeomSetOffsetRotation(dGeomID geom, dMatrix3 R);
void dGeomSetOffsetQuaternion(dGeomID geom, dQuaternion Q);
void dGeomSetOffsetWorldPosition(dGeomID geom, dReal x, dReal y, dReal z);
void dGeomSetOffsetWorldRotation(dGeomID geom, dMatrix3 R);
void dGeomSetOffsetWorldQuaternion(dGeomID geom, dQuaternion);
void dGeomClearOffset(dGeomID geom);
int dGeomIsOffset(dGeomID geom);
dReal* dGeomGetOffsetPosition(dGeomID geom);
void dGeomCopyOffsetPosition(dGeomID geom, dVector3 pos);
dReal* dGeomGetOffsetRotation(dGeomID geom);
void dGeomCopyOffsetRotation(dGeomID geom, dMatrix3 R);
void dGeomGetOffsetQuaternion(dGeomID geom, dQuaternion result);
int dCollide(dGeomID o1, dGeomID o2, int flags, dContactGeom *contact, int skip);
void dSpaceCollide(dSpaceID space, void *data, dNearCallback callback);
void dSpaceCollide2(dGeomID space1, dGeomID space2, void *data, dNearCallback callback);
dGeomID dCreateSphere(dSpaceID space, dReal radius);
void dGeomSphereSetRadius(dGeomID sphere, dReal radius);
dReal dGeomSphereGetRadius(dGeomID sphere);
dReal dGeomSpherePointDepth(dGeomID sphere, dReal x, dReal y, dReal z);
dGeomID dCreateConvex(dSpaceID space, dReal *_planes, uint _planecount, dReal *_points, uint _pointcount, uint *_polygons);
void dGeomSetConvex(dGeomID g, dReal *_planes, uint _count, dReal *_points, uint _pointcount, uint *_polygons);
dGeomID dCreateBox(dSpaceID space, dReal lx, dReal ly, dReal lz);
void dGeomBoxSetLengths(dGeomID box, dReal lx, dReal ly, dReal lz);
void dGeomBoxGetLengths(dGeomID box, dVector3 result);
dReal dGeomBoxPointDepth(dGeomID box, dReal x, dReal y, dReal z);
dGeomID dCreatePlane(dSpaceID space, dReal a, dReal b, dReal c, dReal d);
void dGeomPlaneSetParams(dGeomID plane, dReal a, dReal b, dReal c, dReal d);
void dGeomPlaneGetParams(dGeomID plane, dVector4 result);
dReal dGeomPlanePointDepth(dGeomID plane, dReal x, dReal y, dReal z);
dGeomID dCreateCapsule(dSpaceID space, dReal radius, dReal length);
void dGeomCapsuleSetParams(dGeomID ccylinder, dReal radius, dReal length);
void dGeomCapsuleGetParams(dGeomID ccylinder, dReal *radius, dReal *length);
dReal dGeomCapsulePointDepth(dGeomID ccylinder, dReal x, dReal y, dReal z);
dGeomID dCreateCylinder(dSpaceID space, dReal radius, dReal length);
void dGeomCylinderSetParams(dGeomID cylinder, dReal radius, dReal length);
void dGeomCylinderGetParams(dGeomID cylinder, dReal *radius, dReal *length);
dGeomID dCreateRay(dSpaceID space, dReal length);
void dGeomRaySetLength(dGeomID ray, dReal length);
dReal dGeomRayGetLength(dGeomID ray);
void dGeomRaySet(dGeomID ray, dReal px, dReal py, dReal pz, dReal dx, dReal dy, dReal dz);
void dGeomRayGet(dGeomID ray, dVector3 start, dVector3 dir);
void dGeomRaySetParams(dGeomID g, int FirstContact, int BackfaceCull);
void dGeomRayGetParams(dGeomID g, int *FirstContact, int *BackfaceCull);
void dGeomRaySetClosestHit(dGeomID g, int closestHit);
int dGeomRayGetClosestHit(dGeomID g);
dGeomID dCreateGeomTransform(dSpaceID space);
void dGeomTransformSetGeom(dGeomID g, dGeomID obj);
dGeomID dGeomTransformGetGeom(dGeomID g);
void dGeomTransformSetCleanup(dGeomID g, int mode);
int dGeomTransformGetCleanup(dGeomID g);
void dGeomTransformSetInfo(dGeomID g, int mode);
int dGeomTransformGetInfo(dGeomID g);
dGeomID dCreateHeightfield(dSpaceID space, dHeightfieldDataID data, int bPlaceable);
dHeightfieldDataID dGeomHeightfieldDataCreate();
void dGeomHeightfieldDataDestroy(dHeightfieldDataID d);
void dGeomHeightfieldDataBuildCallback(dHeightfieldDataID d, void* pUserData, dHeightfieldGetHeight* pCallback, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void dGeomHeightfieldDataBuildByte(dHeightfieldDataID d, char* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void dGeomHeightfieldDataBuildShort(dHeightfieldDataID d, short* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void dGeomHeightfieldDataBuildSingle(dHeightfieldDataID d, float* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void dGeomHeightfieldDataBuildDouble(dHeightfieldDataID d, double* pHeightData, int bCopyHeightData, dReal width, dReal depth, int widthSamples, int depthSamples, dReal scale, dReal offset, dReal thickness, int bWrap);
void dGeomHeightfieldDataSetBounds(dHeightfieldDataID d, dReal minHeight, dReal maxHeight);
void dGeomHeightfieldSetHeightfieldData(dGeomID g, dHeightfieldDataID d);
dHeightfieldDataID dGeomHeightfieldGetHeightfieldData(dGeomID g);
void dClosestLineSegmentPoints(dVector3 a1, dVector3 a2, dVector3 b1, dVector3 b2, dVector3 cp1, dVector3 cp2);
int dBoxTouchesBox(dVector3 _p1, dMatrix3 R1, dVector3 side1, dVector3 _p2, dMatrix3 R2, dVector3 side2);
int dBoxBox(dVector3 p1, dMatrix3 R1, dVector3 side1, dVector3 p2, dMatrix3 R2, dVector3 side2, dVector3 normal, dReal *depth, int *return_code, int flags, dContactGeom *contact, int skip);
void dInfiniteAABB(dGeomID geom, dReal aabb[6]);
void dCloseODE();
int dCreateGeomClass(dGeomClass *classptr);
void* dGeomGetClassData(dGeomID);
dGeomID dCreateGeom(int classnum);
}
