%sample script to run interpolation
% you must add this JDBC driver path to connect to the database
jp='/home/snowhydro/nbair/software/databaseConnectors/MSSQLjdbc/mssql-jdbc-7.0.0.jre8.jar';

javaaddpath(jp);
conn=database('quinaya','snowuser','msbl0ws');
sqlquery = 'Use snow';
execute(conn,sqlquery);

%add paths
addpath('/home/snowhydro/nbair/sweInterpolation');

moddir='/home/snowhydro/nbair/datasets/SPIRES/Sierra/CAAlbers';
%get DEM
topofile='/home/snowhydro/nbair/datasets/DEMandTopography/DEM/SierraElevationCAAlbersWGS84.tif';
Z=geotiffread(topofile);

Interpout_dir='/home/snowhydro/nbair/datasets/sweInterp';
setdbprefs('DataReturnFormat','cellarray')  % This is the default setting
%%
WY=2001:2018;
for i=1:length(WY)
    scafname=fullfile(moddir,sprintf('Sierra%i.h5',WY(i)));
    [sca,dates,hdr]=GetEndmember(scafname,'snow');
    h5name=fullfile(Interpout_dir,sprintf('SWEInterpWY%i.h5',WY(i)));
    if exist(h5name,'file')~=0
        delete(h5name)
    end 
    [RawSWE,SCAswe,SWEpts]=SWEInterpolation(hdr.ProjectionStructure,...
    hdr.RefMatrix,dates,Z,sca,conn,true,'nearest',true,h5name);
end