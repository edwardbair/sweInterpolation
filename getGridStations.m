% find the Pillows and Courses in an elevation grid, along with their
% coordinates
function [P,C,XP,XC]=getGridStations(mstruct,Rmap,Z,conn)
%
% input
%   mstruct - structure that defines projection of grid
%   Rmap - referencing matrix of elevation grid
%   Z - elevation grid
%   conn - matlab databse connection object
%
% output
%   P - CDEC codes for pillows within grid
%   C - CDEC codes for courses within grid
%   XP - Np x 3 matrix, x, y, z coordinates of the pillows
%   XC - Nc x 3 matrix, x, y, z coordinates of the courses

% pillow and course locations are lat-lon, get lat-lon corners of the grid
N=size(Z);
[xcorner,ycorner]=pix2map(Rmap,[1 N(1) N(1) 1],[1 1 N(2) N(2)]);
[lat,lon]=projinv(mstruct,xcorner,ycorner);

% Make connection to database.  Note that the password and username are
% needed with the JDBC connection.
% conn=database.ODBCConnection('SierraNevadaSnow',username,passwd);
% first the pillows
% generate the query
qstr=sprintf('SELECT DISTINCT CDEC,Elevation,Latitude,Longitude FROM PillowLocation WHERE Latitude BETWEEN %g AND %g AND Longitude BETWEEN %g AND %g',...
    min(lat),max(lat),min(lon),max(lon));
% retrieve the data
curs = exec(conn,qstr);
e = fetch(curs);
% close(curs)
% close(e)
% e=fetch(conn,qstr);
% close(conn)
if isempty(e.Data) | strcmp(e.Data,'No Data')
    warning('function getGridStations: pillow query returned no data\n%s',qstr)
    P=[];
    XP=[];
else
    P=table2cell(e.Data(:,1));
%     zp=cell2mat(e.Data(:,2));
    zp=table2array(e.Data(:,2));
%     [xp,yp]=projfwd(mstruct,cell2mat(e.Data(:,3)),cell2mat(e.Data(:,4)));
    [xp,yp]=projfwd(mstruct,table2array(e.Data(:,3)),table2array(e.Data(:,4)));   
    XP=zeros(length(xp),3);
    XP(:,1)=xp;
    XP(:,2)=yp;
    XP(:,3)=zp;
end

% then the courses
% generate the query
qstr=sprintf('SELECT DISTINCT CDEC,Elevation,Latitude,Longitude FROM CourseLocationCurrent WHERE Latitude BETWEEN %g AND %g AND Longitude BETWEEN %g AND %g',...
    min(lat),max(lat),min(lon),max(lon));
% retrieve the data
e = exec(conn,qstr,'cursorType','scrollable');
e = fetch(e);
% close(e)
if isempty(e.Data) | strcmp(e.Data,'No Data')
    warning('function getGridStations: course query returned no data\n%s',qstr)
    C=[];
    XC=[];
else
    C=table2cell(e.Data(:,1));
%     zc=cell2mat(e.Data(:,2));
    zc=table2array(e.Data(:,2));
%     [xc,yc]=projfwd(mstruct,cell2mat(e.Data(:,3)),cell2mat(e.Data(:,4)));
    [xc,yc]=projfwd(mstruct,table2array(e.Data(:,3)),table2array(e.Data(:,4)));
    XC=zeros(length(xc),3);
    XC(:,1)=xc;
    XC(:,2)=yc;
    XC(:,3)=zc;
end