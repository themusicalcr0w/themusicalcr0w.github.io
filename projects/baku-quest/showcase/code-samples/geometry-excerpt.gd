# Source: Scripts/World/Suburban/StaticGeometryMerge.gd
# Selected source; requires the surrounding project.

static func build(records:Array,material:Material,flags:int)->ImporterMesh:
 var merged:Array=[];merged.resize(Mesh.ARRAY_MAX)
 var indices:=PackedInt32Array()
 var vertex_offset:=0
 var active:Array=[];active.resize(Mesh.ARRAY_MAX);active.fill(false)
 var output_flags:=0
 for record in records:
  for channel in range(1,Mesh.ARRAY_INDEX):
   if record.arrays[channel]!=null:active[channel]=true
 for channel in range(Mesh.ARRAY_CUSTOM0,Mesh.ARRAY_CUSTOM3+1):
  if active[channel]:output_flags |= Mesh.ARRAY_CUSTOM_RGBA_FLOAT << (Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT+(channel-Mesh.ARRAY_CUSTOM0)*Mesh.ARRAY_FORMAT_CUSTOM_BITS)
 for record in records:
  var arrays:Array=record.arrays
  var pose:Transform3D=record.pose
  var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX].duplicate()
  for i in vertices.size():vertices[i]=pose*vertices[i]
  _append(merged,Mesh.ARRAY_VERTEX,vertices)
  var normal_basis:=pose.basis.inverse().transposed()
  for channel in range(1,Mesh.ARRAY_INDEX):
   if not active[channel]:continue
   var values:Variant
   if channel>=Mesh.ARRAY_CUSTOM0 and channel<=Mesh.ARRAY_CUSTOM3:
    var format:int=(int(record.get('flags',flags))>>(Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT+(channel-Mesh.ARRAY_CUSTOM0)*Mesh.ARRAY_FORMAT_CUSTOM_BITS))&7
    values=_custom_rgba(arrays[channel],format,vertices.size())
   elif arrays[channel]!=null:values=arrays[channel].duplicate()
   else:values=_defaults(channel,vertices.size())
   if channel==Mesh.ARRAY_NORMAL:
    for i in values.size():values[i]=(normal_basis*values[i]).normalized()
   elif channel==Mesh.ARRAY_TANGENT:
    for i in range(0,values.size(),4):
     var tangent:Vector3=(pose.basis*Vector3(values[i],values[i+1],values[i+2])).normalized()
     values[i]=tangent.x;values[i+1]=tangent.y;values[i+2]=tangent.z
   _append(merged,channel,values)
  var source_indices=arrays[Mesh.ARRAY_INDEX]
  if source_indices!=null and not source_indices.is_empty():
   for index in source_indices:indices.append(index+vertex_offset)
  else:
   for index in vertices.size():indices.append(index+vertex_offset)
  vertex_offset+=vertices.size()
 merged[Mesh.ARRAY_INDEX]=indices
 var importer:=ImporterMesh.new()
 importer.add_surface(Mesh.PRIMITIVE_TRIANGLES,merged,[],{},material,'',output_flags)
 importer.generate_lods(25.0,60.0,[])
 return importer
